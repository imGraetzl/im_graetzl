# payment.md – Zahlungs-, Storno- & Auszahlungslogik (Stripe Connect)

> **Modell:** Destination Charges + manuelle Payouts pro Connected Account
> **Ziel:** Gelder fließen direkt auf den Connected Account des Owners (z. B. 95 %), aber werden erst nach erbrachter Leistung manuell an das Bankkonto ausbezahlt.
> Die Plattform erhält sofort ihre Service-Gebühr (z. B. 5 %) und behält die Kontrolle über Refunds und Stornogebühren.

---

## 1. Überblick

Dieses Setup regelt den Zahlungsfluss und das Stornoverhalten im System (**Rooms**, **Services**, **Events**)  
und basiert auf **Destination Charges**, **manuellen Auszahlungen** sowie einer **monatlichen Abrechnung mit automatischer Stornogebühren-Verrechnung**.

**Prinzip:**

* Kund:innen zahlen via Stripe – die Zahlung wird sofort gesplittet (**Owner 95 %**, **Plattform 5 %**).  
* Der Betrag wird auf dem **Connected Account (Balance)** des Owners verbucht – nicht direkt auf seinem Bankkonto.  
* Keine automatische Auszahlung: die Plattform löst manuell Payouts aus (z. B. monatlich oder nach Leistungsende).  
* Bei allen Buchungen und Stornos wird eine einheitliche 5 % Plattformgebühr berechnet und in der Monatsabrechnung ausgewiesen.

**Besonderheiten nach Buchungstyp:**

* **Services & Events:** Kund:innen buchen und bezahlen sofort. Rechnungen werden im Namen des Anbieters erstellt. Nach erfolgreicher Stripe-Zahlung setzt das System `status = confirmed`, `confirmed_at = debited_at`. Schlägt die Zahlung fehl (`payment_status = failed`), bleibt die Buchung auf `pending` bzw. wird auf `canceled` gesetzt – ohne manuelle Owner-Aktion.
* **Rooms:** Anfrage → Annahme durch Anbieter:in → Payment-Link (24 h gültig) → währenddessen *pending* (Zeitraum blockiert). Owner-Zusage setzt `confirmed_at` und `pending_expires_at = confirmed_at + 24h`. Wird innerhalb der Frist bezahlt → Buchung fixiert (`status = confirmed`, `confirmed_at = debited_at`). Lehnt der Owner aktiv ab → `status = canceled`, `canceled_by: provider`; keine Zahlung → Reservierung verfällt automatisch (`status = canceled`, `canceled_by: system`).

**Gebühren und Stornos:**

* **Anbieterstorno:** Kund:in erhält 100 % Refund, Anbieter:in zahlt **5 % Plattformgebühr** (eigene Position in der Abrechnung).  
* **Kundenstorno nach Frist:** Refund laut Policy (Services/Events = 80 %, Rooms = 0 %); Anbieter:in trägt **5 % Plattformgebühr**.  
* **Kundenstorno innerhalb der Frist:** 100 % Refund, Anbieter:in zahlt **5 % Plattformgebühr**. 

Wenn im Abrechnungszeitraum **keine Auszahlung** erfolgt, kann die Plattform offene **5 % Plattformgebühren** später verrechnen oder separat in Rechnung stellen.  
Bei Kleinstbeträgen oder negativer Balance behält sich die Plattform vor, auf eine Verrechnung zu verzichten.  
In der Abrechnung werden Plattformgebühren **immer als eigene Position** ausgewiesen.

---

## 2. Zahlungsfluss (Checkout)

> **Hinweis:** Für das MVP läuft der Transfer immer über das Stripe-Konto des technischen Owners (`booking.user`). Eine spätere Organisations-Entität kann dieses Mapping ersetzen.

```ruby
amount_cents = (booking.amount * 100).to_i
platform_fee_amount_in_cents = (booking.platform_fee_amount * 100).to_i

Stripe::PaymentIntent.create(
  amount: amount_cents,
  currency: 'eur',
  transfer_data: { destination: booking.user.stripe_connect_account_id },
  application_fee_amount: platform_fee_amount_in_cents,
  metadata: {
    booking_id: booking.id,
    bookable_type: booking.bookable_type,
    owner_id: booking.user.id
  }
)
```

**Ergebnis:**

