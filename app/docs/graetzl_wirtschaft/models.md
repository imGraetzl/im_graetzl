# Models Übersicht – Buchungssystem

## 📂 Alphabetische Übersicht (Projektstruktur)

### Root (`app/models/`)

* booking.rb → `Booking`
* booking_slot.rb → `BookingSlot`
* event.rb → `Event`
* event_run.rb → `EventRun`
* event_session.rb → `EventSession`
* participation.rb → `Participation`
* refund.rb → `Refund`
* room.rb → `Room`
* service.rb → `Service`
* service_resource.rb → `ServiceResource`
* availability_template.rb → `AvailabilityTemplate`
* availability_template_rule.rb → `AvailabilityTemplateRule`

### Concerns (`app/models/concerns/`)

* bookable.rb → `Bookable` (Concern für alle buchbaren Typen)

### Bookables (`app/models/bookables/`)

* availability_rule.rb → `Bookables::AvailabilityRule`
* blackout.rb → `Bookables::Blackout`
* cancellation_policy.rb → `Bookables::CancellationPolicy`
* price_rule.rb → `Bookables::PriceRule`
* slot_policy.rb → `Bookables::SlotPolicy`
* provider_blackout.rb → `Bookables::ProviderBlackout`
* resource_blackout.rb → `Bookables::ResourceBlackout`

---

## 📑 Modelle im Detail

### 🧑‍🤝‍🧑 Owner & Customer

* **Owner** → `belongs_to :owner, class_name: "User"`

  * Definiert die Anbieter:in (Besitzer:in) eines Bookables (Room, Service, EventRun, EventSession).
  * Standardmäßig identisch mit `user`; beim Speichern übernimmt das Modell automatisch `owner_id ||= user_id`.

* **Customer** → `belongs_to :customer, class_name: "User"`

  * Definiert die buchende oder teilnehmende Person.
  * Wird in `Booking` (und implizit bei `Participation`) verwendet, um die Kund:innen eindeutig zu identifizieren.

---

### Event

* `belongs_to :user`
* `has_many :event_runs, dependent: :destroy`
* `enum booking_type: { paid: 0, free: 1 }`
* Nicht direkt buchbar
* Buchungsrelevante Felder:

  * Default-Parameter für Runs: `default_booking_mode`, `default_schedule_type`, `default_capacity`, `default_price_amount`
  * Optional: Default-Flags `respect_holidays`, `holiday_region` (werden bei neuen Runs übernommen)
  * `region_id` (String-Key) – Pflichtfeld, bestimmt Region für Runs/Sessions und nachgelagerte Auswertungen
  * Status-Enum (`enabled`, `disabled`, `deleted`)
* Content-/Adressangaben (Beschreibung, Medien, Adressen) werden später ergänzt bzw. aus bestehenden Meeting-Strukturen übernommen.

### EventRun

* `include Bookable` (wirksam, wenn Event `paid` und `booking_mode = per_run`)
* `belongs_to :event`
* `has_many :event_sessions, dependent: :destroy`
* `enum schedule_type: { single: 0, multi: 1 }`
* `enum booking_mode: { per_run: 0, per_session: 1 }`
* Eigenschaften:

  * capacity, price_amount
  * respect_holidays, holiday_region (steuern Session-Generator)
  * cancellation_policy_id (optional)
  * region_id (wird beim Anlegen vom Event übernommen)
  * Overrides: title, description, image, Kapazität (weitere Content-/Adressangaben folgen später)
* Buch-/Teilnahme-Logik:

  * `paid + per_run` → Bookings am Run
  * `paid + per_session` → Bookings an Sessions
  * `free + per_run` → Participations am Run
  * `free + per_session` → Participations an Sessions
* Verfügbarkeit:

  * `has_many :availability_rules, as: :bookable`
  * `has_many :blackouts, as: :bookable`
  * Standardmäßig übernimmt der Run die Holiday-Defaults vom Event; Änderungen sind pro Run möglich.
  * Kein Template-System – Anpassungen erfolgen direkt am Run.

### EventSession

* `belongs_to :event_run`
* `include Bookable` (nur relevant, wenn Event `paid` und `booking_mode = per_session`)
* Felder:

  * starts_at, ends_at
  * capacity_override (optional)
  * canceled (boolean)
  * region_id (übernimmt Wert vom EventRun)
