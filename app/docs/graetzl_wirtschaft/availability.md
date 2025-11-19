# Availability, Templates & Abwesenheiten (Spezifikation)

Diese Spezifikation beschreibt die **Verfügbarkeitslogik** für Services (und perspektivisch Rooms/EventRuns), inklusive **Availability Templates**, **Feiertagsbehandlung** und **zentralen Abwesenheiten** (Urlaub/Krankheit) auf Anbieter- und Resource-Ebene.

---

## Ziele & Prinzipien
- **Einfach für Nutzer:innen**: Templates dienen als **Vorlagen** und **Batch-Update-Werkzeug**; Services haben **immer eigene Regeln**.
- **Keine stillen Vererbungen**: Änderungen an Templates wirken **nur** nach expliziter Bestätigung.
- **Flexibel**: Pro Service jederzeit Ausnahmen möglich; bei Bedarf als neue Vorlage speicherbar.
- **Skalierbar**: Abwesenheiten zentral pflegen (Provider/Resource) statt pro Service einzeln.

---

## Datenmodell (Kurzüberblick)

### Templates
- `AvailabilityTemplate` (name, scope: **nur `service`**, respect_holidays, holiday_region)
- `AvailabilityTemplateRule` (rrule, start_time, end_time, enabled)
- `Service.availability_template_id` (immer gesetzt) → verweist auf die aktive Vorlage
- Feiertagslogik: Resolver liest `respect_holidays`/`holiday_region` direkt aus der verknüpften Vorlage.

### Abwesenheiten
- `Bookables::Blackout` (bookable-spezifisch)
- `Bookables::ProviderBlackout` (User-weite Abwesenheit: blockt alle Bookables des Owners)
- `Bookables::ResourceBlackout` (Resource-weite Abwesenheit: blockt alle Services dieser Resource)

---

## UX-Flows

### A) **Ersten Service anlegen** (keine vorhandenen Templates)
1. **Formfeld „Verfügbarkeit“**:
   - Editor: Wochentage + Zeitfenster (mehrere Blöcke), Datumsgültigkeit, aktiv/inaktiv.
   - Feld **„Vorlagenname“** (Pflicht, z. B. „Bürozeiten“).
   - Checkbox **„Feiertage berücksichtigen“** (+ optional Region, default AT).
2. **Speichern**:
   - System erstellt **AvailabilityTemplate** + **TemplateRules** aus dem Editor.
   - Regeln werden in `service.availability_rules` **kopiert**.
   - `service.availability_template_id = template.id`.
   - Feiertags-Flag & Region werden auf der Vorlage gespeichert (Resolver liest sie dort aus).

### B) **Nächsten Service anlegen** (Templates vorhanden)
1. Auswahl **„Vorlage wählen“** (Dropdown) **oder** „Neue Zeiten definieren“ → erzeugt automatisch eine neue Vorlage.
2. Verhalten:
   - **Vorlage gewählt, keine Änderung** → Regeln kopieren, `service.availability_template_id = template.id`.
   - **Vorlage gewählt + Änderung**
     - Wenn Vorlage **nur diesen Service** betrifft → Änderungen können die Vorlage direkt überschreiben.
     - Wenn Vorlage **auch andere Services** hat → Dialog:  
       1. **„Als neue Vorlage speichern“** → Name vergeben → neue Vorlage anlegen, Service verknüpfen (`availability_template_id = neue.id`).  
       2. **„Bestehende Vorlage aktualisieren & auf verknüpfte Services anwenden“** → Regeln überschreiben, Batch-Apply auf alle Services mit dieser Vorlage auslösen.

### C) **Template bearbeiten (später)**
> MVP-Hinweis: Zum Start genügt ein einfacher Editor ohne Batch-Apply. Der unten beschriebene Dialog ist als spätere Erweiterung vorgesehen.

1. Template-Editor (Name, Regeln, Feiertags-Flag/Region).
2. Nach **Speichern** → Dialog:
   - **„Auf verknüpfte Services anwenden?“** → Checkbox-Liste der Services mit `availability_template_id = dieses Template`.
   - **„Auf ALLE Services anwenden“** (optional/rollenbasiert) → hängt weitere Services auf dieses Template um.