* Kunde zahlt 100 % → Stripe verteilt sofort:

  * **95 %** → Balance des Connected Accounts (Owner)
  * **5 %** → Application Fee (Plattform)
* Plattform erhält **Stripe-Gebühren-Belastung** auf ihrer Balance (Gebühren werden von der Fee abgezogen).

---

## 3. Keine automatischen Bankauszahlungen

Die Owner-Accounts werden auf **manuelles Auszahlungsintervall** gesetzt:

```ruby
account.settings.payouts.schedule.interval = 'manual'
```

**Folge:**

* Gelder bleiben bei Stripe auf der Connected Account Balance.
* Der Owner kann **nicht selbst** auszahlen.
* Nur die Plattform kann Payouts per API oder Job initiieren.

---

## 4. Refunds & Stornierungen

### 4.1 Refund durch Kund:innen-Storno

Bei einer Stornierung durch Kund:innen wird automatisch gemäß der gewählten **Cancellation Policy** entschieden,  
ob eine Rückerstattung **vollständig** (100 %) oder **reduziert** (z. B. 80 % oder 0 %) erfolgt.

#### Beispiel 1: Stornierung innerhalb der kostenlosen Frist (100 %)

    Stripe::Refund.create(
      payment_intent: booking.payment_intent_id,
      reverse_transfer: true
    )
    Stripe::ApplicationFeeRefund.create(
      application_fee: booking.application_fee_id
    )

**Ergebnis:**
* Der Refund-Betrag wird aus dem **Connected Account Balance** des Owners abgezogen.  
* Die **Application Fee** (5 % Plattformgebühr bei der ursprünglichen Buchung) wird automatisch zurückerstattet.  
* Der Kunde erhält **100 % Refund**.  
* Anbieter:in zahlt zusätzlich die **5 % Plattformgebühr (Storno)**, die als `platform_fee_amount` in der Refund-Tabelle gespeichert wird.

📘 **Transparenz:**
* Owner sieht im Stripe-Dashboard den Refund-Abzug, die Balance sinkt.  
* Plattform sieht Fee Refund, Refund Record wird in der Datenbank gespeichert.  

---

#### Beispiel 2: Stornierung nach Ablauf der kostenlosen Frist

Bei verspäteter Stornierung gelten die Regeln der Policy:

* **Services & Events:** 80 % Refund an Kund:in.  
* **Rooms:** 0 % Refund an Kund:in.  
* Anbieter:in zahlt zusätzlich die **5 % Plattformgebühr (Storno)**, die als `platform_fee_amount` in der Refund-Tabelle gespeichert wird.

**Ablauf:**
1. Refund über Stripe (Teilrefund oder kein Refund).  
2. `platform_fee_amount` wird gesetzt (5 %).  
3. Gebühr wird bei der nächsten Abrechnung als **eigene Position ("Plattformgebühr Storno") verrechnet.**

💡 **Vorzeichen:** Sowohl `refund.amount` als auch `refund.platform_fee_amount` werden immer als positive Werte gespeichert. Die Gegenbuchung erfolgt später über `owner_payout_items` (dort ggf. mit negativen Beträgen bei Nachforderungen).

---

### 4.2 Refund bei Anbieter-Storno

Bei einer Stornierung durch Anbieter:innen gilt:

* Kund:in erhält immer **100 % Refund**.  
* Anbieter:in trägt eine **5 % Plattformgebühr (Storno)** auf das gesamte Buchungsvolumen.  
* Diese Gebühr wird in `Refund.platform_fee_amount` gespeichert.

**Ablauf:**
1. Refund wird über Stripe ausgeführt (PaymentIntent + ApplicationFeeRefund).  
2. `platform_fee_amount` wird mit 5 % des ursprünglichen Buchungsbetrags gespeichert.  
3. Die Gebühr wird in der Monatsabrechnung als eigene Position („Plattformgebühr Anbieter-Storno“) ausgewiesen oder bei der nächsten Auszahlung verrechnet.

---

📘 **Zusammenfassung Refund-Handling**

| Auslöser              | Refund an Kund:in | Plattformgebühr (5 %) | Beispiel                            |
|-----------------------|-------------------|------------------------|-------------------------------------|
| Kund:in – rechtzeitig | 100 %             | 5 %                    | Service storniert 30 h vor Start    |
| Kund:in – zu spät     | 80 % / 0 %        | 5 %                    | Event storniert 6 h vor Start       |
| Anbieter:in           | 100 %             | 5 %                    | Anbieter storniert Room vor Beginn  |

