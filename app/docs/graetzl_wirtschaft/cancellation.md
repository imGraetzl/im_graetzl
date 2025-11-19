# Stornobedingungen (Cancellation Policies)

Diese Spezifikation beschreibt die verbindliche Logik für Stornierungen im Buchungssystem **Grätzl Wirtschaft**.  
Sie regelt, wie Rückerstattungen und Gebühren bei Stornierungen automatisch über Stripe abgewickelt werden – sowohl für **Kund:innen** als auch für **Anbieter:innen**.

---

## Ziel

* Einheitliche Stornobedingungen für alle Buchungstypen (**Room**, **Service**, **Event**)  
* Anbieter:innen können beim Erstellen eines Angebots zwischen drei Storno-Modellen wählen: **Low**, **Medium** oder **High**  
* Automatische Rückerstattung an Kund:innen gemäß der gewählten Policy  
* Bei **Stornierung durch Anbieter:innen** wird die **5 % Plattformgebühr** vom Buchungsvolumen einbehalten  
* Bei **Stornierung durch Kund:innen** wird dem Anbieter ebenfalls die **5 % Plattformgebühr** weiterverrechnet  
* Alle Refunds werden in einer eigenen Tabelle gespeichert und enthalten den Ursprung der Stornierung (`canceled_by`)  
* Plattformgebühren werden monatlich über die Abrechnung (siehe `payment.md`) verrechnet

---

## Übersicht

Jede buchbare Einheit (`Bookable`) besitzt eine zugewiesene **Stornobedingung** über:

```ruby
belongs_to :cancellation_policy, class_name: 'Bookables::CancellationPolicy'
```

Einträge in `Bookables::CancellationPolicy` sind **vordefinierte Datensätze (Seeds)**. Nutzer:innen können keine eigenen Bedingungen erstellen oder bearbeiten.

---

## Feste Presets

| Key              | Name    | Regelbeschreibung                                                                 | Refund-Staffel (hours → percent) |
|------------------|---------|------------------------------------------------------------------------------------|----------------------------------|
| `service_low`    | Low     | Immer kostenlos stornierbar; Anbieter zahlt **5 %**                                | `{0 → 100}`                      |
| `service_medium` | Medium  | Bis 24 h vor Start kostenlos, danach **80 % Refund**; Anbieter zahlt **5 %**       | `{24 → 100, 0 → 80}`             |
| `service_high`   | High    | Bis 48 h vor Start kostenlos, danach **80 % Refund**; Anbieter zahlt **5 %**       | `{48 → 100, 0 → 80}`             |
| `event_low`      | Low     | Immer kostenlos stornierbar; Anbieter zahlt **5 %**                                | `{0 → 100}`                      |
| `event_medium`   | Medium  | Bis 24 h vor Start kostenlos, danach **80 % Refund**; Anbieter zahlt **5 %**       | `{24 → 100, 0 → 80}`             |
| `event_high`     | High    | Bis 48 h vor Start kostenlos, danach **80 % Refund**; Anbieter zahlt **5 %**       | `{48 → 100, 0 → 80}`             |
| `room_low`       | Low     | Immer kostenlos stornierbar; Anbieter zahlt **5 %**                                | `{0 → 100}`                      |
| `room_medium`    | Medium  | Bis 24 h vor Start kostenlos, danach **0 % Refund**; Anbieter zahlt **5 %**        | `{24 → 100, 0 → 0}`              |
| `room_high`      | High    | Bis 72 h vor Start kostenlos, danach **0 % Refund**; Anbieter zahlt **5 %**        | `{72 → 100, 0 → 0}`              |

---

## Erweiterung: Gebührenregeln (Provider & Customer Rules)

Neben den Rückerstattungs-Staffeln (**`refund_tiers`**) können Policies zusätzliche Gebührenregeln enthalten,  
die bei bestimmten Arten von Stornierungen greifen – entweder durch den **Anbieter** oder durch die **Kund:innen** selbst.

Diese Regeln sind Teil des JSON-Feldes `rules` in der `Bookables::CancellationPolicy`.

---

### Beispiel (Service- oder Eventbuchung)

