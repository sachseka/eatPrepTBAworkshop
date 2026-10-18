# Einbindung in IQB-Methods

Zielstruktur im bestehenden Repository:

```
docs/R_tutorials/eatPrepTBA2026.qmd
docs/R_tutorials/eatPrepTBA2026_files/   # vollständiger Inhalt von _site/
```

Die gerenderte Unterseite enthält relative Links und lokal eingebundene Schriften.
So bleiben die Materialien innerhalb der IQB-Methods-Domain; Quelltexte, Daten und
renv.lock stehen im Downloadpaket bereit. Der Hauptwebsite-Build muss die
Workshop-R-Pakete dadurch nicht erneut installieren oder ausführen.

Die Materialseite enthält das originale eatPrepTBA-Paketlogo und direkte Links
auf alle Arbeitsskripte: Datenaufbereitung, Datenabruf, Logs, lokale Codebücher
und Codebücher aus IQB-Studio. Die lokalen Beispiele einschließlich Excel-Export
benötigen keine IQB-Studio- oder Testcenter-Konten. Der DOCX-Download ist eine
Vorlage für die spätere Nutzung mit eigenem IQB-Studio-Zugang.

## Vorbereitete Änderungen

1. `eatPrepTBA2026.qmd` nach `docs/R_tutorials/` kopieren.
2. Den vollständigen Inhalt des Workshop-Ordners `_site/` nach
   `docs/R_tutorials/eatPrepTBA2026_files/` kopieren.
3. In `docs/eat_workshops.qmd` unter `listing.contents` ergänzen:

```yaml
    - "R_tutorials/eatPrepTBA2026.qmd"
```

4. In der **bestehenden** `_quarto.yml` unter `project` die Ressource ergänzen
   (vorhandene Ressourcen beibehalten):

```yaml
project:
  type: website
  resources:
    - docs/R_tutorials/eatPrepTBA2026_files/**
```

Die Workshop-Quellen außerhalb des ZIP nicht zusätzlich in diesen Ressourcenordner
legen: Sonst könnte der Hauptbuild sie erneut als Website-Seiten behandeln.

## Review und Veröffentlichung

Ein Patch für die zwei vorhandenen Dateien liegt in `iqb-methods.patch`.
Die Angaben wurden gegen den am 23.09.2026 gelesenen main-Stand geprüft.
Vor Anwendung auf einen neueren Stand `git apply --check` verwenden.

Die bestehende IQB-Methods-Pipeline baut PRs und bietet für Branches im Repository
eine Vorschau unter `pr-preview/pr-<Nummer>/`. Nach Merge nach main wird die
Hauptwebsite veröffentlicht. Der vollständige Hauptwebsite-Build wurde im Rahmen
dieses Workshop-Projekts nicht ausgeführt; nur die Einbindung wird lokal geprüft.

Materialstand ist der 18.10.2026; die Paketbasis ist eatPrepTBA 0.9.8.9041
(Commit `5e1a0ac`). Die technische Prüfung steht in `VALIDATION.md`.

Die Workshop-Quellen werden im Repository
[eatPrepTBAworkshop](https://github.com/sachseka/eatPrepTBAworkshop) gepflegt.
Vor Veröffentlichung Workshop-Termin, Vortragende und Kennzeichnung als
Arbeitsfassung prüfen. Ein didaktischer Durchlauf prüft die Verständlichkeit
der Beispiele. Aktuelle Testcenter-Screenshots können im Review ergänzt werden.

`scripts/package_materials.py` erstellt den kopierfertigen Ordner unter
`integration/payload/` nach dem Rendern neu. Nur dieser generierte Zielordner
wird ersetzt. Kommentarfassungen, archivierte Übungen, lokale Paketbibliotheken
und verschachtelte Integrationsordner werden nicht veröffentlicht.
