# eatPrepTBA-Workshop

Materialien zum Workshop **Vom Testcenter zum Skalierungsdatensatz**:
Quarto-Folien, Handout, kommentierte R-Skripte und synthetische Beispieldaten.
R-Grundkenntnisse werden vorausgesetzt. Die lokalen Beispiele benötigen
keinen Zugang zu IQB-Studio oder Testcenter.

**Karoline Sachse · IQB Methoden-Team · 26.10.2026**

[Workshop-Repository](https://github.com/sachseka/eatPrepTBAworkshop) ·
[eatPrepTBA-Dokumentation](https://iqb-research.github.io/eatPrepTBA/) ·
[eatPrepTBA-Repository](https://github.com/iqb-research/eatPrepTBA)

## Einstieg

1. Repository herunterladen oder klonen und `WSeatPrepTBA.Rproj` öffnen.
2. Pakete gemäß [Vorbereitung](setup.qmd) installieren und
   [00_installation.R](R/00_installation.R) ausführen.
3. Die passenden R-Skripte mit den Folien und dem [Handout](handout.qmd)
   Schritt für Schritt nachvollziehen.

Die [PDF-Folien](downloads/workshop.pdf) sind ohne R lesbar. Das
[Materialpaket](downloads/WSeatPrepTBA-material.zip) enthält Daten,
R-Skripte, Zwischenstände und Quarto-Quellen. Zum Rendern der HTML-Fassung
gelten die Hinweise weiter unten.

## Themen und Skripte

Der Workshop behandelt Paketaufbau und Datenquellen, die Aufbereitung für
die Skalierung, ausgewählte Logauswertungen und Codebücher. Die Skripte
sind linear aufgebaut; nach wichtigen Schritten zeigen Objektauszüge die
entstandenen Tabellen.

| Skript | Inhalt |
|---|---|
| [00_installation.R](R/00_installation.R) | Installation und Funktionstest |
| [01_datenabruf.R](R/01_datenabruf.R) | Vorlage für eigene IQB-Studio- und Testcenter-Zugänge |
| [02_daten_verstehen.R](R/02_daten_verstehen.R) | JSON, Partial Credit und gespeicherte Codes |
| [03_datenaufbereitung.R](R/03_datenaufbereitung.R) | Antworten bis zum Skalierungsdatensatz aufbereiten |
| [04_logs.R](R/04_logs.R) | Ereignisse, Zeiten und Fokusverluste |
| [05_kodiermanuale.R](R/05_kodiermanuale.R) | Lokales Codebuch als Excel und CSV |
| [06_kodiermanuale_studio.R](R/06_kodiermanuale_studio.R) | Codebuch und DOCX direkt aus IQB-Studio |

Die beiden API-Vorlagen benötigen eigene Zugangsdaten sowie angepasste
Server- und Workspace-Angaben. Sie werden beim Rendern nicht ausgeführt.
Für eigene Studien sind außerdem Kennungen, Bereichszuordnung und
Missing-Regeln anzupassen.

## Materialien neu erzeugen

Benötigt werden Quarto CLI, Python 3 sowie die R-Pakete aus der
[Vorbereitung](setup.qmd), zusätzlich `knitr` und `rmarkdown`. Im Projektordner:

```bash
quarto render
quarto preview
```

Vor dem Rendern übernimmt `scripts/sync_snippets.py` die markierten
Codeabschnitte aus `R/` in Folien und Handout. Änderungen an diesen
Codeblöcken werden deshalb in den R-Dateien vorgenommen. Die lokalen
Beispiele werden beim Rendern berechnet; die Website entsteht in `_site/`.

Die Folien enthalten eine klickbare Kapitelübersicht mit der Position im
Abschnitt. Zum PDF-Export die Druckansicht der Folien (`?print-pdf`) verwenden
und die Datei als `downloads/workshop.pdf` speichern. Anschließend
`python scripts/package_materials.py` ausführen; das aktualisiert das
Materialpaket und die vorbereitete Einbindung für IQB-Methods.

Die Generatoren `scripts/generate_data.R` und
`scripts/generate_demonstration_data.R` erzeugen die synthetischen Daten
neu und überschreiben deren lokale Dateien. Für die normale Nutzung sind
die Daten bereits enthalten. Die Arbeitsskripte schreiben nach `outputs/`
und `checkpoints/`.

## Datenstand und Quellen

Materialstand: 18.10.2026. Paketbasis: eatPrepTBA 0.9.8.9041
(Commit `5e1a0ac`). `renv.lock` dokumentiert die Paketversionen;
[VALIDATION.md](VALIDATION.md) beschreibt die durchgeführten Prüfungen.

Die synthetische Lesestudie umfasst sechs Units, acht Items, zwei Booklets
und 40 vorgesehene Personen. Ein separates Partial-Credit-Beispiel mit vier
erfundenen Personen folgt dem verlinkten IQB-Studio-Tutorial. Diese Daten
sind keine Originalexporte einer realen Erhebung.

Herkunft und Nutzungszusammenhang der Logos und Screenshots stehen unter
[assets/README.md](assets/README.md). Die Codegestaltung orientiert sich
am eatPrep-Workshop 2024. Einige Abbildungen zeigen frühere Oberflächen.

## Rückmeldungen

Korrekturen an den Materialien können als
[Workshop-Issue](https://github.com/sachseka/eatPrepTBAworkshop/issues)
eingetragen werden. Bei Fehlern oder Funktionswünschen zu eatPrepTBA
gehört die Rückmeldung in die
[Paket-Issues](https://github.com/iqb-research/eatPrepTBA/issues).
Hilfreich sind Paketversion, betroffener Schritt, Fehlermeldung und ein
kleines Beispiel ohne vertrauliche Daten.
