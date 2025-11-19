# Graetzl Wirtschaft – Technisches Schema

> **Ziel:** Verbindliche Referenz für Tabellen, Felder, Enums, Relationen, Indizes und Seeds.  
> **Scope:** Neue Buchungsplattform (Rooms, Services, Events) inklusive Zahlungen, Refunds, Templates & Abwesenheiten.

---

## Lesehinweise & Konventionen
- **Datentypen:** Rails-Migrationstyp (`string`, `integer`, `t.references`) ergänzt um wichtige Optionen (`null`, `default`, `index`). Geldbeträge als `decimal(10,2)` (`amount`, `price_amount`, `platform_fee_amount`). Zeitpunkte als `datetime`, `date`, `time`.
- **Foreign Keys:** `foreign_key: true` bei Standardnamen; `foreign_key: { to_table: ... }` wenn Zieltabellen anders heißen. Eigene Namen nur falls nötig.
- **Enums:** Status-Felder als Integer-Enums (`enabled`, `disabled`, `deleted`); neue Optionsfelder (z. B. `bookables_price_rules.strategy`) als String-Enums. Defaults im Dokument fixieren.
- **Indizes:** `DB`-Notation (`INDEX bookings_on_bookable`), Unique-Indizes als `UNIQUE`.
- **Timestamps:** Alle Tabellen `t.timestamps` (UTC) sofern nicht anders erwähnt.
- **Polymorph:** Felder `_type` + `_id` `string` + `bigint`.
- **Seeds:** explizit markiert.
- **Currency:** Zahlungen erfolgen in EUR; bei Buchungen bleibt `currency` (Default `"eur"`), bei Bookables entfällt das Feld.
- **Regionen:** `region_id` ist ein String-Key (konfiguriert via Region-Config), kein echtes AR-Modell.
- **User-Lifecycle:** Nutzer:innen dürfen wegen historischer Verknüpfungen (Bookings, OwnerPayouts) nicht hart gelöscht werden. Soft-Delete/Anonymisierung einplanen, damit FKs bestehen bleiben und DSGVO-Anforderungen erfüllt werden.

Weitere Prozess- und UX-Kontexte: `models.md` (Domain-Übersicht), `availability.md`, `cancellation.md`, `payment.md`. Bei Abweichungen gilt **dieses** Schema-Dokument.

---

## 1. Benutzer & Identitäten

### 1.1 `users` (bestehend)
- Verwendung als **Owner** (`owner_id`) und **Customer** (`customer_id`) in neuen Tabellen.
- Erweiterungen prüfen:
  - `stripe_connect_account_id:string` – Feld existiert bereits und wird für Stripe-Connect-Verknüpfungen genutzt.
  - `payout_pause:boolean` – optional später.

---

## 2. Bookable-Basis

### 2.1 Concern `Bookable`
- **Pflichtattribute (direkt auf dem Bookable):** `user_id`, `owner_id` (optional), `cancellation_policy_id`.
- **Owner-Default:** `owner_id` wird beim Anlegen standardmäßig auf `user_id` gesetzt (nur spezialisierte Flows – z. B. später Services im Auftrag Dritter – dürfen das Feld bewusst anpassen).
- **Geteilte Relationen:**
  - `belongs_to :user` (Owner-Konto, required)
  - `belongs_to :owner, class_name: "User"` (optional, default User)
  - `belongs_to :cancellation_policy, optional: true`
  - `has_many :bookings`, `has_many :availability_rules`, `has_many :blackouts`
  - `has_one :slot_policy`, `has_many :price_rules`
- **Gemeinsam genutzte Strukturen:** `bookables_availability_rules`, `bookables_blackouts`, `bookables_slot_policies`, `bookables_price_rules`.
- **Typ-spezifisch:** Konkrete Felder für Dauer, Kapazität, Anfrage-Workflow usw. werden pro Bookable (Room, Service, EventRun, EventSession) festgelegt.

### 2.2 Tabelle `bookables_cancellation_policies`
- **Seeds (fixe 9 Policies)** – siehe Werte in `app/docs/graetzl_wirtschaft/cancellation.md:32` ff.
- **Spalten**
  - `key:string`, `null: false`, `index: { unique: true }`
  - `name:string`, `null: false`
  - `description:text`, optional
  - `rules:jsonb`, `null: false`, default: `{}` (struktur siehe Cancellation-Doku)
  - `created_at`, `updated_at`
