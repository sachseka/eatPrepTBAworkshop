# Workshop eatPrepTBA – inhaltlicher Plan

Der Workshop erklärt den Weg von Antworten im Testcenter und Metadaten
aus IQB-Studio zum Skalierungsdatensatz. Drei Pausen von jeweils etwa
zehn Minuten geben Gelegenheit, die bis dahin gezeigten Skripte auszuführen.
Danach folgt jeweils eine kurze Fragerunde. Der übrige Umfang richtet sich
nach den Inhalten und Fragen. R-Grundkenntnisse reichen aus; eigene
Serverzugänge sind für die lokalen Beispiele nicht erforderlich.

## 0. Einstieg und Vorbereitung

Materialseite, Folien und Downloadpaket zeigen; das entpackte R-Projekt
öffnen. Die Vorbereitung erfolgt abschnittsweise in `Syntaxen/00_installation.R`:
Pakete bei Bedarf installieren, Versionen abfragen, Pakete laden und Dateien
prüfen. Das Materialpaket enthält nur `Syntaxen/`, `Daten/` und die
Projektdatei. Die PDF-Folien werden separat heruntergeladen.

## 1. Paket und erste Kodierung

- Paketdokumentation, GitHub-Repository und Issues als Anlaufstellen zeigen.
- eatPrepTBA, eatAutoCode und den [IQB-Autocoder](https://github.com/iqb-berlin/responses) einordnen.
- IQB-Studio-Metadaten, Testcenter-Antworten und Testdesign unterscheiden.
- Zunächst die IQB-Studio-Themen zusammenhängend behandeln: Version,
  Workspace, Anmeldung, Aufgabenabruf und verschachtelte Unit-Tabellen.
- `get_coding_report()` als Prüfbericht und `add_metadata()` zur Aufbereitung
  geladener Metadaten zeigen. Für das Offlinebeispiel liegen synthetische
  Ausgaben vor; Profildefinitionen können Internetzugriff erfordern.
- An der Rechenaufgabe Basisvariablen, Item-Verknüpfung und Kodierschema
  erklären. Die Partial-Credit-Regeln zuerst in IQB-Studio und danach in R
  nachvollziehen; dafür werden noch keine Antworten geladen.
- Anschließend zum Testcenter wechseln: Workspace-ID, Testmodus,
  Antwortabruf und vollständiges Testdesign erläutern.
- Die lokalen Antworten in `Syntaxen/02_daten_verstehen.R` laden,
  JSON ansehen und mit `prepare_responses()` entpacken.
- Mit dem zuvor erklärten Kodierschema neu kodieren und das Auswertungsitem
  auswählen. Das Einlesen bereits gespeicherter Codes mit `prepare_coded()`
  bleibt als optionaler Abschnitt in Skript und Handout; die eigene Folie entfällt.

Die Funktionsreferenz bleibt im Handout verlinkt. Wiederholte vollständige
Funktionslisten sind im Vortrag nicht erforderlich.

**Pause und Ausprobieren, etwa zehn Minuten:** Skripte `00`, `01` und `02`
ansehen. In `00` Pakete laden und Dateien prüfen, anschließend `02` ausführen,
sofern noch nicht parallel geschehen. `01` bleibt eine Vorlage für eigene
Zugänge. Anschließend folgt die Folie **„Fragen?“**.

## 2. Beispiel 2: Kennwerte und Skalierungsdatensatz

Die separate synthetische Lesestudie enthält sechs Units, acht Items und
40 vorgesehene Personen. `Syntaxen/03_datenaufbereitung.R` bildet den vollständigen
Ablauf ab:

1. Antworten, Units und Testdesign einlesen.
2. Automatisch kodieren und manuelle Codes ergänzen.
3. Vorgesehene Fälle vervollständigen und Missing-Regeln vergleichen.
4. Personen auswählen und Variablen mit Items verknüpfen.
5. Missing-Anteile und codebezogene Kennwerte berechnen.
6. Den Skalierungsdatensatz, Kennungen und Long-Daten exportieren.

Nach jedem zentralen Verarbeitungsschritt steht ein berechneter
Objektauszug. Er zeigt die neue Zeilenstruktur und die benötigten Spalten.
Code-ID und Score werden getrennt erläutert. Die Missing-Arten bleiben in
den Long-Daten erhalten, auch wenn im Skalierungsdatensatz `NA` steht.
Die kleine Lehrstudie erklärt den Rechenweg; sie dient nicht der empirischen
Itembewertung.

**Pause und Ausprobieren, etwa zehn Minuten:** `Syntaxen/03_datenaufbereitung.R`
bis zum Export ausführen, sofern noch nicht parallel geschehen. Danach
folgt erneut die Folie **„Fragen?“**.

## 3. Logs und Codebücher

### Logdaten

`Syntaxen/04_logs.R` bleibt ein kompakter Überblick: Ereignistypen, Auffälligkeiten,
Bearbeitungs- und Ladezeiten sowie Fokusverluste. P001 zeigt einen
auswertbaren Verlauf; P002 zeigt fehlende oder offene Ereignisfolgen.
Fehlende Zeitwerte sind keine Nullwerte. Fokusverluste und QC-Flags werden
als Beschreibungen des protokollierten Verlaufs eingeordnet.

### Codebücher und Kodiermanuale

Ein Codebuch macht die Kodierschemata einer Studie als Dokumentation der
Codes und Bewertungen für die Auswertung und Weitergabe lesbar.
`Syntaxen/06_kodiermanuale_studio.R` zeigt zuerst, wie `prepare_codebook()` das
Codebuch aus den Kodierschemata in IQB-Studio erstellt. Anschließend folgt
kurz der direkte DOCX-Download mit `download_codebook()`.

Für die lokale Demonstration ohne Zugang verwendet
`Syntaxen/05_kodiermanuale.R` eine vorbereitete synthetische Tabelle. Daran werden
Auswahl und Export als Excel und CSV gezeigt. Diese Tabelle ersetzt nur
den Abruf im Workshop; bei eigenen Studien entsteht das Codebuch direkt
aus den Kodierschemata. Ein lokal erzeugtes Word-Beispiel entfällt.

**Pause und Ausprobieren, etwa zehn Minuten:** Skripte `04` und `05`
ausführen und die Ergebnisse ansehen. Skript `06` bleibt wie `01` eine
Vorlage für eigene Zugänge. Anschließend folgt die dritte Folie **„Fragen?“**.

## Materialien und Prüfung

Vorbereitung, Folien und Handout übernehmen den Code aus den R-Skripten.
Die Bereiche sind über Textanker in `scripts/snippets.json` zugeordnet;
technische Markierungen in den Teilnehmer-Skripten entfallen. Die Skripte
enthalten kurze nummerierte Abschnitte und knappe Kommentare.
CSV-Ergebnisse werden mit `write.csv2(..., row.names = FALSE)` für deutsches
Excel exportiert. Eine vorangestellte `sep=;`-Zeile gibt das Trennzeichen vor;
UTF-16LE erhält Umlaute. Beim Rückimport der Ergebnis-CSV in R ist `skip = 1`
erforderlich. Eingabedateien behalten ihr ursprüngliches Format.
Das Paketlogo, lesbare Codeblöcke, berechnete Objektauszüge und die
Kapitelanzeige unterstützen die Orientierung. Die Titelfolie enthält keine
Kapitelanzeige. Die Quellen der Abbildungen stehen in `assets/README.md`.

Die Prüfung umfasst die lokalen R-Abläufe, die Ergebnisse der synthetischen
Fälle, die Übereinstimmung der Codeblöcke, Browseransicht, PDF und Downloads.
Live-API-Aufrufe sind davon ausgenommen. Der aktuelle Nachweis steht in
`VALIDATION.md`.
