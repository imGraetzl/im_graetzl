# Bookables Overview – Beschreibung

## Überblick

Das Buchungssystem basiert auf vier Typen von buchbaren Einheiten (**Bookables**):

* **Room**
* **Service**
* **EventRun**
* **EventSession**

Alle teilen gemeinsame Logik über das Concern **`Bookable`**, das Kernfunktionen wie Eigentümer:in, Preis- und Zeitregeln, Stornierungsbedingungen und Buchungen verwaltet.

---

## Gemeinsame Logik (Concern `Bookable`)

**Bookable** stellt die Basisfunktionen für alle buchbaren Modelle bereit:

* `belongs_to :user` (Owner)
* `belongs_to :cancellation_policy, optional: true`
* `has_many :bookings, as: :bookable`
* `has_many :availability_rules, as: :bookable`
* `has_many :blackouts, as: :bookable`
* `has_one :slot_policy, as: :bookable`
* `has_many :price_rules, as: :bookable`
* `owner_id` spiegelt den technischen Owner und defaultet automatisch auf `user_id`

### Funktionen

* **Verfügbarkeit:** Gesteuert über `AvailabilityRules` und `Blackouts`.
* **Stornierungen:** Automatisch über `CancellationPolicy` → Refund-Berechnung via Policy-Regeln.
* **Refunds:** Erfolgen über `Booking#cancel!`, werden als separate `Refund`-Records gespeichert.

---

## Room

* `belongs_to :room_offer`
* `region_id` (String-Key) für Region-Scoping
* Repräsentiert einen Raum (z. B. Seminarraum, Atelier).

**Verfügbarkeit**

* Definiert über **AvailabilityRules** und **Blackouts**.
* Start-Ausrichtung: volle, halbe oder viertel Stunde.
* **SlotPolicy** bestimmt Buchungseinheiten (z. B. 30/60 Minuten), Mindest-/Maximalanzahl und Alignment.
* Feiertage werden aktuell nicht automatisch berücksichtigt; nur explizite Blackouts schließen Zeiträume aus.

**Preislogik**

* Standardpreis `price_amount` pro Slot laut SlotPolicy.
* Optionale `Bookables::PriceRules` (z. B. `per_unit_rate` für Wochenenden, `quantity_discount` ab 4/8 Stunden).

**Stornierung**

* Verknüpft mit einer festen **CancellationPolicy** (`*_low`, `*_medium`, `*_high`) je nach Buchungstyp.  
* Refunds und die 5 % Plattformgebühr werden automatisch gemäß Policy und über Stripe abgewickelt.

---

## Service

* `belongs_to :location`
* `region_id` (String-Key) übernimmt Region des Locations-Profils
* Repräsentiert eine Dienstleistung (z. B. Massage, Coaching, Training).
* Jeder Service ist mit exakt einem AvailabilityTemplate verknüpft (Vorlagepflicht, ermöglicht Batch-Änderungen & Feiertags-Settings).

**Verfügbarkeit**

* Feste Einheitsdauer über SlotPolicy (`unit_minutes`, `min/max_units = 1`).
* Start-Ausrichtung: volle, halbe oder viertel Stunde.
* Regeln über **AvailabilityRules** und **Blackouts**.
* Feiertags-Handling erfolgt über das verknüpfte AvailabilityTemplate (`respect_holidays`, `holiday_region`).

**Exklusivität**

* Eine `ServiceResource` (z. B. Therapeut:in) darf pro Zeitraum nur eine aktive Buchung haben.

**Preislogik**

* Fixpreis `price_amount` pro Buchung.
* Optionale `Bookables::PriceRules` für zeitabhängige Tarife oder Rabatte.

**Stornierung**

* Verknüpft mit einer **CancellationPolicy** (service_low, service_medium, service_high).
* Refunds werden über Stripe automatisch abgewickelt.

---

## Event-Struktur

### Event