- **Rules-Struktur (Beispiel)**
  ```json
  {
    "refund_tiers": [
      { "before_hours": 48, "refund_percent": 100 },
      { "before_hours": 0,  "refund_percent": 80 }
    ],
    "provider_rules": [
      { "on": "provider_cancel", "fee_percent": 5 }
    ],
    "customer_rules": [
      { "after_deadline": true, "fee_percent": 5 }
    ]
  }
  ```
- **Validierungsideen**
  - DB-Check: `jsonb_typeof(rules->'refund_tiers') = 'array'`
  - Weitere Checks optional (z. B. `jsonb_array_length` > 0).

### 2.3 Tabelle `rooms`
- **Geteilte Bookable-Felder:** `user_id`, `owner_id`, `cancellation_policy_id`, `slot_policy_id`
- **Room-spezifisch:** Bezug zu `room_offer`, Preis-/Slot-Defaults, Pending-Workflow
- Purpose: Erweiterung zu `room_offers` (bestehende Tabelle).
- **Spalten**
  - `room_offer_id:references`, `null: false`, `foreign_key: true`
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `owner_id:references`, `null: true`, `foreign_key: { to_table: :users }`
  - `region_id:string`, `null: true`
  - `cancellation_policy_id:references`, `null: true`, `foreign_key: { to_table: :bookables_cancellation_policies }`
  - `price_amount:decimal`, `precision: 10, scale: 2, null: false`, default: `0.0`
  - `status:integer`, `null: false`, default: `0` (Enum: `enabled`, `disabled`, `deleted`)
  - `created_at`, `updated_at`
- **Preislogik**
  - Standardpreis = `price_amount` pro Einheit gemäß SlotPolicy (`unit_minutes`, `min_units`, `max_units`).
  - Erweiterte Logik über `bookables_price_rules` (Rabatte, alternative Tarife).
- **Region-Sync**
  - `region_id` (String-Key) initial aus `room_offer.region_id`.
  - Bei Wechsel des `room_offer` oder dessen Region muss `room.region_id` nachgezogen werden (Callback/Service).
- **SlotPolicy**
  - Jeder Room benötigt eine `bookables_slot_policy` (enthält `unit_minutes`, `min_units`, `max_units`, `start_alignment`).
- **Templates & Feiertage**
  - Für Rooms existiert aktuell kein AvailabilityTemplate-Konzept; Zeiten/Holiday-Ausnahmen werden direkt über AvailabilityRules/Blackouts gepflegt.
- **Indizes**
  - `INDEX rooms_on_room_offer_id`
  - `INDEX rooms_on_user_id`
  - `INDEX rooms_on_owner_id`
  - `INDEX rooms_on_cancellation_policy_id`
  - `INDEX rooms_on_region_id`
- **Initialmigration**
  - Bestehende `room_offers` erhalten je einen `Room` (1:n künftig möglich).

### 2.4 Tabelle `services`
- **Geteilte Bookable-Felder:** `user_id`, `owner_id`, `cancellation_policy_id`, `availability_template_id` (zur Template-Zuordnung, immer gesetzt)
- **Service-spezifisch:** Pflicht-`location`, fixe Einheitsdauer über SlotPolicy, Ressourcen-Zuordnung
  - **Spalten**
    - `location_id:references`, `null: false`, `foreign_key: true`
    - `user_id:references`, `null: false`, `foreign_key: true`
    - `owner_id:references`, `null: true`, `foreign_key: { to_table: :users }`
    - `availability_template_id:references`, `null: false`, `foreign_key: true`
    - `cancellation_policy_id:references`, `null: true`, `foreign_key: { to_table: :bookables_cancellation_policies }`
    - `location_category_id:references`, `null: false`, `foreign_key: true`
    - `title:string`, `null: false`
    - `summary:string`, `limit: 280`, `null: false` (Kurzbeschreibung für Teaser, Pflicht)
    - `description:text`, `null: false`
    - `cover_photo_data:jsonb`, `null: false` (Shrine Attachment via `CoverImageUploader`, Pflichtfeld)
    - `slug:string`, `null: false`, `index: { unique: true }` (Friendly ID, z. B. für `/services/:slug`)
  - `region_id:string`, `null: false`
  - `price_amount:decimal`, `precision: 10, scale: 2, null: false`
  - `status:integer`, `null: false`, default: `0` (Enum: `enabled`, `disabled`, `deleted`)
  - `created_at`, `updated_at`
