# Technische Prüfung der Workshop-Materialien

Stand: 18.10.2026. Die lokalen R-Prüfungen, das Quarto-Rendering und die
Browserprüfung sind erfolgreich abgeschlossen.

## Ergebnis

- Vier R-Prüfskripte erfolgreich: Rechenaufgabe, vollständige Aufbereitung,
  Ausführung der Folienblöcke sowie Log- und Excel-Ergebnisse.
- 43 lokale Folien-Codeblöcke in ihrer Reihenfolge ausgeführt;
  131 eingebettete Abschnitte in Folien und Handout mit den R-Dateien abgeglichen.
- Kategorie-, Code- und Scorehäufigkeiten des MC-Beispiels geprüft.
- 24 verwendete Paketfunktionen statisch geprüft, keine Argumentprobleme.
- 77 Folien und 77 PDF-Seiten; keine Inhalts- oder Codeüberläufe,
  JavaScript-Fehler, fehlgeschlagenen Ressourcen oder Navigationsprobleme.
- Titelfolie ohne Kapitelanzeige und Footer; die übrigen 76 PDF-Seiten
  enthalten die Abschnittsnavigation.

## Dokumentierte Umgebung

- R 4.5.1, Windows; eatPrepTBA 0.9.8.9041 aus Commit
  `5e1a0ac1fe736bcafd6338231bf57df1172c9d56`.
- eatAutoCode 0.5.0.9006 mit IQB-Autocoder `@iqb/responses` 5.2.2.
- writexl 1.5.4 für den Excel-Export.
- `renv.lock` hält die Paketversionen fest;
  `outputs/session-info.txt` dokumentiert die verwendete R-Umgebung.

## Datenaufbereitung und Beispiele

- `scripts/validate_workflow.R` prüft die erwarteten Ergebnisse der
  synthetischen Lesestudie: automatische und manuelle Kodierung,
  Ableitungen, Missing-Regeln, Personenauswahl und Exporte.
- `scripts/validate_demonstration_data.R` prüft JSON-Import,
  gespeicherte Codes und Partial Credit der separaten Rechenaufgabe.
- Die Kategorie-, Code- und Scoreauswertungen des Multiple-Choice-Items
  werden anhand der tatsächlichen Antwortverteilungen geprüft.
  Kategoriehäufigkeiten und Codehäufigkeiten haben unterschiedliche
  Bedeutungen; die gültigen Scorewerte bestimmen den Nenner der Anteile.
- `scripts/validate_slide_code.R` führt die lokalen Folienblöcke in
  ihrer Reihenfolge aus. `scripts/sync_snippets.py --check` vergleicht
  die eingebetteten Codeabschnitte mit den verteilbaren R-Skripten.

## Logs und Codebuch

- `scripts/validate_exports.R` prüft Bearbeitungs- und Ladezeiten,
  abgeschlossene und offene Fokusverluste sowie den Excel-Export.
- Der Excel-Export wird mit `openxlsx` unabhängig eingelesen; geprüft
  werden Tabellenblätter, Unit-Auswahl und Code-/Scorezuordnungen.
- Die DOCX-Erstellung aus lokalem Manualtext ist entfernt. Enthalten
  ist ausschließlich die nicht ausgeführte Vorlage mit
  `download_codebook(..., format = "docx")` aus IQB-Studio.
- Die API-Vorlagen werden syntaktisch und anhand der verwendeten
  Funktionssignaturen geprüft; sie gehören nicht zum lokalen Ablauf.

## Folien, Website und Materialien

- Quarto-Dokumente rendern und berechnete Objektausgaben prüfen.
- Folien im Browser auf Inhalts- und Codeüberläufe, JavaScript-Fehler
  sowie fehlgeschlagene Ressourcen prüfen.
- Kapitelanzeige, Position im Abschnitt und Kapitelsprünge prüfen;
  Titelfolie ohne Kapitelanzeige und Footer ausgeben.
- PDF neu erzeugen und Lesbarkeit von Text, Code und Ergebnissen prüfen.
- Materialpaket und IQB-Methods-Payload aktualisieren; lokale Links und
  Archivdateien mit `scripts/check_material_links.py` prüfen.
- Kommentarfassungen, lokale Paketbibliotheken, Arbeitsarchive und
  überholte DOCX-Ausgaben aus der Veröffentlichung ausschließen.

## Grenzen

Live-Anmeldung und Downloads mit tatsächlichen IQB-Studio- oder
Testcenter-Zugängen werden nicht ausgeführt. Die Demonstrationen nutzen
synthetische lokale Daten. Ein vollständiger Neuaufbau der Paketumgebung
aus dem Internet ist nicht Bestandteil dieser Prüfung.

Die Einbindung in IQB-Methods ist vorbereitet; deren Hauptwebsite-Build
und Veröffentlichung gehören nicht zur lokalen Workshopprüfung.