* Repräsentiert das **Angebot** (z. B. „Fotokurs“, „Yoga“).
* **Nicht direkt buchbar.**
* Hält Default-Einstellungen für Runs/Sessions:
  - `booking_type: paid | free`
  - `default_booking_mode: per_run | per_session`
  - `default_schedule_type: single | multi`
  - `default_capacity`, `default_price_amount` (optional)
* Weitere Content-/Adressfelder folgen außerhalb des Buchungsschemas.

### EventRun

* Konkrete Durchführung eines Events (z. B. „Yoga Dienstag 18:00“).
* `booking_mode: per_run | per_session` legt fest, ob der Run selbst oder seine Sessions buchbar sind.
* **schedule_type:** single oder multi.
* **Verfügbarkeit:** über AvailabilityRules + Blackouts.
* Feiertage blendet der Session-Generator aus, wenn `event_run.respect_holidays = true` (Region via `holiday_region`, optional Defaults am Event).
* Kein Template-System: Anpassungen erfolgen direkt am Run (oder via Event-Defaults beim Anlegen neuer Runs).
* **Stornierung:** optional eigene `cancellation_policy_id`.
* Kann Kapazität und Preis vom Event überschreiben.
* Adressen/Ort werden separat verwaltet (Meeting-Felder).

**Preis & Refunds:**

* Bei `paid + per_run`: Buchung direkt am Run → Refund gemäß Policy.
* Bei `free + per_run`: Teilnahme (Participation) ohne Refund.

### EventSession

* Einzeltermin innerhalb eines Runs.
* Felder: `starts_at`, `ends_at`, `canceled`, `capacity_override`.
* `include Bookable` (wenn `paid + per_session`).
* `price_amount` wird nur genutzt, wenn Sessions buchbar sind.
* Für Kalender & Attendance wird selbst bei `per_run` mindestens eine Session empfohlen.

**Rollenabhängig:**

* `paid + per_session`: buchbar (Booking).
* `free + per_session`: teilnehmbar (Participation, kein Refund).

---

## Booking

* `belongs_to :bookable, polymorphic: true`
* `belongs_to :customer, class_name: 'User'`
* `has_many :refunds, dependent: :destroy`

**Enums:**

* `status: pending, confirmed, canceled`
* `payment_status: incomplete, authorized, processing, debited, disputed, failed, canceled, refunded`

**Wichtige Felder:**

* `starts_at`, `ends_at`
* `amount`
* `platform_fee_amount` – Plattformgebühr (5 %)
* Stripe-IDs: `stripe_setup_intent_id`, `stripe_payment_intent_id`, `stripe_customer_id`, `stripe_payment_method_id`, `connect_account_id`, `application_fee_id`
* Payment-Metadaten: `payment_method`, `payment_wallet`, `payment_card_last4`
* `region_id` – Region des Bookables zum Buchungszeitpunkt
* `payout_status` – steuert monatliche Auszahlungen (`nil` solange Zahlung nicht `debited`, danach `pending`, `eligible`, `paid_out`, `recovery_pending`)
  - `nil` → Stripe-Zahlung noch nicht final belastet
  - `pending` → Zahlung debited, Leistung offen
  - `eligible` → Leistung fertig, wartet auf Auszahlungsjob
  - `paid_out` → Auszahlung durchgeführt
  - `recovery_pending` → Nachforderung nach bereits erfolgter Auszahlung
* Zusätzliche Timestamps: `confirmed_at` (finale Bestätigung), `pending_expires_at` (Timeout für Rooms), `debited_at`, `failed_at`, `disputed_at`, `refunded_at`

**Methoden:**

* `cancel!(by:, reason: nil)`  
  → Automatische Refund-Logik über Stripe gemäß `CancellationPolicy`.  
  Erstellt `Refund`-Datensatz mit Betrag, Stripe-Refund-ID, Zeitstempel und Feldern `platform_fee_amount`, `canceled_by` und `platform_fee_collection_status`.