- **Join**: HABTM `service_resources_services` (siehe Abschnitt 6).
- **Indizes** analog zu `rooms` (inkl. `INDEX services_on_region_id`).
- **Hinweis**
  - Eine `location` kann mehrere `services` besitzen (1:n).
  - Preis ist immer Fixbetrag pro Buchung (`price_amount`), bestimmt durch SlotPolicy (`unit_minutes`, `min_units`, `max_units`).
  - Inhalt: `title`, `summary` (Pflicht, max. 280 Zeichen) und `description` bilden die Service-Darstellung. `cover_photo` ist Pflicht (Shrine `CoverImageUploader`, Speicherung in `cover_photo_data`).
  - Tags: eigener Kontext `acts_as_taggable_on :service_tags` (neuer Context, nutzt bestehende `tags`/`taggings`-Tabellen).
  - Kategorie: `location_category_id` referenziert die bestehenden `LocationCategory`-Datensätze; beim Anlegen wird standardmäßig die Kategorie der zugehörigen `location` vorbelegt, kann aber überschrieben werden.
  - Friendly URLs: `slug` via FriendlyId; Route-Vorschlag `/services/:slug`.
  - Ressourcen: MVP setzt automatisch die primäre Resource (Owner/User) – UI für Mehrfach Ressourcen folgt später.
- **Region-Sync**
  - `region_id` (String-Key, Pflicht) initial aus `location.region_id` (Location = Anbieter:innen-Profil).
  - `user_id` und `owner_id` müssen der `location.user_id` entsprechen; `owner_id` defaultet auf `user_id`.
  - Bei Wechsel der `location` oder deren Region muss `service.region_id` aktualisiert werden; Validierung stellt sicher, dass Location und Service denselben Owner/User besitzen.
- **SlotPolicy**
  - Services erhalten beim Anlegen eine SlotPolicy mit gewünschter Dauer (`unit_minutes`) und Alignment; `min_units`/`max_units` stehen dort standardmäßig auf 1.
- **Templates**
  - Jeder Service besitzt genau ein AvailabilityTemplate. MVP: simple Copy/Attach (Template anlegen oder übernehmen); Batch-Update-/Apply-Dialog folgt nachgelagert.

### 2.5 Tabelle `events`
- **Rahmen:** Event liefert Stammdaten & Defaults. Buchungen entstehen erst auf Runs/Sessions.
- **Spalten** (buchungsrelevant)
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `owner_id:references`, `null: true`, `foreign_key: { to_table: :users }`
  - `title:string`, `null: false`
  - `booking_type:integer`, `null: false`, default: `0` (`paid`, `free`)
  - `default_booking_mode:integer`, `null: false`, default: `0` (`per_run`, `per_session`)
  - `default_schedule_type:integer`, `null: false`, default: `0` (`single`, `multi`)
  - `default_capacity:integer`, optional
  - `default_price_amount:decimal`, `precision: 10, scale: 2`, optional
  - `region_id:string`, `null: false`
  - `status:integer`, `null: false`, default: `0` (Enum: `enabled`, `disabled`, `deleted`)
  - `created_at`, `updated_at`
- **Hinweise**
  - Weitere Content-/Adressfelder (Beschreibung, Medien, Adressen) werden später ergänzt bzw. via bestehende Meeting-Struktur übernommen.
  - `booking_type = free` → erzeugt `Participation` (statt `Booking`) auf Run/Session.
  - Optional: `respect_holidays`/`holiday_region` können als Default-Attribute auf dem Event gepflegt werden und bei neuen Runs vorbefüllt werden.

### 2.6 Tabelle `event_runs`
- **Geteilte Bookable-Felder:** `user_id`, `owner_id`, `cancellation_policy_id`
- **EventRun-spezifisch:** Verknüpfung zu `event`, `schedule_type`, `booking_mode`, Kapazität/Preis
- **Spalten**
  - `event_id:references`, `null: false`, `foreign_key: true`
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `owner_id:references`, `null: true`, `foreign_key: { to_table: :users }`
  - `schedule_type:integer`, default: `0` (`single`, `multi`)
    - `booking_mode:integer`, default: `0` (`per_run`, `per_session`)
    - `capacity:integer`, optional
    - `price_amount:decimal`, `precision: 10, scale: 2`
    - `cancellation_policy_id:references`, `null: true`, `foreign_key: { to_table: :bookables_cancellation_policies }`
    - `respect_holidays:boolean`, `null: false`, default: `false`
    - `holiday_region:string`
    - `region_id:string`, `null: false`
    - `starts_at:datetime`, optional (für single runs)
  - `ends_at:datetime`, optional
  - `status:integer`, `null: false`, default: `0` (Enum: `enabled`, `disabled`, `deleted`)
  - `created_at`, `updated_at`