```json
{
  "refund_tiers": [
    { "before_hours": 24, "refund_percent": 100 },
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

**Bedeutung:**

* `refund_tiers`: Definiert die Rückzahlung an Kund:innen in Abhängigkeit vom Zeitpunkt der Stornierung.  
* `provider_rules`: Legen fest, welche Gebühren dem Anbieter bei **Anbieterstorno** verrechnet werden.  
  → Der Kunde erhält immer **100 % Refund**, der Anbieter zahlt **5 % Plattformgebühr** vom Buchungsvolumen.  
* `customer_rules`: Legen fest, welche Gebühren dem Anbieter bei **Kunden-Storno** verrechnet werden.  
  → Der Kunde erhält **reduzierte Rückerstattung** (80 % bei Service/Event, 0 % bei Room), der Anbieter zahlt **5 % Plattformgebühr**.  
* `fee_percent`: Prozentualer Anteil der Buchungssumme, der als Gebühr berechnet wird (Standard: **5 %**).  
* `before_hours`: Zeitfenster vor Buchungsbeginn (z. B. 24 h, 48 h, 72 h).

---

**Beispielwirkung:**

* **Kunde storniert rechtzeitig** → 100 % Refund, Anbieter zahlt 5 % Plattformgebühr.
* **Kunde storniert zu spät** → 80 % (Service/Event) oder 0 % (Room) Refund, Anbieter zahlt 5 % Plattformgebühr.  
* **Anbieter storniert** → 100 % Refund an Kunde, Anbieter zahlt 5 % Plattformgebühr.  
* **System storniert** → 100 % Refund an Kunde, keine Gebühr.

Diese Regeln gelten für **alle Buchungstypen** (Service, Event, Room).  
Bei **Room**-Buchungen kommt zusätzlich eine 24 h Pending-Logik zur Anwendung (siehe unten).

---

## Refund-Tabelle

### Modellstruktur

```ruby
class Refund < ApplicationRecord
  belongs_to :booking

  # Felder
  # amount:decimal              # Rückerstatteter Betrag
  # stripe_refund_id:string           # Referenz zur Refund-ID bei Stripe
  # refunded_at:datetime              # Zeitpunkt der Rückerstattung
  # platform_fee_amount:decimal       # Plattformgebühr (5 %), die bei jeder Stornierung anfällt
  # Hinweis: Wird für Abrechnung und Auswertungen genutzt (Monatsabrechnung / Reporting)
  # canceled_by:string                # Quelle der Stornierung: 'customer', 'provider' oder 'system'
end
```

### Migration

```ruby
create_table :refunds do |t|
  t.references :booking, null: false, foreign_key: true
  t.decimal :amount, precision: 10, scale: 2, null: false   # Rückerstatteter Betrag
  t.string :stripe_refund_id                               # Referenz zur Refund-ID bei Stripe
  t.datetime :refunded_at, null: false                     # Zeitpunkt der Rückerstattung
  t.decimal :platform_fee_amount, precision: 10, scale: 2, default: 0, null: false   # Plattformgebühr (5 %)
  t.string :canceled_by, null: false, default: 'customer'  # Quelle der Stornierung: 'customer', 'provider' oder 'system'
  t.timestamps
end
```

---

## Refund-Logik im Booking

Refunds werden als eigene Datensätze gespeichert, ergänzt um die Plattformgebühr (`platform_fee_amount`) und den Storno-Ursprung (`canceled_by`).
Die Plattformgebühr wird nicht über Stripe abgezogen, sondern in der Datenbank gespeichert und in der Monatsabrechnung verrechnet.

### Beispielimplementierung

```ruby
class Booking < ApplicationRecord
  has_many :refunds, dependent: :destroy

  def cancel!(by:, reason: nil)
    return if canceled?

    # Ermittlung des Refund-Prozentsatzes
    refund_percent = case by.to_sym
                     when :provider, :system
                       100
                     else
                       policy_refund_percent
                     end

    transaction do
      if paid? && refund_percent.positive?
        amount = (amount * refund_percent / 100.0).round(2)

        # Refund über Stripe anstoßen
        stripe_refund = Stripe::Refund.create(
          payment_intent: payment_intent_id,
          amount: amount,
          stripe_account: connect_account_id
        )

        # Plattformgebühr bestimmen (5 % bei jeder Stornierung)
        platform_fee = calculate_platform_fee

        # Refund-Datensatz speichern
        refunds.create!(
          amount: amount,
          platform_fee_amount: platform_fee,
          stripe_refund_id: stripe_refund.id,
          refunded_at: Time.current,
          canceled_by: by.to_s
        )

        update!(payment_status: :refunded)
      end

      update!(status: :canceled)
    end
  end

  private

  # Stunden bis zum Startzeitpunkt
  def hours_before_start
    ((starts_at - Time.current) / 1.hour).floor
  end

  # Refund-Prozentsatz gemäß Policy (z. B. 100 %, 80 %, 0 %)
  def policy_refund_percent
    policy = bookable.try(:cancellation_policy)
    return 0 unless policy&.rules&.dig("refund_tiers")

    tier = policy.rules["refund_tiers"].find { |t| hours_before_start >= t["before_hours"].to_i }
    tier ? tier["refund_percent"].to_i : 0
  end

  # Einheitliche 5 % Plattformgebühr (unabhängig von der Storno-Art)
  def calculate_platform_fee
    policy = bookable.try(:cancellation_policy)
    fee_percent =
      if policy&.rules&.dig("platform_fee_percent")
        policy.rules["platform_fee_percent"].to_f
      else
        5.0 # Standardwert, falls nicht definiert
      end

    (amount * fee_percent / 100.0).round(2)
  end