3. **Bestätigung** → Für alle ausgewählten Services:
   - `service.availability_rules` **ersetzen** (löschen → kopieren aus Template)
   - `service.availability_template_id` bleibt gesetzt (bzw. wird auf die aktualisierte Vorlage umgehängt)

### D) **Abwesenheiten/Urlaub**
- **ProviderBlackout** (Owner): Zeitraum + Grund → blockt alle Bookables der Anbieter:in.
- **ResourceBlackout** (Person A/B): Zeitraum + Grund → blockt alle Services, die diese Resource verwenden.
- UI: Seite „Abwesenheiten“ mit zwei Tabs (Ich/Global, Ressourcen). Sofortige Wirkung.

---

## Feiertage
- Konfig über Template: `respect_holidays` (bool) + `holiday_region` (string).
- MVP: ausschließlich `AT` zulässig; weitere Codes (z. B. `DE`, `AT-9`) werden bei Bedarf in einer späteren Iteration ergänzt.
- Umsetzung: interne Holiday-Library (z. B. `holidays` Gem), keine externe API nötig.
- Resolver blendet Feiertage als **nicht verfügbar** aus, wenn das verknüpfte Template `respect_holidays = true` (Region via `availability_template.holiday_region`).
- Für EventRuns steuern `respect_holidays` + `holiday_region`, ob der Session-Generator Feiertage auslässt (Defaults optional am Event, Anpassung pro Run möglich).

---

## Slot-Resolver (Service)

**Eingaben**: Service, Zeitraum, (optional) bevorzugte Resource

**Schritte**:
1. **Regelbasis**: `service.availability_rules` (1:1 Kopien aus der verknüpften Vorlage)
2. **Subtraktion**:
   - `Bookables::Blackout` am Service
   - `Bookables::ProviderBlackout` des Owners
   - `Bookables::ResourceBlackout` der gewählten Resource (oder aller, wenn auto-zuweisen)
   - **Feiertage**, wenn das verknüpfte Template `respect_holidays = true`
   - **Pending-Buchungen (Rooms):** Während einer laufenden 24-Stunden-Reservierung gelten diese Zeiträume als blockiert und werden im Resolver ausgeschlossen.
   - **Externe Buchungen** (`source: external`): Diese werden wie normale Buchungen behandelt und blockieren den Zeitraum im Resolver.


3. **SlotPolicy berücksichtigen**:
   - Start-Ausrichtung: volle/halbe/viertel Stunde (Slots werden auf dieses Raster gerundet).
   - `unit_minutes`: bestimmt Slot-Länge; bei Rooms zusätzlich `min_units`/`max_units`.
4. **Exklusivität** (Hard Rule): pro `ServiceResource` nur 1 aktive Buchung je Zeitraum → kollidierende Slots verwerfen; Rooms verhalten sich analog.
5. **Mehrere Ressourcen (optional später)**:
   - Auto-Zuordnung: nimm erste verfügbare Resource
   - Manuell: Nutzer:in wählt Resource

**Beispiel (Abfrage für einen konkreten Tag, z. B. Mittwoch)**
- Service: 60 min Slots, Alignment auf ganze Stunde, Verfügbarkeit Mo–Fr 09–17 Uhr.
- Blackout am Mittwoch 12–14 Uhr → Slots 09/10/11/14/15/16 Uhr bleiben übrig.
- Pending-Buchung am selben Tag 09–10 Uhr → dieser Slot entfällt.
- Rückgabe (für diesen Tag): `[{ start_at: 10:00, end_at: 11:00, resource_id: 3 }, { start_at: 11:00, end_at: 12:00, resource_id: 3 }, { start_at: 14:00, end_at: 15:00, resource_id: 3 }, …]`

---

## API/Backend-Verhalten

### Template-Anwendung (Batch)
- Serviceobjekt: `AvailabilityTemplateApplier.apply(template, service)`
- Effekt:
  - `service.availability_rules.destroy_all`
  - Kopie aller `availability_template_rules` → `service.availability_rules`
  - Setze `service.availability_template_id = template.id`