- **Preislogik:** Betrag repräsentiert Ticketpreis pro Run (bei `per_session` dienen Sessions als buchbare Einheit).
- **Hinweise**
  - Übernimmt Defaults vom Event; `capacity`/`price_amount` können pro Run überschrieben werden.
  - Adress-/Kontaktinformationen werden über bestehende Meeting-Felder oder separate Tabellen abgebildet.
  - AvailabilityRules/Blackouts steuern die automatische Session-Generierung.
  - `respect_holidays`/`holiday_region` entscheiden, ob der Session-Generator Feiertage ausblendet; neue Runs übernehmen Defaults vom Event (optional) oder werden manuell gesetzt.
  - Es gibt kein Template-System für Events/Runs; Anpassungen erfolgen direkt am Run (Event-Defaults dienen nur als Startwerte).
  - Region-Sync: `region_id` wird beim Anlegen vom Event übernommen; ändert sich `event.region_id`, aktualisiert ein Callback die Runs.
  - `region_id` wird beim Anlegen automatisch vom Event übernommen und ermöglicht nachträgliche Region-Auswertungen ohne zusätzliche Joins.

### 2.7 Tabelle `event_sessions`
- **Geteilte Bookable-Felder:** `user_id`, `owner_id`, `cancellation_policy_id`
- **EventSession-spezifisch:** Zugehörigkeit zu `event_run`, Zeitfenster, optionale Kapazitäts-/Preis-Overrides
- **Spalten**
  - `event_run_id:references`, `null: false`, `foreign_key: true`
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `owner_id:references`, `null: true`, `foreign_key: { to_table: :users }`
  - `starts_at:datetime`, `null: false`
  - `ends_at:datetime`, `null: false`
  - `capacity_override:integer`, optional
  - `canceled:boolean`, default: `false`
  - `cancellation_policy_id:references`, `null: true`, `foreign_key: { to_table: :bookables_cancellation_policies }` (inherit oder override)
  - `price_amount:decimal`, `precision: 10, scale: 2` (falls `per_session`)
  - `region_id:string`, `null: false`
  - `status:integer`, `null: false`, default: `0` (Enum: `enabled`, `disabled`, `deleted`)
  - `created_at`, `updated_at`
- **Preislogik:** Gilt nur, wenn das Event im Modus `per_session` zahlt – dann entspricht `price_amount` dem Session-Preis.
- **Hinweise**
  - `capacity_override` erlaubt Abweichungen von `event_run.capacity` für einzelne Sessions.
  - `canceled` markiert ausgefallene Sessions, ohne sie zu löschen; `status` steuert generelle Sichtbarkeit.
  - `region_id` folgt dem Run; bei Änderungen am Run wird sie synchronisiert.
  - `region_id` bleibt mit dem übergeordneten Run synchronisiert und ermöglicht regionale Auswertungen ohne zusätzliche Joins.
- **Indizes**
  - `INDEX event_sessions_on_event_run_id`
  - `INDEX event_sessions_on_starts_at`

### 2.8 Concern-Vererbung
- Alle Bookables speichern `bookable_type`/`bookable_id` bei den abhängigen Tabellen (`bookings`, `availability_rules`, etc.).
- Bestehende Meeting-/Event-Modelle bleiben unangetastet; Migration/Mapping erfolgt optional nach Fertigstellung der neuen Struktur.

---

## 3. Buchungen & Zahlungen

