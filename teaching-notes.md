# Moderationsleitfaden

## Vorbereitung

- R-Projekt und `Syntaxen/00_installation.R` öffnen; Abschnitte einzeln ausführen.
  Nur bei Bedarf installieren, danach Versionen und Beispieldateien prüfen.
- eatAutoCode nicht separat laden: Beide Pakete enthalten `code_responses()`;
  für den Workshop wird die Funktion aus eatPrepTBA benötigt.
- Die lokalen Skripte `02` bis `05` vollständig ausführen.
- Folien, Handout, Skripte und Excel-Codebuch bereitlegen.
- Die beiden API-Vorlagen nicht im lokalen Ablauf ausführen. Ihre Adressen
  und Workspace-IDs sind Beispiele für die spätere Arbeit mit eigenem Konto.
- Die Rechenaufgabe und die Lesestudie als getrennte synthetische Beispiele
  ankündigen. Die Screenshots gehören zur Rechenaufgabe.

## Ablauf

**0 · Einstieg:** Materialseite, Folien und Downloadpaket öffnen. Das
entpackte R-Projekt und die Abschnitte in `00_installation.R` zeigen;
die Installationszeilen sind nur bei Bedarf erforderlich.
Das ZIP enthält nur die Ordner `Syntaxen` und `Daten` sowie die Projektdatei;
die PDF-Folien stehen separat bereit.

**1 · Paket und erste Kodierung:** Paket, Dokumentation und
Rückmeldemöglichkeiten für beide Pakete vorstellen. Datenquellen zuordnen
und den Abruf anhand der R-Objekte erklären. Das Rechenbeispiel in
`02_daten_verstehen.R` vollständig behandeln: JSON entpacken, Partial
Credit nachvollziehen, selbst kodieren, das Item auswählen und gespeicherte
Codes einlesen.
Den API-Prüfbericht `get_coding_report()` und die Metadatenaufbereitung
mit `add_metadata()` am passenden Arbeitsschritt einordnen. Letztere kann
Profildefinitionen aus dem Internet nachladen; im Offlinebeispiel die
vorbereitete Ausgabe verwenden.

**Pause und Ausprobieren, etwa zehn Minuten:** Skripte `00`, `01` und `02`
ansehen. In `00` Pakete laden und Dateien prüfen, dann `02` ausführen,
sofern noch nicht parallel geschehen. Skript `01` ist eine Vorlage für
eigene Zugänge. Anschließend auf der Folie **„Fragen?“** offene Punkte
sammeln und besprechen.

**2 · Beispiel 2:** Die Lesestudie mit `03_datenaufbereitung.R` von der
Kodierung über Missing-Regeln und Kennwerte bis zum Skalierungsdatensatz
und Export durchgehen.

**Pause und Ausprobieren, etwa zehn Minuten:** Skript `03` einmal
ausführen, sofern noch nicht parallel geschehen. Danach eine kurze
Fragerunde auf der zweiten Folie **„Fragen?“**.

**3 · Logs und Codebücher:** Logs mit Skript `04` auf Ereignisse, Zeiten
und Fokusverluste beschränken. Anschließend den Zweck des Codebuchs
erläutern: Codes und Bewertungen aus den Kodierschemata dokumentieren.
Zuerst die Erstellung mit `prepare_codebook()` und den DOCX-Download aus
IQB-Studio anhand von Skript `06` zeigen; dann Auswahl und Export an der
lokalen Tabelle in Skript `05`. Die API-Vorlage erfordert keine Ausführung
im Workshop.

**Pause und Ausprobieren, etwa zehn Minuten:** Skripte `04` und `05`
ausführen und die Ergebnisse ansehen; Skript `06` als Vorlage durchsehen.
Danach offene Punkte auf der dritten Folie **„Fragen?“** besprechen.

Bei jedem zentralen Schritt zuerst den Code und danach die entstandene
Tabelle erläutern: Was ist eine Zeile, welche Spalten sind neu, was folgt
daraus?

Die Kapitelanzeige markiert den aktuellen Abschnitt und die Position darin.
Für die übrigen Abschnitte gibt es keine festen Minutenbudgets.

## Begriffe und Verständnisfragen

- **IQB-Studio**, **Testcenter** und **Kodierschema** konsistent benennen.
- Was unterscheidet eine Antwortvariable von einem Auswertungsitem?
- Warum können Code-ID und Score unterschiedliche Werte haben?
- Welche fehlenden Antworten ergänzt das Testdesign?
- Welche Information geht verloren, wenn nur der Skalierungsdatensatz
  gespeichert wird?
- Warum ist ein offener Fokusverlust keine beobachtete Dauer von null?

Der Stil bleibt sachlich und zugänglich. Begriffe werden am konkreten
Objekt erklärt; unnötige Sicherheitsprüfungen oder wiederholte
Funktionsübersichten unterbrechen den Ablauf nicht.

## Wiedereinstieg und eigene Daten

Die Dateien unter `Daten/Ergebnisse/` entstehen beim Ausführen von Skript `03`.
Log- und Codebuchskripte können unabhängig ausgeführt werden. Für eigene
Daten zunächst Pfade, Metadatenstand, Kennungen und Bereichszuordnung
anpassen. Missing-Regeln und Personenauswahl werden anhand des
Auswertungsplans festgelegt und dokumentiert.

Codeänderungen erfolgen in den R-Skripten. `scripts/snippets.json`
ordnet die Abschnitte für Folien, Handout und Vorbereitung über Textanker
zu; `scripts/sync_snippets.py` übernimmt den Abgleich.

## Prüfung vor Durchführung

- Die lokalen Skripte laufen aus dem Projektordner durch.
- Code, Objektauszüge, Logos, Screenshots und Downloads sind lesbar.
- Excel-Codebuch und exportierte Daten lassen sich öffnen und erklären.
- Die Beispiele sind ohne IQB-Studio- oder Testcenter-Konto nachvollziehbar.
- Datum, Vortragende und gegebenenfalls Demo-Workspace sind eingetragen.

Einige Screenshots zeigen frühere Oberflächen. Neue Abbildungen erhalten
einen Herkunftsnachweis in `assets/README.md`.