- Beim **Service#create** (immer mit Vorlage): Kopieren + Setzen `availability_template_id`
- Beim **Template#update**: optionaler Apply-Schritt (siehe Dialog oben)
- `EventRun#create`: übernimmt `respect_holidays`/`holiday_region` aus dem Event (falls vorhanden) oder setzt eigene Werte.

---

## Edge Cases & Sicherheit
- **Preview** vor Batch-Apply: „X Services werden geändert“.
- **Konflikte**: Manuelle Sonderregeln sind nicht vorgesehen; historische Abweichungen werden beim Apply überschrieben (Warnhinweis anzeigen).
- **Löschung von Templates**: Nur möglich, wenn keine Services mehr darauf zeigen (Services müssen vorab auf eine andere Vorlage umgehängt werden).
- **Archivierung**: Templates können archiviert (hidden) statt gelöscht werden.

---

## Migration (Zusammenfassung)
- Tabellen: `availability_templates`, `availability_template_rules`, `bookables_provider_blackouts`, `bookables_resource_blackouts`
- Felder: `services.availability_template_id` (**not null**), `event_runs.respect_holidays`, `event_runs.holiday_region`

---

## Rooms – aktueller Stand
- Room-Verfügbarkeiten werden derzeit ausschließlich über `Bookables::AvailabilityRule` + `Bookables::Blackout` gepflegt.
- Es existiert **noch kein** Template-Mechanismus für Rooms; Zeiten werden pro Raum manuell verwaltet.
- Feiertagslogik ist (Stand jetzt) nicht implementiert. Räume berücksichtigen also nur explizite Blackouts/Blocker – keine automatische Holiday-Aggregation.
- Perspektivisch kann der Service-Ansatz übernommen werden (Template-Pflicht, Feiertage über Vorlage); dies wird separat spezifiziert, bevor wir die Featurelücke schließen.
- Datenmodell/Resolver werden so gehalten, dass `rooms` später ein `availability_template_id` aufnehmen können, ohne bestehende Implementierungen zu brechen.

## Events – aktueller Stand
- EventRuns besitzen eigene Felder `respect_holidays` + `holiday_region`; damit steuert der Session-Generator gezielt Feiertage pro Run.
- Es gibt bewusst **kein** Template-System für Events/Runs. Anpassungen erfolgen direkt am Run (oder über Event-Defaults, die beim Anlegen neuer Runs gezogen werden).
- AvailabilityRules/Blackouts bleiben die Grundlage für Terminserien; Feiertage wirken als zusätzlicher Filter während der Session-Generierung.
- Sollten wir später Event-Templates benötigen, wird das Konzept separat beschrieben – derzeit gilt der Run-spezifische Ansatz als Referenz.

### Ergänzung: Pending-Reservierungen bei Rooms

Nach Annahme einer Buchungsanfrage durch den Anbieter wird der angefragte Zeitraum sofort **temporär blockiert**:

* **Status:** `pending`  
* **Reservierungsdauer:** 24 Stunden  
* Zeitraum gilt in der Verfügbarkeitsberechnung als **nicht buchbar**  
* Bei Zahlung innerhalb der Frist → Buchung wird **fixiert (confirmed)**  
* Bei Nicht-Zahlung → Reservierung **verfällt automatisch** und Zeitraum wird wieder freigegeben

**Technische Umsetzung**

- Pending-Buchungen werden im Slot-Resolver wie `Bookables::Blackout` behandelt.  
- Konfiguration (als Kommentar/Leitlinie für Implementierung; keine harte Konfig):
  
      exclude_slots_for_pending_bookings = true
      pending_expiration_hours = 24

- Nach Ablauf der Frist löst das System automatisch ein  
  `Booking#cancel!(by: :system)` aus.

---

## Open Questions
- Erweiterung Holiday-Regionen (z. B. `DE`, `AT-9`) – Evaluierung nach MVP
- Rollenbasierte Sichtbarkeit von „Auf ALLE anwenden“ (nur Admin/Super-Owner?)
- Undo/History für Batch-Apply nötig?