### 3.1 Tabelle `bookings`
- **Spalten**
  - `bookable_type:string`, `bookable_id:bigint`, `null: false`, index (`INDEX bookings_on_bookable_type_id_starts_at`)
  - `customer_id:references`, `null: false`, `foreign_key: { to_table: :users }`
  - `owner_id:references`, `null: false`, `foreign_key: { to_table: :users }`
  - `starts_at:datetime`, `null: false`
  - `ends_at:datetime`, `null: false`
  - `quantity:integer`, `null: false`, default: `1`
  - `status:integer`, `null: false`, default: `0` (`pending`, `confirmed`, `canceled`)
  - `payment_status:string`, `null: false`, default: `"incomplete"` (`incomplete`, `authorized`, `processing`, `debited`, `disputed`, `failed`, `canceled`, `refunded`)
  - `source:integer`, `null: false`, default: `0` (`internal`, `external`)
  - `amount:decimal`, `precision: 10, scale: 2, null: false`
  - `region_id:string`, `null: false`
  - `currency:string`, `null: false`, default: `"eur"`
  - `platform_fee_amount:decimal`, `precision: 10, scale: 2, null: false`, default: `0.0`
  - `stripe_setup_intent_id:string`
  - `stripe_payment_intent_id:string`
  - `stripe_customer_id:string`
  - `stripe_payment_method_id:string`
  - `stripe_connect_account_id:string` (Kopie von `users.stripe_connect_account_id`)
  - `payment_method:string`
  - `payment_wallet:string`
  - `payment_card_last4:string`
  - `application_fee_id:string`
  - `invoice_number:string`
  - `payout_status:integer`, `null: true` (Enum: `pending`, `eligible`, `paid_out`, `recovery_pending`)
  - `debited_at:datetime`
  - `failed_at:datetime`
  - `disputed_at:datetime`
  - `dispute_status:string` (`open`, `won`, `lost`, `warning_closed`)
  - `canceled_at:datetime`
  - `confirmed_at:datetime`
  - `pending_expires_at:datetime`
  - `canceled_by:string`
  - `created_at`, `updated_at`
- **Indizes**
  - `INDEX bookings_on_customer_id`
  - `INDEX bookings_on_owner_id`
  - `INDEX bookings_on_status_pending_expires_at`
  - `INDEX bookings_on_payment_status`
  - `INDEX bookings_on_payout_status`
  - `INDEX bookings_on_bookable_type_id_starts_at`
  - `INDEX bookings_on_region_id`
- **Notizen**
  - Pending-Timeout 24h (nach `pending` erstellt, cron-job setzt `canceled_by: system`). `pending_expires_at` hilft dabei als Index (siehe oben).
  - `payment_status` folgt dem Stripe-Lifecycle (siehe CrowdPledge); Statuswechsel triggern Zeitstempel (`debited_at`, `failed_at`, `disputed_at`, `confirmed_at`).
- `confirmed_at` dokumentiert den Zeitpunkt, an dem die Buchung final bestätigt wurde (bei Rooms durch Owner-Bestätigung + Zahlung, bei Services/Events direkt nach erfolgreichem Checkout).
- `pending_expires_at` = `confirmed_at + 24h` (Rooms); der Cleanup-Job storniert offene Buchungen und setzt `canceled_by: system`, wenn dieses Limit erreicht ist.
  - `payout_status` bleibt `NULL`, bis Stripe die Zahlung als `debited` bestätigt; danach steuert die Plattform den Lifecycle (`pending` → `eligible` → `paid_out`). Bei nachträglichen Refunds nach Auszahlung wechselt der Status auf `recovery_pending`.
- `platform_fee_collection_status`: `pending` (offen), `collected` (verrechnet), `invoiced` (separat in Rechnung), `waived` (erlassen).
  - Beträge werden als Decimal gespeichert; Stripe-API erhält konvertierte Cent-Werte.
  - `invoice_number` folgt Sequenz-Logik analog `RoomRental`/`Zuckerl`.
  - `region_id` hält die Region des Bookables fest (Snapshot beim Anlegen), damit Reporting/Owner-Payouts ohne zusätzliche Joins möglich sind.

### 3.2 Tabelle `booking_slots`
- **Spalten**
  - `booking_id:references`, `null: false`, `foreign_key: true`
  - `starts_at:datetime`, `null: false`
  - `ends_at:datetime`, `null: false`
  - `created_at`, `updated_at`
- **Index**
  - `UNIQUE booking_slots_on_booking_id_starts_at`

### 3.3 Tabelle `refunds`
- **Spalten**
  - `booking_id:references`, `null: false`, `foreign_key: true`
  - `amount:decimal`, `precision: 10, scale: 2, null: false`
  - `platform_fee_amount:decimal`, `precision: 10, scale: 2, null: false`, default: `0.0`
  - `stripe_refund_id:string`
  - `refunded_at:datetime`, `null: false`
  - `canceled_by:string`, `null: false`, default: `"customer"`
  - `platform_fee_collection_status:integer`, `null: false`, default: `0` (`pending`, `collected`, `invoiced`, `waived`)
  - `region_id:string`, `null: false`
  - `created_at`, `updated_at`
- **Index**
  - `INDEX refunds_on_booking_id`