---

## 5. Monatsabrechnung & Payouts

Ein geplanter Job (z. B. `OwnerPayoutJob`) läuft am Monatsende und erzeugt eine **Vorschau** für alle fälligen Auszahlungen.

**Lifecycle `payout_status`**

1. `NULL` – Buchung ist erstellt, Stripe hat die Zahlung noch nicht endgültig belastet (`payment_status` ≠ `debited`).  
2. `pending` – Zahlung wurde erfolgreich belastet (`payment_status = debited`), die Leistung ist aber noch nicht abgeschlossen.  
3. `eligible` – Zahlung ist belastet **und** die Leistung liegt in der Vergangenheit; Buchung kommt in die nächste Auszahlung.  
4. `paid_out` – Buchung wurde bereits in einem `owner_payout` verarbeitet und überwiesen.  
5. `recovery_pending` – Buchung wurde schon ausgezahlt, aber danach refundiert/disputed; der offene Betrag wird im nächsten Lauf als Gegenbuchung berücksichtigt.
  `confirmed_at` markiert den Zeitpunkt der finalen Bestätigung: Bei Rooms entsteht er durch Owner-Zusage + Zahlung (24h-Frist via `pending_expires_at`), bei Services/Events direkt nach erfolgreichem Stripe-Checkout (`debited_at`).

- Übergang `NULL → pending`: Stripe-Webhook `payment_intent.succeeded` oder vergleichbarer Callback.  
- Übergang `pending → eligible`: Job, der abgeschlossene Leistungen markiert (z. B. täglich nach `ends_at`).  
- Übergang `eligible → paid_out`: Owner-Payout-Lauf nach erfolgreichem Transfer.  
- Übergang `paid_out → recovery_pending`: Refund oder Dispute nach bereits erfolgter Auszahlung. Nach erfolgreicher Gegenverrechnung wechselt der Status zurück zu `paid_out`; bleibt eine Restschuld offen, verbleibt der Datensatz auf `recovery_pending`.

1. Selektiert alle **bestätigten und abgeschlossenen Buchungen** mit `ends_at ≤ Monatsende` und `payout_status` in `{eligible, recovery_pending}` (Disputes setzen den Status automatisch auf `recovery_pending`).
2. Berechnet je Owner:

   * **Bruttosumme** aller im Monat erbrachten Buchungen  
   * **Abzuziehende Plattformgebühren (5 %)** aus Stornos – sowohl bei Anbieter-Stornos als auch bei Kunden-Stornos
   * **Nettoauszahlungsbetrag** nach Abzug aller relevanten Gebühren  

3. Erstellt bzw. aktualisiert einen `owner_payout`-Datensatz pro Owner, setzt `transfer_status` auf `payout_ready` und hinterlegt die oben berechneten Beträge (positive Beträge aus `eligible`, negative aus `recovery_pending`).
4. Das Admin-Tool listet alle `payout_ready`-Einträge. Mitarbeitende wählen aus, welche Auszahlungen sofort gestartet werden, welche als `payout_waived` markiert werden oder einfach im Status `payout_ready` verbleiben (→ Aufnahme in den nächsten Lauf).
5. Für die ausgewählten Einträge stößt das Admin-Tool anschließend den Stripe-Payout an:

    net_amount_cents = (payout.transfer_amount * 100).to_i

   Stripe::Payout.create(
     amount: net_amount_cents,
     currency: 'eur',
     stripe_account: user.connect_account_id
   )

   Der `transfer_status` wechselt dabei auf `payout_processing` und nach erfolgreichem Transfer auf `payout_completed`. Alle verarbeiteten Buchungen wechseln von `eligible` zu `paid_out`; Einträge aus `recovery_pending` werden nach erfolgter Gegenverrechnung ebenfalls auf `paid_out` (bzw. bleiben `recovery_pending`, falls der Ausgleich nicht vollständig möglich war).
6. Parallel werden PDF-Abrechnungen pro Owner erzeugt und enthalten:

   * **Einnahmen aus Buchungen**  
   * **abzgl. Plattformgebühr – Stornos (5 %)**
   * **abzgl. Plattformgebühr – Buchungen (5 %)**  
   * **= Nettoauszahlung**