* Rolle:

  * paid/per_run → Kalenderdarstellung
  * paid/per_session → buchbare Einheit
  * free/per_run → Kalenderdarstellung, Teilnahmen am Run
  * free/per_session → teilnehmbare Einheit (Participation)

---

### Booking

* `belongs_to :bookable, polymorphic: true` (Room, Service, EventRun, EventSession)
* `belongs_to :customer, class_name: "User"`
* `has_many :booking_slots, dependent: :destroy`
* `has_many :refunds, dependent: :destroy`
* Enums:

  * status: pending, confirmed, canceled
  * payment_status: incomplete, authorized, processing, debited, disputed, failed, canceled, refunded
  * source: internal, external
* Felder:

  * starts_at, ends_at
  * quantity
  * amount
  * platform_fee_amount: decimal (Plattformgebühr 5 %, wird bei der Zahlung gesetzt)
  * stripe_setup_intent_id, stripe_payment_intent_id, stripe_customer_id, stripe_payment_method_id, stripe_connect_account_id
  * payment_method, payment_wallet, payment_card_last4
  * application_fee_id, invoice_number
  * region_id: string (Region des Bookables zum Zeitpunkt der Buchung)
  * confirmed_at, pending_expires_at
  * payout_status (enum: pending, eligible, paid_out, recovery_pending) – bleibt `nil`, bis `payment_status` `debited` erreicht  
    - `nil` → Stripe-Zahlung noch nicht final belastet  
    - `pending` → Zahlung debited, Leistung noch offen  
    - `eligible` → Leistung abgeschlossen, wartet auf Auszahlungsjob  
    - `paid_out` → Auszahlung durchgeführt  
    - `recovery_pending` → Nachforderung nach bereits erfolgter Auszahlung (Refund/Dispute)
  * `has_many :owner_payout_items` (optional) – listet die Abrechnungseinträge, in denen die Buchung aufscheint
  * debited_at, failed_at, disputed_at
  * dispute_status (open, won, lost, warning_closed)
* Methoden:

  * `cancel!(by:, reason: nil)` → setzt Status, Refund über Stripe, speichert Refund-Datensatz inklusive `platform_fee_amount` und `canceled_by`
  * **Externe Buchungen:**  
    - Können manuell vom Anbieter angelegt werden (`source: external`).  
    - Haben kein Stripe-Payment (`payment_status = unpaid`) und keine Refund-Logik.  
    - Blockieren den Zeitraum identisch wie reguläre Buchungen.  
    - Werden in der Abrechnung **nicht berücksichtigt**.

---

### Refund

* `belongs_to :booking`
* Felder:

  * amount: decimal
  * stripe_refund_id: string
  * refunded_at: datetime
  * platform_fee_amount: decimal (5 % Plattformgebühr, bei jeder Stornierung)
  * canceled_by: string (`customer`, `provider`, `system`)
  * platform_fee_collection_status: string (`pending`, `collected`, `invoiced`, `payout_waived`)
  * region_id: string (übernimmt Region des Bookings)
* Zweck:

  * Speichert Rückzahlungen bei Stornos inkl. der fälligen Plattformgebühr (5 %).
  * Automatisch durch `Booking#cancel!` erzeugt
  * Enthält alle Infos zur Herkunft der Stornierung.
  * Dient als Grundlage für Monatsabrechnungen
  * Beträge werden immer positiv gespeichert; die Gegenbuchung erfolgt über Owner-Payout-Items.

---

### OwnerPayout

* `belongs_to :user` (Anbieter:in)
* `has_many :owner_payout_items, dependent: :destroy`
* Felder:

  * earnings_amount, refunds_amount, platform_fees_amount, transfer_amount
  * period_start, period_end
  * transfer_status: payout_ready, payout_processing, payout_completed, payout_failed, payout_waived
  * region_id: string (Region, für die der Payout erstellt wurde)
  * payout_attempted_at, payout_completed_at, payout_waived_at
  * stripe_transfer_id