end
```

---

## Ablauf: Stornierung & Refund

### 1. Kunde storniert (`Booking#cancel!(by: :customer)`)

* Refund wird gemäß den **`refund_tiers`** der zugewiesenen Policy berechnet.  
* Bei der Stornierung wird die **`customer_rules`** angewendet.  
  → Kund:in erhält reduzierten Refund (80 % bei Service/Event, 0 % bei Room).  
  → Anbieter:in zahlt 5 % Plattformgebühr (wird im Refund gespeichert).  
* Refund wird automatisch über Stripe erstellt und als Datensatz gespeichert.  
* `status = canceled`, `payment_status = refunded`, `canceled_by = 'customer'`.
* `payout_status`  
  * Buchungen mit `payout_status` `pending` oder `eligible` werden auf `NULL` zurückgesetzt (keine Auszahlung mehr nötig).  
  * Buchungen mit `payout_status = paid_out` wechseln auf `recovery_pending`, damit der Betrag im nächsten Lauf gegengerechnet wird.

---

### 2. Anbieter storniert (`Booking#cancel!(by: :provider)`)

* Kund:in erhält **immer 100 % Refund**.  
* Die **`provider_rules`** werden angewendet (Standard: 5 % Plattformgebühr für den Anbieter).  
* Diese Gebühr wird im Refund als `platform_fee_amount` gespeichert.  
* `status = canceled`, `payment_status = refunded`, `canceled_by = 'provider'`.
* `payout_status`-Anpassung wie oben.

---

### 3. System-Storno (`Booking#cancel!(by: :system)`)

* Wird vom System ausgelöst (z. B. abgelaufene Pending-Buchung bei Room).  
* Verhalten identisch mit Anbieter-Storno: **100 % Refund an Kund:in**, keine zusätzliche Gebühr.  
* `status = canceled`, `payment_status = refunded`, `canceled_by = 'system'`.
* `payout_status`-Anpassung wie oben.

---

## Verhalten bei kostenlosen Buchungen (z. B. kostenlose Events)

Für kostenlose Buchungen (`booking_type = free`) werden **keine Refunds und keine Plattformgebühren** erzeugt.  
Es wird ausschließlich der Buchungsstatus geändert:

```ruby
def cancel!
  update!(status: :canceled)
end
```

---

## E-Mail- und UI-Verhalten

### Kund:innen

* Button **„Buchung stornieren“** → Dialog mit Bedingungen → Storno ausführen.
* Automatische E-Mail mit Refund-Info.

### Anbieter:innen

* Button **„Buchung stornieren“** → Refund für Kund:in = 100 %, Gebühr für Anbieter gemäß Policy.
* E-Mail-Bestätigung mit Gebühreninformation.

### Admin/System

* Kann Buchungen über Admin-Oberfläche stornieren.
* Gleiches Verhalten wie Anbieter-Storno, aber **ohne** Plattformgebühr.

---

## Auswertungen & Nachvollziehbarkeit

Mit dem Feld `canceled_by` lassen sich alle Stornos klar auswerten:

| Frage                                      | Beispiel-Query                                                 |
| ------------------------------------------ | -------------------------------------------------------------- |
| Wie oft stornieren Kund:innen?             | `Refund.where(canceled_by: 'customer').count`                  |
| Wie oft stornieren Anbieter:innen?         | `Refund.where(canceled_by: 'provider').count`                  |
| Gesamtbetrag an Plattformgebühren          | `Refund.sum(:platform_fee_amount)`                            |
| Verteilung nach Typ (Room, Service, Event) | `Refund.joins(:booking).group('bookings.bookable_type').count` |

---

## Zusammenfassung

* Neun feste Policies:  
  `service_low`, `service_medium`, `service_high`,  
  `event_low`, `event_medium`, `event_high`,  
  `room_low`, `room_medium`, `room_high`
* Vollautomatische Refunds über Stripe gemäß der gewählten Policy.
* Erweiterte `provider_rules` und `customer_rules` regeln Gebühren:
  * **Anbieter-Storno:** 5 % Plattformgebühr auf das Buchungsvolumen.  
  * **Kunden-Storno:** 5 % Plattformgebühr für den Anbieter.
* Refunds enthalten `platform_fee_amount` und `canceled_by`.
* Keine benutzerdefinierten oder editierbaren Policies durch Nutzer:innen.
* Einheitliche User Experience, transparente Abwicklung und klare Auswertbarkeit im System.
