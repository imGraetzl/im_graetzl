# Events – Struktur & Beispiele

Dieses Dokument ergänzt `schema.md` und `bookables_overview.md` um konkrete Szenarien
für Events, Runs und Sessions. Ziel ist, typische Setups nachvollziehbar zu machen,
ohne die Hauptdokumente mit Beispielen zu überfrachten.

---

## Überblick – Ebenen

| Ebene        | Beschreibung                                                     |
|--------------|------------------------------------------------------------------|
| `Event`      | Rahmen / Angebot. Hält Stammdaten und Default-Einstellungen.     |
| `EventRun`   | Konkrete Durchführung (Serie oder Einzeltermin). Entscheidet, ob | 
|              | Buchungen auf dem Run oder seinen Sessions stattfinden.          |
| `EventSession` | Einzeltermin innerhalb eines Runs. Optional bei `per_run`, Pflicht bei `per_session`.|

Kalenderdarstellung: selbst bei Single-Terminen erzeugen wir eine Session, damit
alle Event-Varianten konsistent im Kalender und in der Session-Generierung landen.

---

## Szenario 1 – Einmaliges, bezahltes Event

**„Yoga Einführungskurs“ – 01.11.2025, 10:00–11:00, Ticket für gesamten Termin**

- `Event`
  - `booking_type: paid`
  - Default-Modus `per_run`
- `EventRun`
  - `schedule_type: single`, `booking_mode: per_run`
  - `starts_at/ends_at` gesetzt, `price_amount` = Ticketpreis
- `EventSession`
  - Ein Session-Eintrag (10:00–11:00) für Kalender & Anwesenheit

> **Buchung:** passiert am Run. Session dient zur Darstellung.

---

## Szenario 2 – Fortlaufender Kurs, Sessions buchbar (paid)

**„After-Work Yoga“ – jeden Dienstag 18:00–19:00, fortlaufend, Ticket pro Termin**

- `Event`
  - `booking_type: paid`, `default_booking_mode: per_session`
- `EventRun`
  - `schedule_type: multi`, `booking_mode: per_session`
  - AvailabilityRules: Dienstag 18:00–19:00 (kein Enddatum → open end)
- `EventSession`
  - Wird per Generator rollierend angelegt (z. B. 6 Monate im Voraus)
  - Jede Session per se buchbar (`Booking` auf Session)

---

## Szenario 3 – Bezahlter Kurs mit begrenzter Laufzeit, Buchung als Paket

**„Yoga Aufbaukurs“ – 8 Termine dienstags, Februar & März, Paketpreis**

- `Event`
  - `booking_type: paid`, Default `per_run`
- `EventRun`
  - `schedule_type: multi`, `booking_mode: per_run`
  - `starts_at`/`ends_at` = erster/letzter Termin
  - `price_amount` = Gesamtpreis
- `EventSession`
  - Acht Sessions (Termine) für Kalender und Anwesenheit

> **Buchung:** läuft am Run. Sessions zeigen Termine, aber generieren keine eigenen Buchungen.

---

## Szenario 4 – Gleicher Kurs, Sessions einzeln buchbar

- Wie Szenario 3, aber
  - `booking_mode: per_session`
  - `EventSession` mit `price_amount` (falls vom Run abweichend)

> **Buchung:** entsteht pro Session; Run dient als Container.

---

## Hinweise & Best Practices

- Auch bei `per_run`-Events empfehlen wir eine Session pro Termin für Kalender & Attendance.
- `location_id` und `region_id` können auf Event, Run oder Session gesetzt werden, abhängig davon,
  ob Termine unterschiedliche Orte haben.
- Feiertage: `EventRun.respect_holidays` + `holiday_region` steuern, ob der Session-Generator Termine an gesetzlichen Feiertagen auslässt (Defaults optional am Event pflegen).
- Availability-Templates kommen bei Events derzeit nicht zum Einsatz; Änderungen erfolgen direkt am Run (oder über Event-Defaults bei neuen Runs).
- `booking_type = free` → Run/Session erzeugen `Participation` statt `Booking`; Struktur bleibt identisch.
- Der `EventSessionGeneratorJob` erstellt Sessions für Runs mit AvailabilityRules; bei reinen Einzelterminen
  kann die Session direkt beim Anlegen entstehen.

---

**Weiterführend**: Schema-Details siehe `schema.md` (Abschnitte 2.5–2.7), Logikübersicht in `bookables_overview.md`.