- **Hinweise**
  - Jeder Storno (auch Teil-Refund) wird als eigener Datensatz erfasst – das erleichtert Reporting, Mehrfach-Refunds und die Nachverfolgung (`canceled_by`, `platform_fee_collection_status`).
  - `platform_fee_amount` spiegelt die 5 %-Gebühr für den Refund wider und fließt über `owner_payout_items` in die nächste Abrechnung ein (auch wenn keine Auszahlung geplant war).
  - `region_id` wird vom ursprünglichen Booking übernommen, damit Refunds regional ausgewertet werden können.
  - `amount` und `platform_fee_amount` werden immer als positive Werte gespeichert; die Gegenbuchung erfolgt später über Owner-Payout-Items (dort ggf. mit negativen Beträgen).

### 3.4 Tabelle `participations`
- Für freie Events (kein Payment).
- **Spalten**
  - `participatable_type:string`, `participatable_id:bigint`, `null: false` (`EventRun` oder `EventSession`)
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `status:integer`, default: `0` (`attending`, `canceled`)
  - `created_at`, `updated_at`
- **Index**
  - `UNIQUE participations_on_user_and_participatable`

### 3.5 Tabelle `owner_payouts`
- **Spalten**
  - `user_id:references`, `null: false`, `foreign_key: true` (Owner)
  - `period_start:date`, `null: false`
  - `period_end:date`, `null: false`
  - `earnings_amount:decimal`, `precision: 10, scale: 2, null: false`, default: `0.0`
  - `refunds_amount:decimal`, `precision: 10, scale: 2, null: false`, default: `0.0`
  - `platform_fees_amount:decimal`, `precision: 10, scale: 2, null: false`, default: `0.0`
  - `transfer_amount:decimal`, `precision: 10, scale: 2, null: false`, default: `0.0`
  - `transfer_status:string`, `null: false`, default: `payout_ready` (`payout_ready`, `payout_processing`, `payout_completed`, `payout_failed`, `payout_waived`)
  - `region_id:string`, `null: false`
  - `payout_attempted_at:datetime`
  - `payout_completed_at:datetime`
  - `payout_waived_at:datetime`
  - `stripe_transfer_id:string`
  - `created_at`, `updated_at`
- **Index**
  - `UNIQUE owner_payouts_on_user_period`
- **Hinweise**
  - `transfer_status`: `payout_ready` → `payout_processing` → `payout_completed`; `payout_failed` für Fehlversuche, `payout_waived` bei erlassener Payout-Abwicklung.
  - Monatslauf erzeugt zunächst eine Übersicht (Status `payout_ready`). Im Admin-Tool können fällige Auszahlungen ausgewählt und angestoßen werden; einzelne Einträge lassen sich als `payout_waived` markieren oder für den nächsten Lauf stehen lassen.
  - Buchungen, die einem `owner_payout` zugeordnet wurden, behalten den Status `paid_out` – auch wenn der Payout auf `payout_waived` gesetzt wird. Die Verknüpfung dient als Audit-Trail dafür, warum die Auszahlung nicht überwiesen wurde.
  - `region_id` spiegelt die Region der enthaltenen Buchungen; Owner-Payouts werden damit pro Region auswertbar.
  - `payout_attempted_at` dokumentiert den Start der Überweisung, `payout_completed_at` den Stripe-Erfolg, `payout_waived_at` bewusst erlassene Auszahlungen.

### 3.6 Tabelle `owner_payout_items`
- **Zweck:** Verknüpft einzelne Buchungen (`bookings`) mit einem `owner_payout` und dokumentiert die verrechneten Beträge (inkl. negativer Gegenbuchungen bei Refunds).
- **Spalten**
  - `owner_payout_id:references`, `null: false`, `foreign_key: true`
  - `booking_id:references`, `null: false`, `foreign_key: true`
  - `booking_amount:decimal`, `precision: 10, scale: 2`, `null: false` (Bruttobetrag der Buchung, inkl. Mehrwertsteuer falls relevant)
  - `platform_fee_amount:decimal`, `precision: 10, scale: 2`, `null: false`, default: `0.0`
  - `refund_amount:decimal`, `precision: 10, scale: 2`, `null: false`, default: `0.0` (positive Werte bilden Gegenbuchungen ab)
  - `region_id:string`, `null: false`
  - `created_at`, `updated_at`
- **Index**
  - `UNIQUE owner_payout_items_on_owner_payout_booking`