* Zweck:

  * Bündelt die für einen Owner fälligen Auszahlungen pro Zeitraum.
  * Dient als Grundlage für den Payout-Job (Aggregation, Transfer, Fehlerhandling).
  * Status `payout_waived` dokumentiert bewusst zurückgestellte Auszahlungen; die verknüpften `owner_payout_items` bleiben erhalten und die zugehörigen Buchungen behalten `payout_status = paid_out`.

### OwnerPayoutItem

* `belongs_to :owner_payout`
* `belongs_to :booking`
* Felder:
  * booking_amount, platform_fee_amount, refund_amount
  * region_id: string
* Zweck:
  * Dokumentiert, welche Buchungen (inkl. Gegenbuchungen) in einem Owner-Payout verarbeitet wurden.
  * Entfernt die Plattform ein Item, wird `booking.payout_status` wieder auf `eligible` gesetzt.
  * `booking_amount` und `platform_fee_amount` sind positiv für Auszahlungen und negativ für Gegenbuchungen; `refund_amount` wird nur mit positiven Werten befüllt.

---

### Participation

* `belongs_to :user`
* `belongs_to :participatable, polymorphic: true` (EventRun oder EventSession)
* `enum status: { attending: 0, canceled: 1 }`
* Felder: created_at, updated_at

### BookingSlot

* `belongs_to :booking`
* Felder: starts_at, ends_at

---

### Room

* `include Bookable`
* `belongs_to :room_offer`
* `region_id` (String-Key)

**Verfügbarkeit:**
* SlotPolicy: `unit_minutes` (z. B. 30/60), `min_units/max_units`
* Start-Ausrichtung: volle, halbe oder viertel Stunde
* AvailabilityRules + Blackouts
* Pending-Reservierungen blockieren Zeiträume für 24 h nach Annahme einer Buchungsanfrage (siehe Payment-/Availability-Logik).
* Feiertage/Template-Unterstützung: noch nicht vorhanden; Ausnahmen ausschließlich über Blackouts.

**Preislogik:**
* Standardpreis `price_amount` pro Slot.
* Optionale `Bookables::PriceRules` (Wochenendtarife, Mengenrabatte).

**Buchungs- und Zahlungsablauf:**
* Kund:in stellt Buchungsanfrage → Anbieter:in nimmt an → Payment-Link (24 h gültig).  
* Während dieser Zeit: Buchung = `pending`, Zeitraum blockiert (nicht erneut buchbar).  
* Zahlung innerhalb 24 h → Buchung fixiert (`confirmed`).  
* Keine Zahlung → Reservierung verfällt, Status `canceled` via `Booking#cancel!(by: :system)`.

**Stornierung:**
* `belongs_to :cancellation_policy, optional: true`
* Refunds und die 5 % Plattformgebühr werden automatisch gemäß der zugewiesenen Cancellation Policy berechnet.

### Service

* `include Bookable`
* `belongs_to :location`
* `region_id` (String-Key)
* `has_and_belongs_to_many :service_resources`
* `belongs_to :availability_template`
  * Vorlage hält `respect_holidays`/`holiday_region` und wird pro Service verpflichtend gepflegt.
* **Content & Klassifikation**
  * Felder: `title` (Pflicht), `summary` (Pflicht, Kurztext bis 280 Zeichen), `description` (Langtext)
  * `cover_photo` via `CoverImageUploader` (`cover_photo_data`, Pflicht)
  * FriendlyId (`slug`) für SEO-/Widget-URLs (`/services/:slug`)
  * `acts_as_taggable_on :service_tags` – eigener Kontext für Services (Tag-/Tagging-Tabellen bereits vorhanden)
  * `belongs_to :location_category` – Standardwert aus der zugeordneten `location`, kann angepasst werden
* Verfügbarkeit:

  * Feste Einheitsdauer via SlotPolicy (`unit_minutes`, `min/max_units = 1`)
  * Start-Ausrichtung: volle, halbe oder viertel Stunde (SlotPolicy)
  * AvailabilityRules + Blackouts
* Buchung:

  * Pro Booking nur **eine** Einheit
  * Services sind direkt buchbar; Zahlung erfolgt sofort (Stripe Checkout). Gastbuchungen erlaubt (Customer ohne Registrierung).
* Preislogik:

  * Fixpreis pro Buchung (`price_amount`), optional PriceRules