**Owner-Payout-Items**

- Zu jedem `owner_payout` wird eine Liste von `owner_payout_items` gespeichert. Jedes Item referenziert genau eine Buchung (`booking_id`) und hält die verrechneten Werte (`booking_amount`, `platform_fee_amount`, `refund_amount`) fest.
- Entfernt ein:e Admin ein Item vor dem Auszahlungsstart, wird `booking.payout_status` wieder auf `eligible` gesetzt – die Buchung erscheint im nächsten Lauf erneut.
- Wird ein `owner_payout` auf `payout_waived` gesetzt, bleiben die Items verknüpft und die zugehörigen Buchungen behalten `payout_status = paid_out`. So bleibt nachvollziehbar, dass keine Auszahlung erfolgen soll.
- Auch reine Refund-Positionen (z. B. Storno **vor** der Auszahlung) landen als eigenes Item mit `booking_amount = 0`, `platform_fee_amount > 0`. Auf diese Weise werden Stornogebühren verbucht, obwohl kein Geld an den Owner fließt.
- Zeichenkonvention:
  - `booking_amount`: positiv für Auszahlungen, negativ für Gegenbuchungen (z. B. spätere Refunds).  
  - `platform_fee_amount`: gleiches Vorzeichen wie `booking_amount`.  
  - `refund_amount`: ausschließlich positive Werte für tatsächliche Rückflüsse (z. B. Storno vor Auszahlung).
  - Disputes: Stripe-Webhooks (`charge.dispute.created`) setzen `payment_status = disputed`, `payout_status = recovery_pending`. Bei verlorenen Disputes wird ein negativer Eintrag erzeugt (analog zu Refunds); bei gewonnenen Disputes kehrt die Buchung zu `paid_out` zurück.
  - Timeline-Felder: `payout_attempted_at` (Auszahlung gestartet), `payout_completed_at` (Transfer erfolgreich), `payout_waived_at` (bewusst erlassene Auszahlung).

> Hinweis: Kleinstbeträge (<1 €) oder negative Salden können im Admin-Tool direkt auf `payout_waived` gesetzt werden. Die Entscheidung bleibt nachvollziehbar, aber ohne technische Zwangsüberweisung.

---

### 5.1 Owner hat nur Stornos, keine Einnahmen

Wenn ein Owner im Monat **nur Stornos** hat (z. B. 2 Stornos, keine abgeschlossenen Leistungen):

* Die **Plattformgebühren (5 %)** werden als Verbindlichkeit erfasst (`platform_fee_collection_status = 'pending'`). 
* Alle betroffenen Buchungen stehen auf `payout_status = recovery_pending` und werden im nächsten Lauf als Gegenposition berücksichtigt.  
* Im Monatsabschluss erzeugt das System automatisch eine **Rechnung an den Owner** über die Summe dieser Gebühren.  
* Falls der Owner eine aktive Stripe-Balance hat (z. B. aus früheren Buchungen), kann die Plattform:
  * entweder einen **negativen Transfer** (Stripe-Connect Debit Transfer) erstellen,  
  * oder den Betrag von der **nächsten Auszahlung einbehalten** (withhold).  
* Wenn keine Deckung vorhanden ist, bleibt der Betrag als offene Forderung bestehen, und eine manuelle Rechnung wird per Mail versendet.

📘 **Hinweis:**  
Stripe zieht *keine automatischen Banklastschriften*. Offene Forderungen können manuell oder über einen separaten PaymentIntent/Invoice beglichen werden.

---

### 5.2 Gebührenstruktur

* Die **5 % Plattformgebühr** enthält bereits sämtliche Stripe-Processing-Kosten.  
  → Es erfolgt **keine separate Ausweisung oder Abrechnung** der Stripe-Gebühren.  
* Die **Plattformgebühr (5 %)** wird:
  * bei jeder erfolgreichen Buchung sofort als **Application Fee** erhoben (Stripe `application_fee_amount`)
  * bei jeder Stornierung zusätzlich als **5 % Plattformgebühr (Storno)** in der Refund-Tabelle (`platform_fee_amount`) gespeichert.  