- **Hinweise**
  - Buchungen können einmalig einem `owner_payout` zugeordnet werden. Entfernt die Plattform einen Eintrag, wechselt die entsprechende Buchung zurück auf `payout_status = eligible` und erscheint im nächsten Lauf erneut.
  - Für negative Gegenbuchungen (z. B. `recovery_pending`) wird `booking_amount` negativ oder `refund_amount` positiv gesetzt – je nachdem, wie der Aggregationsjob summiert. Wichtig ist die klare Dokumentation des Nettoeffekts pro Booking.
  - `region_id` bleibt mit der zugehörigen Buchung synchron und erlaubt Region-Reporting auf Item-Ebene.

---

## 4. Verfügbarkeit & Templates

### 4.1 Tabelle `availability_templates`
- **Spalten**
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `name:string`, `null: false`
  - `scope:integer`, `null: false`, default: `0` (`service`)
  - `respect_holidays:boolean`, default: `false`
  - `holiday_region:string`
  - `archived:boolean`, default: `false`
  - `created_at`, `updated_at`
- **Index**
  - `UNIQUE availability_templates_on_user_name_scope`
- **Hinweis**
  - Aktuell werden Templates nur für Services eingesetzt; ein Room-Scope kann später ergänzt werden.

### 4.2 Tabelle `availability_template_rules`
- **Spalten**
  - `availability_template_id:references`, `null: false`, `foreign_key: true`
  - `rrule:string`, `null: false`
  - `start_time:time`, `end_time:time`, `null: false`
  - `enabled:boolean`, default: `true`
  - `created_at`, `updated_at`
- **Index**
  - `INDEX availability_template_rules_on_template`

### 4.3 Tabelle `bookables_availability_rules`
- **Spalten**
  - `bookable_type:string`, `bookable_id:bigint`, `null: false`
  - `rrule:string`, `null: false`
  - `start_time:time`, `end_time:time`, `null: false`
  - `enabled:boolean`, default: `true`
  - `created_at`, `updated_at`
- **Indices**
  - `INDEX availability_rules_on_bookable`

### 4.4 Tabelle `bookables_blackouts`
- **Spalten**
  - `bookable_type:string`, `bookable_id:bigint`, `null: false`
  - `starts_at:datetime`, `null: false`
  - `ends_at:datetime`, `null: false`
  - `reason:string`
  - `created_at`, `updated_at`
- **Index**
  - `INDEX blackouts_on_bookable`

### 4.5 Tabelle `bookables_provider_blackouts`
- **Spalten**
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `starts_at:datetime`, `null: false`
  - `ends_at:datetime`, `null: false`
  - `reason:string`
  - `created_at`, `updated_at`
- **Index**
  - `INDEX provider_blackouts_on_user`

### 4.6 Tabelle `bookables_resource_blackouts`
- **Spalten**
  - `service_resource_id:references`, `null: false`, `foreign_key: true`
  - `starts_at:datetime`, `null: false`
  - `ends_at:datetime`, `null: false`
  - `reason:string`
  - `created_at`, `updated_at`
- **Index**
  - `INDEX resource_blackouts_on_resource`

### 4.7 Tabelle `bookables_slot_policies`
- **Spalten**
  - `bookable_type:string`, `bookable_id:bigint`, `null: false`
  - `unit_minutes:integer`, `null: false`
  - `min_units:integer`, `null: false`, default: `1`
  - `max_units:integer`, `null: false`, default: `1`
  - `start_alignment:string`, `null: false`, default: `"on_hour"` (Enum: `on_hour`, `half_hour`, `quarter`)
  - `created_at`, `updated_at`
- **Index**
  - `UNIQUE slot_policies_on_bookable`

### 4.8 Tabelle `bookables_price_rules`
- **Spalten**
  - `bookable_type:string`, `bookable_id:bigint`, `null: false`
  - `strategy:string`, `null: false`, default: `"per_unit_rate"` (Enum: `per_unit_rate`, `quantity_discount`)
  - `unit_minutes:integer`
  - `amount:decimal`, `precision: 10, scale: 2`
  - `days_of_week:integer[]`
  - `time_from:time`, `time_to:time`
  - `date_from:date`, `date_to:date`
  - `metadata:jsonb`, default: `{}`
  - `created_at`, `updated_at`
- **Index**
  - `INDEX price_rules_on_bookable`