* Exklusivität:

  * **Hard Rule:** Eine `ServiceResource` darf pro Zeitraum nur eine aktive Buchung haben.
  * MVP: fixe Zuordnung zur primären Resource (Owner/Nutzer); spätere Erweiterung für manuelle Mehrfach-Ressourcen-Auswahl möglich.
* Stornierung:

  * `belongs_to :cancellation_policy, optional: true`
  * Refunds und die 5 % Plattformgebühr werden automatisch gemäß der Cancellation Policy berechnet.

### ServiceResource

* `belongs_to :user` (Anbieter oder Mitarbeiter:in)
* `has_and_belongs_to_many :services`

---

## 📑 Bookables – gemeinsame Hilfstabellen

Alle Models im Namespace `Bookables::…` hängen an einem `bookable, polymorphic: true`.

### Bookables::AvailabilityRule

* Felder:

  * `rrule` (z. B. `FREQ=WEEKLY;BYDAY=TU`)
  * `start_time`, `end_time`
  * `enabled` (boolean)

### Bookables::Blackout

* Felder:

  * `starts_at`, `ends_at`
  * `reason` (optional)

### Bookables::SlotPolicy

* Felder:

  * `unit_minutes` (z. B. 15, 30, 60)
  * `min_units`, `max_units`
  * `start_alignment`: `on_hour`, `half_hour`, `quarter`

### Bookables::PriceRule

* Felder:

  * `strategy` (`per_unit_rate`, `quantity_discount`)
  * `unit_minutes` (optional, z. B. für alternative Slot-Größe)
  * `amount` (nur bei `per_unit_rate` notwendig)
  * optionale Filter: `days_of_week`, `time_from/time_to`, `date_from/date_to`
  * `metadata` (JSON) für Rabattdetails, z. B. `{ "min_units": 16, "discount_percent": 20 }`

### Bookables::CancellationPolicy

* `has_many :rooms`
* `has_many :services`
* `has_many :event_runs`
* `has_many :event_sessions`

**Felder:**

* `key`: string (z. B. `service_low`, `event_high`, `room_medium`)
* `name`: string
* `rules`: jsonb (Refund-Tiers + Provider-/Customer-Late-Rules)
* `created_at`, `updated_at`

**Zweck:**

* Definiert **neun feste Policies** (Low, Medium, High pro Typ):  
  - `service_low`, `service_medium`, `service_high`  
  - `event_low`, `event_medium`, `event_high`  
  - `room_low`, `room_medium`, `room_high`
* Jede Policy enthält:  
  - `refund_tiers`: Rückerstattungslogik je nach Frist (z. B. `{24 → 100, 0 → 80}`)  
  - `provider_rules`: 5 %-Plattformgebühr bei **Anbieterstorno**  
  - `customer_rules`: 5 %-Plattformgebühr bei **Kunden-Storno**
* Refunds und Gebühren werden automatisch über Stripe erzeugt.  
* Keine benutzerdefinierten Policies möglich.

### Bookables::ProviderBlackout

* `belongs_to :user`
* Felder:

  * `starts_at`, `ends_at`
  * `reason` (optional)

### Bookables::ResourceBlackout

* `belongs_to :service_resource`
* Felder:

  * `starts_at`, `ends_at`
  * `reason` (optional)

---

## 📑 Templates

### AvailabilityTemplate

* `belongs_to :user`
* `has_many :services, dependent: :restrict_with_exception`
* `has_many :availability_template_rules, dependent: :destroy`
* Felder:

  * `name`
  * `scope` (enum: `service`; weitere Scopes später möglich)
  * `respect_holidays` (boolean, default: false)
  * `holiday_region` (string, optional)
* Löschung nur möglich, wenn keine Services mehr verknüpft sind (ansonsten erst umhängen).

### AvailabilityTemplateRule

* `belongs_to :availability_template`
* Felder:

  * `rrule`
  * `start_time`, `end_time`
  * `enabled`

---

## 🔁 Hintergrundprozesse

### EventSessionGeneratorJob

* Läuft regelmäßig (z. B. täglich).
* Filtert aktive `EventRun` mit `availability_rules.enabled = true`.
* Generiert `EventSession` bis zu einem konfigurierbaren **Horizont** (z. B. +6 Monate).
* Beachtet Blackouts (Termine auslassen oder als `canceled` markieren).
