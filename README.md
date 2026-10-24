# eatPrepTBA-Workshop

Materialien zum Workshop **Vom Testcenter zum Skalierungsdatensatz**:
Quarto-Folien, Handout, kommentierte R-Skripte und synthetische Beispieldaten.
R-Grundkenntnisse werden vorausgesetzt. Die lokalen Beispiele benötigen
keinen Zugang zu IQB-Studio oder Testcenter.

**Karoline Sachse · IQB Methoden-Team · 26.10.2026**

[Folien im Browser](https://sachseka.github.io/eatPrepTBAworkshop/workshop.html) ·
[Materialseite](https://sachseka.github.io/eatPrepTBAworkshop/) ·
[Materialpaket herunterladen](https://github.com/sachseka/eatPrepTBAworkshop/raw/refs/heads/main/downloads/WSeatPrepTBA-material.zip) ·
[eatPrepTBA-Dokumentation](https://iqb-research.github.io/eatPrepTBA/) ·
[eatPrepTBA-Repository](https://github.com/iqb-research/eatPrepTBA)

## Einstieg

1. [Materialpaket herunterladen](https://github.com/sachseka/eatPrepTBAworkshop/raw/refs/heads/main/downloads/WSeatPrepTBA-material.zip),
   vollständig entpacken und `WSeatPrepTBA.Rproj` öffnen.
2. [00_installation.R](R/00_installation.R) öffnen und die Abschnitte gemäß
   [Vorbereitung](https://sachseka.github.io/eatPrepTBAworkshop/setup.html) einzeln ausführen: bei Bedarf installieren,
   dann Versionen abfragen, Pakete laden und Beispieldateien prüfen.
3. Die passenden R-Skripte mit den [Folien](https://sachseka.github.io/eatPrepTBAworkshop/workshop.html)
   und dem [Handout](https://sachseka.github.io/eatPrepTBAworkshop/handout.html)
   Schritt für Schritt nachvollziehen.

Die [PDF-Folien](downloads/workshop.pdf) sind ohne R lesbar. Das
[Materialpaket](downloads/WSeatPrepTBA-material.zip) enthält Daten,
R-Skripte, Zwischenstände und Quarto-Quellen. Die Online-Folien lassen sich
ohne Installation direkt im Browser öffnen.

## Ablauf

| Abschnitt | Inhalt |
|---|---|
| 0 · Einstieg | Materialien herunterladen, R-Projekt öffnen, Pakete vorbereiten |
| 1 · Paket & erste Kodierung | Datenquellen, API-Abruf, R-Objekte und Rechenbeispiel mit Partial Credit |
| 2 · Studie & Skalierung | Lesestudie aufbereiten, Missing-Regeln, psychometrische Kennwerte und Skalierungsdatensatz |
| 3 · Logs & Codebücher | Ereignisse, Zeiten und Fokusverluste; Codebücher und Kodiermanuale |

Nach Abschnitt 1 und Abschnitt 2 folgen jeweils etwa zehn Minuten zum
eigenständigen Ausführen der Skripte und eine kurze Fragerunde. Die erste
Phase gehört zu `02_daten_verstehen.R`, die zweite zu `03_datenaufbereitung.R`.

## Themen und Skripte

Der Workshop behandelt Paketaufbau und Datenquellen, die Aufbereitung für
die Skalierung, ausgewählte Logauswertungen und Codebücher. Die Skripte
sind linear aufgebaut; nach wichtigen Schritten zeigen Objektauszüge die
entstandenen Tabellen.

| Skript | Inhalt |
|---|---|
| [00_installation.R](R/00_installation.R) | Installation, Paketversionen und Beispieldateien |
| [01_datenabruf.R](R/01_datenabruf.R) | Vorlage für eigene IQB-Studio- und Testcenter-Zugänge |
| [02_daten_verstehen.R](R/02_daten_verstehen.R) | JSON, Partial Credit und gespeicherte Codes |
| [03_datenaufbereitung.R](R/03_datenaufbereitung.R) | Antworten bis zum Skalierungsdatensatz aufbereiten |
| [04_logs.R](R/04_logs.R) | Ereignisse, Zeiten und Fokusverluste |
| [05_kodiermanuale.R](R/05_kodiermanuale.R) | Lokales Codebuch als Excel und CSV |
| [06_kodiermanuale_studio.R](R/06_kodiermanuale_studio.R) | Codebuch und DOCX direkt aus IQB-Studio |

Die beiden API-Vorlagen benötigen eigene Zugangsdaten sowie angepasste
Server- und Workspace-Angaben. Die eingetragenen Werte sind Beispiele.
Die Vorlagen werden im lokalen Workshop und beim Rendern nicht ausgeführt.
Für eigene Studien sind außerdem Kennungen, Bereichszuordnung und
Missing-Regeln anzupassen.

`library(eatPrepTBA)` lädt eatAutoCode intern mit. eatAutoCode nicht separat
laden, damit `code_responses()` aus eatPrepTBA verwendet wird. Die erste
Kodierung wird im Rechenbeispiel von Skript `02` überprüft.

## Materialien neu erzeugen

Benötigt werden Quarto CLI, Python 3 sowie die R-Pakete aus der
[Vorbereitung](setup.qmd), zusätzlich `knitr` und `rmarkdown`. Im Projektordner:

```bash
quarto render
quarto preview
```

Vor dem Rendern übernimmt `scripts/sync_snippets.py` die in
`scripts/snippets.json` festgelegten Codeabschnitte aus `R/` in Vorbereitung,
Folien und Handout. Änderungen an diesen
Codeblöcken werden deshalb in den R-Dateien vorgenommen. Die lokalen
Beispiele werden beim Rendern berechnet; die Website entsteht in `_site/`.

Die Folien enthalten eine klickbare Kapitelübersicht mit der Position im
Abschnitt. Zum PDF-Export die Druckansicht der Folien (`?print-pdf`) verwenden
und die Datei als `downloads/workshop.pdf` speichern. Anschließend
`python scripts/package_materials.py` ausführen; das aktualisiert das
Materialpaket und die vorbereitete Einbindung für IQB-Methods.

Nach Rendering, PDF-Export und Aktualisierung des Materialpakets wird der
geprüfte Inhalt von `_site/` mit folgendem Befehl veröffentlicht:

```bash
quarto publish gh-pages --no-render --no-prompt --no-browser
```

GitHub Pages verwendet dafür den Branch `gh-pages`. Die Quelltexte bleiben
auf `main`; auf GitHub ist kein erneuter R-Durchlauf erforderlich.

Die Generatoren `scripts/generate_data.R` und
`scripts/generate_demonstration_data.R` erzeugen die synthetischen Daten
neu und überschreiben deren lokale Dateien. Für die normale Nutzung sind
die Daten bereits enthalten. Die Arbeitsskripte schreiben nach `outputs/`
und `checkpoints/`.

## Datenstand und Quellen

Materialstand: 24.10.2026. Verwendet werden eatPrepTBA 0.9.8.9042
(Commit `ea782df`), eatAutoCode 0.5.0.9008 (Commit `54f39a8`)
und IQB-Autocoder 5.5.0. Die Installation bezieht den aktuellen GitHub-Stand;
`renv.lock` dokumentiert die genaue Paketumgebung des Workshops.
[VALIDATION.md](VALIDATION.md) beschreibt die durchgeführten Prüfungen.

Die synthetische Lesestudie umfasst sechs Units, acht Items, zwei Booklets
und 40 vorgesehene Personen. Ein separates Partial-Credit-Beispiel mit vier
erfundenen Personen folgt dem verlinkten IQB-Studio-Tutorial. Diese Daten
sind keine Originalexporte einer realen Erhebung.

Herkunft und Nutzungszusammenhang der Logos und Screenshots stehen unter
[assets/README.md](assets/README.md). Die Codegestaltung orientiert sich
am eatPrep-Workshop 2024. Einige Abbildungen zeigen frühere Oberflächen.

## Rückmeldungen

Jede Rückmeldung ist willkommen, auch zu unklaren Formulierungen,
umständlichen Arbeitsschritten oder unerwartetem Verhalten. Hinweise zu
den Materialien können als
[Workshop-Issue](https://github.com/sachseka/eatPrepTBAworkshop/issues)
eingetragen werden. Bei Fehlern oder Funktionswünschen zu eatPrepTBA
gehört die Rückmeldung in die
[Paket-Issues](https://github.com/iqb-research/eatPrepTBA/issues).
Hilfreich sind Paketversion, betroffener Schritt, Fehlermeldung und ein
kleines Beispiel ohne vertrauliche Daten.