- **Strategien & Beispiele**
  - `per_unit_rate`: Überschreibt `price_amount` für den gefilterten Zeitraum. Beispiel: `days_of_week: [0,6]`, `amount: 150` → Wochenendpreis pro Einheit 150 €.
  - `quantity_discount`: Rabatte ab bestimmter Dauer/Menge. `metadata` enthält z. B. `{ "min_units": 16, "discount_percent": 20 }` (ab 4 Stunden 20 % Rabatt). Weitere Stufen durch mehrere Rules. Der Rabatt wird auf den aktuell gültigen Preis angewendet (Basispreis oder eine zuvor greifende `per_unit_rate`).
- **Filter**
  - `days_of_week`: 0–6 (Sonntag–Samstag).
  - `time_from/time_to`: Tageszeitfenster (z. B. 18:00–23:00).
  - `date_from/date_to`: Saisonale Preise.
  - `unit_minutes`: abweichende Slot-Größe für eine Regel (optional).
  - `metadata`: Freiform, u. a. für `min_units`, `discount_percent`, `max_units` oder `amount_override`.
- **Priorisierung**
  - Resolver prüft spezifische Regeln zuerst (z. B. `quantity_discount` bei erfüllter Mindestdauer), danach `per_unit_rate`. Bei mehreren passenden Regeln entscheidet die engste Filterung (z. B. spezifischer Tag/Zeitraum schlägt nur Wochentag).
- **Initialausbaustufe**
  - Start schlank: mindestens Standardpreis (`price_amount`) ohne PriceRule muss funktionieren; PriceRules optional. Release 1 liefert ausschließlich `per_unit_rate` (z. B. Wochenendpreise); `quantity_discount` folgt nach dem ersten Live-Gang.
- **Pflicht?** PriceRules sind optional. Ohne Eintrag gilt `price_amount` und SlotPolicy-Restriktionen.

---

## 5. Ressourcen & Zuweisungen

### 5.1 Tabelle `service_resources`
- **Spalten**
  - `user_id:references`, `null: false`, `foreign_key: true`
  - `name:string`, `null: false`
  - `bio:text`
  - `avatar_id:references`, `null: true`, `foreign_key: true`
  - `created_at`, `updated_at`

### 5.2 Join-Tabelle `service_resources_services`
- **Spalten**
  - `service_resource_id:references`, `null: false`, `foreign_key: true`
  - `service_id:references`, `null: false`, `foreign_key: true`
- **Index**
  - `UNIQUE index_service_resources_services_on_service_resource_service`

---

## 6. Hintergrundprozesse & Jobs
- `EventSessionGeneratorJob` → benötigt Zugriff auf `event_runs`, `bookables_availability_rules`, `bookables_blackouts`.
- `BookingPendingCleanupJob` → filtert `bookings.status = pending` und `created_at < 24h`.
- `OwnerPayoutJob` → aggregiert Buchungen mit `payout_status = eligible` (bzw. `recovery_pending` für Gegenbuchungen), erzeugt `owner_payouts`, setzt verarbeitete Buchungen auf `paid_out` und verschiebt `refunds.platform_fee_collection_status`.

---

## 7. Seeds & Initialdaten
- `bookables_cancellation_policies`: 9 Einträge.
- Optional: `availability_templates` Demo-Daten (nur für Tests).
- Stripe-Bezogene Felder über env (`platform_fee_percent = 5` in Code).

---

## 8. Folgeaufgaben
1. **Room-Migration:** initial pro `room_offer` einen `Room` erzeugen und Daten übertragen; spätere Bereinigung redundanter Felder in `room_offers`.
2. **Service-Locations:** Validierungen/Seeds anpassen, damit jede `location` mehrere `services` führen kann.
3. **Event-Mapping:** Entscheiden, ob/wie bestehende Meeting-Daten in das neue Event/Run/Session-Gerüst migriert werden.
4. **Invoice-Sequenzen:** Mechanismus für `bookings.invoice_number` definieren (ähnlich `RoomRental.next_invoice_number`) und Stripe-`invoice_id`-Handling spezifizieren.
5. **Delete-Strategie:** Prüfen, ob zusätzliche Status (`disabled`, `deleted`) oder `deleted_at`-Felder eingeführt werden sollen und wie sie mit bestehenden Enabled/Disabled-Flags interagieren.
6. **Region-Felder:** Migrationen für `rooms.region_id`/`services.region_id` implementieren; Event-Region bei Bedarf später ableiten (z. B. über Meetings/Adressen).

---

_Stand: 2025-10-31_