* Verknüpfung zu Owner-Payouts: `has_many :owner_payout_items` dokumentiert, in welcher Auszahlung (inkl. Gegenbuchungen) die Buchung berücksichtigt wurde.

### Externe Buchungen

* Anbieter:innen können manuell Buchungen erfassen, die **außerhalb der Plattform** zustande gekommen sind (z. B. telefonisch, per E-Mail, eigene Website).  
* Diese Buchungen werden im System als `source: external` gespeichert.  
* Sie erzeugen keine Stripe-Zahlung und keine Refunds, blockieren aber den Zeitraum für neue Buchungen.  
* Status = `confirmed`, `payment_status` bleibt z. B. `incomplete` (keine Stripe-Abwicklung).  
* In der Monatsabrechnung werden sie nicht berücksichtigt.

---

## Refund

* `belongs_to :booking`
* Speichert Rückzahlungen bei Stornos.

**Felder:**

* `amount`
* `stripe_refund_id`
* `refunded_at`
* `platform_fee_amount` – Plattformgebühr (5 %), die bei jeder Stornierung berechnet und in der Monatsabrechnung verrechnet wird
* `canceled_by` – Ursprung der Stornierung (`customer`, `provider`, `system`)
* `platform_fee_collection_status` – Status der Gebühr (`pending`, `collected`, `invoiced`, `waived`)

**Zweck:**

* Trennung von Zahlungs- und Buchungsdaten  
* Ermöglicht Mehrfach-Refunds und klare Historie  
* Grundlage für Monatsabrechnungen und Auswertungen
* Plattformgebühr (5 %) wird für alle Stornos zentral verrechnet und ausgewiesen.

---

## Participation

* Wird bei kostenlosen Events (`booking_type = free`) verwendet.
* `belongs_to :user`
* `belongs_to :participatable, polymorphic: true`
* `enum status: { attending: 0, canceled: 1 }`
* Kein Zahlungs- oder Refund-Handling.

---

## Bookables::CancellationPolicy

* `has_many :rooms, :services, :event_runs, :event_sessions`
* Definiert **neun feste Policies** (Low / Medium / High je Typ):

  * `service_low`, `service_medium`, `service_high`
  * `event_low`, `event_medium`, `event_high`
  * `room_low`, `room_medium`, `room_high`

**Kurzbeschreibung:**
* **Low:** Immer kostenlos stornierbar (100 % Refund).  
* **Medium:** Bis 24 h kostenlos, danach 80 % Refund (Services/Events) bzw. 0 % Refund (Rooms).  
* **High:** Bis 48 h (Services/Events) bzw. 72 h (Rooms) kostenlos, danach 80 % / 0 % Refund.  
* Anbieter:innen zahlen bei Stornos oder Kunden-Stornos jeweils **5 % Plattformgebühr**.

**Verwendung:**

* Wird automatisch bei jeder Buchung angewendet.
* Refund-Berechnung erfolgt dynamisch über `Booking#cancel!`.

---

## Availability & Blackouts

**Verfügbarkeit:**

* Regeln über `Bookables::AvailabilityRule` (wiederkehrende Zeiten)
* Sperrzeiten über `Bookables::Blackout`
* Feiertage und Abwesenheiten über `ProviderBlackout` / `ResourceBlackout`

**Weitere Infos:** siehe [`availability.md`](availability.md)

---

## Hintergrundprozesse

### EventSessionGeneratorJob

* Generiert automatisch `EventSessions` für `EventRuns` mit aktiven AvailabilityRules.
* Läuft regelmäßig (täglich).
* Beachtet Blackouts und markiert betroffene Sessions als `canceled`.

---

## Zusammenhang

| Bereich                 | Zweck                                      |
| ----------------------- | ------------------------------------------ |
| `bookables_overview.md` | Überblick und Domain-Struktur              |
| `models.md`             | Technische Modellbeschreibung              |
| `availability.md`       | Regeln zur Verfügbarkeit und Abwesenheiten |
| `cancellation.md`       | Stornobedingungen und Refund-Logik         |