* Beide Gebühren erscheinen in der Abrechnung als **eigene Positionen** („Plattformgebühr Buchung“ / „Plattformgebühr Storno“).  
* Refunds und Gebühren werden aus der `refunds`-Tabelle übernommen und in die Abrechnung integriert.  
* Wenn im Abrechnungszeitraum keine Auszahlung erfolgt, werden offene Gebühren in den **nächsten Monat übernommen** oder separat in Rechnung gestellt. Bookings verbleiben dann auf `payout_status = eligible` bzw. `recovery_pending`.

---

## 6. Datenbanklogik (relevant für Abrechnung)

| Tabelle           | Feld                                      | Bedeutung |
|-------------------|-------------------------------------------|------------|
# Tabelle/Feld | Bedeutung
| `bookings.platform_fee_amount` | 5 %-Gebühr aus dem Checkout (Application Fee), sofort erhoben. |
| `refunds.platform_fee_amount` | 5 %-Gebühr bei jeder Stornierung (Provider-/Kunden-Storno). |
| `refunds.platform_fee_collection_status` | Fortschritt der Gebühr: `pending`, `collected`, `invoiced`, `waived`. |
| `refunds.region_id` | Region der stornierten Buchung (Snapshot beim Refund). |
| `bookings.payout_status` | Lifecycle: `NULL` → `pending` → `eligible` → `paid_out`; `recovery_pending` für Nachforderungen. |
| `owner_payouts.platform_fees_amount` | Summe der 5 %-Gebühren, die im Auszahlungszeitraum einbehalten werden. |
| `owner_payout_items.platform_fee_amount` | Anteil der 5 %-Gebühr pro Booking (Audit-Trail für Abrechnung). |
| `owner_payout_items.booking_amount` | (Brutto-)Betrag der Buchung, der in den Payout einfließt. |
| `owner_payout_items.refund_amount` | Gegenbuchung (positive Werte), wenn Refunds/Nachforderungen gegengerechnet werden. |
| `owner_payouts.region_id`, `owner_payout_items.region_id`, `bookings.region_id` | Regionenspiegelung für Reporting & Filter (wird beim Erzeugen übernommen). |

---

## Beispiel: Drei Buchungen im Monatslauf

| Buchung | Ereignis | `payment_status` | `payout_status` | Abrechnungseintrag |
|---------|----------|------------------|-----------------|--------------------|
| **B1** – 100 € | keine Storno, Leistung erbracht | `debited` → bleibt so | `pending` → `eligible` → `paid_out` | Item: `booking_amount = 100`, `platform_fee_amount = 5` |
| **B2** – 80 € | Kunde storniert **vor** dem Owner-Payout | `refunded` | `eligible` → `NULL` | Item: `booking_amount = 0`, `platform_fee_amount = 4`, optional `refund_amount = 80` (Stornogebühr wird dennoch verbucht) |
| **B3** – 120 € | zuerst ausgezahlt, später storniert | `debited` → `refunded` | `pending` → `eligible` → `paid_out` → `recovery_pending` → nach Gegenlauf wieder `paid_out` | Payout 1: `booking_amount = 120`, `platform_fee_amount = 6` – Payout 2 (Gegenbuchung): `booking_amount = -120`, `platform_fee_amount = -6` bzw. separater `refund_amount = 120` |

Wichtig: Bei B2 bleibt nach dem Monatslauf kein offener Payout übrig (`payout_status = NULL`), die Stornogebühr wurde aber dennoch dem Owner-Payout zugeordnet. Bei B3 dokumentiert die Kombination aus erstem und zweitem Payout sowohl die Auszahlung als auch die spätere Rückforderung.

---

## 7. Beispiel-Szenarien

Nachfolgend einige praxisnahe Beispiele zur Veranschaulichung der Zahlungs- und Stornoabläufe mit der einheitlichen **5 % Plattformgebühr**, die unabhängig vom Buchungsausgang gilt.

---

### **A) Kunde storniert – rechtzeitig (innerhalb kostenloser Frist)**

| Position | Betrag | Beschreibung |
|-----------|---------|--------------|
| Buchung | 100 € | Kunde zahlt |
| Refund an Kunde | 100 € | Vollständige Rückerstattung |
| Plattformgebühr (5 %) | 5 € | Bleibt bestehen – wird bei Storno nicht rückerstattet |
| **Ergebnis** | **–5 € Plattformgebühr** | Anbieter zahlt 5 %, auch bei vollem Refund |

> Die Plattformgebühr bleibt unabhängig vom Buchungsausgang bestehen.  
> Sie deckt Transaktions- und Systemkosten ab.

