# Workshop eatPrepTBA – inhaltlicher Plan

Der Workshop erklärt den Weg von Antworten im Testcenter und Metadaten
aus IQB-Studio zum Skalierungsdatensatz. Der Umfang richtet sich nach den
Inhalten und Fragen; es gibt keine festen Zeitvorgaben und keine getrennten
Übungsblöcke. R-Grundkenntnisse reichen aus. Eigene Serverzugänge sind für
die lokalen Beispiele nicht erforderlich.

## 1. Paketaufbau, Daten und Schnittstellen

- Paketdokumentation, GitHub-Repository und Issues als Anlaufstellen zeigen.
- eatPrepTBA, eatAutoCode und den IQB-Autocoder einordnen.
- IQB-Studio-Metadaten, Testcenter-Antworten und Testdesign unterscheiden.
- Abrufvorlagen zeigen; API, RDS, CSV und JSON am Ergebnis erklären.
- An der Rechenaufgabe Antwortvariablen, Kodierschema und abgeleitetes
  Item verbinden. Die synthetischen Daten entsprechen den gezeigten Regeln.
- `prepare_responses()` und `prepare_coded()` vom erneuten Kodieren trennen.

Die Funktionsreferenz bleibt im Handout verlinkt. Wiederholte vollständige
Funktionslisten sind im Vortrag nicht erforderlich.

## 2. Datenaufbereitung

Die separate synthetische Lesestudie enthält sechs Units, acht Items und
40 vorgesehene Personen. `R/03_datenaufbereitung.R` bildet den vollständigen
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

## 3. Logdaten

`R/04_logs.R` bleibt ein kompakter Überblick: Ereignistypen, Auffälligkeiten,
Bearbeitungs- und Ladezeiten sowie Fokusverluste. P001 zeigt einen
auswertbaren Verlauf; P002 zeigt fehlende oder offene Ereignisfolgen.
Fehlende Zeitwerte sind keine Nullwerte. Fokusverluste und QC-Flags werden
als Beschreibungen des protokollierten Verlaufs eingeordnet.

## 4. Codebücher und Kodiermanuale

`R/05_kodiermanuale.R` wählt Einträge einer lokalen Codebuchtabelle aus und
exportiert sie als Excel und CSV. `R/06_kodiermanuale_studio.R` zeigt kurz
den Abruf mit `prepare_codebook()` und den direkten DOCX-Download mit
`download_codebook()`. Diese API-Vorlage benötigt einen eigenen Zugang.
Ein lokal erzeugtes Word-Beispiel ist nicht Bestandteil des Workshops.

## Materialien und Prüfung

Folien, Handout und R-Skripte verwenden dieselben markierten Codeabschnitte.
Das Paketlogo, lesbare Codeblöcke, berechnete Objektauszüge und die
Kapitelanzeige unterstützen die Orientierung. Die Titelfolie enthält keine
Kapitelanzeige. Die Quellen der Abbildungen stehen in `assets/README.md`.

Die Prüfung umfasst die lokalen R-Abläufe, die Ergebnisse der synthetischen
Fälle, die Übereinstimmung der Codeblöcke, Browseransicht, PDF und Downloads.
Live-API-Aufrufe sind davon ausgenommen. Der aktuelle Nachweis steht in
`VALIDATION.md`.