---

### **B) Kunde storniert – nach Ablauf der kostenlosen Frist**

| Position | Betrag | Beschreibung |
|-----------|---------|--------------|
| Buchung | 100 € | Kunde zahlt |
| Refund an Kunde | 80 € (Service/Event) / 0 € (Room) | Teilrückerstattung laut Policy |
| Plattformgebühr (5 %) | 5 € | Bleibt bestehen |
| **Ergebnis** | **–5 € Plattformgebühr** | Anbieter zahlt 5 %, Kunde erhält Teilrefund |

> Die Plattformgebühr gilt immer, unabhängig davon, ob der Kunde voll, teilweise oder gar nichts rückerstattet bekommt.

---

### **C) Anbieter storniert**

| Position | Betrag | Beschreibung |
|-----------|---------|--------------|
| Buchung | 100 € | Kunde zahlt |
| Refund an Kunde | 100 € | Voller Refund |
| Plattformgebühr (5 %) | 5 € | Wird dem Anbieter verrechnet |
| **Ergebnis** | **–5 € Plattformgebühr** | Anbieter zahlt 5 %, da die Plattformleistung erbracht wurde |

> Auch bei Anbieterstornos bleibt die Plattformgebühr bestehen.  
> Die Verrechnung erfolgt über die Monatsabrechnung.

---

### **D) Monatliche Abrechnung (Beispiel mit mehreren Buchungen)**

| Position | Betrag |
|-----------|---------|
| 10 Buchungen à 100 € | 1 000 € |
| 2 Stornos à 100 € (je 5 € Gebühr) | –10 € |
| Plattformgebühr (5 %) | –50 € |
| **Auszahlung an Anbieter** | **940 €** |

> Alle Plattformgebühren (5 %) erscheinen als eigene Positionen in der Monatsabrechnung.  
> Auch stornierte Buchungen sind dort berücksichtigt.

---

### **E) Anbieter hat nur Stornos (keine Umsätze)**

| Position | Betrag |
|-----------|---------|
| 2 Stornos à 100 € (je 5 € Gebühr) | –10 € |
| Erfolgreiche Buchungen | 0 € |
| **Saldo Anbieter** | **–10 €** → Rechnung / offene Forderung |

> Wenn keine Gutschriften vorhanden sind, wird die Plattformgebühr gesammelt und ggf. separat in Rechnung gestellt.  
> Bei Kleinstbeträgen kann die Plattform entscheiden, ob auf die Verrechnung verzichtet wird.

---

### ✅ **Zusammenfassung der Logik**

| Fall | Refund an Kunde | Plattformgebühr (5 %) | Anmerkung |
|------|------------------|-------------------------|------------|
| Kunde storniert (früh) | 100 % | bleibt bestehen | Anbieter zahlt 5 % |
| Kunde storniert (spät) | 80 % / 0 % | bleibt bestehen | Anbieter zahlt 5 % |
| Anbieter storniert | 100 % | bleibt bestehen | Anbieter zahlt 5 % |
| System storniert (z. B. Pending abgelaufen) | 100 % | entfällt | keine Gebühr |

---

## 8. Fazit

> Das Modell ist vollständig Stripe-kompatibel und bildet alle Stornobedingungen korrekt ab:
>
> * **Destination Charges** ermöglichen einen sauberen Zahlungsfluss mit direkter Gutschrift auf den Connected Accounts der Anbieter:innen.  
> * **Application Fee Refunds** sorgen für vollständige Rückerstattungen (100 %) bei rechtzeitigen Stornos, ohne Vermischung von Plattform- und Anbieter-Geldern.  
> * Die **Plattformgebühr (5 %)** wird bei jeder Buchung sowie bei Anbieter- oder Kunden-Stornos automatisch berechnet und in der Monatsabrechnung ausgewiesen.  
> * Sie ist pauschal und umfasst bereits alle Stripe-Processing-Kosten – es erfolgt keine zusätzliche Ausweisung oder Verrechnung.  
> * Kein automatisches Einziehen vom Bankkonto: alle Abbuchungen und Nachverrechnungen erfolgen manuell oder im Rahmen der Monatsabrechnung.  
> * Das System bleibt **DSGVO-konform**, **bilanziell sauber** und garantiert **volle Transparenz** über alle Zahlungs- und Stornoflüsse.
