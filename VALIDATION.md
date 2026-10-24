# Technische Prüfung der Workshop-Materialien

Stand: 24.10.2026. Die lokalen R-Prüfungen, das Quarto-Rendering und die
Browserprüfung sind erfolgreich abgeschlossen.

## Ergebnis

- Vier R-Prüfskripte erfolgreich: Rechenaufgabe, vollständige Aufbereitung,
  Ausführung der Folienblöcke sowie Log- und Excel-Ergebnisse.
- 51 lokale Folien-Codeblöcke in ihrer Reihenfolge ausgeführt;
  160 eingebettete Abschnitte in Folien, Handout und Vorbereitung mit den R-Dateien abgeglichen.
- 104 Codebereiche über eindeutige Textanker in `scripts/snippets.json` geprüft;
  die R-Skripte benötigen keine technischen Abschnittsmarker mehr.
- Kategorie-, Code- und Scorehäufigkeiten des MC-Beispiels geprüft.
- 26 verwendete Paketfunktionen statisch geprüft, keine Argumentprobleme.
- 101 Folien und 101 PDF-Seiten; keine Inhalts- oder Codeüberläufe,
  JavaScript-Fehler, fehlgeschlagenen Ressourcen oder Navigationsprobleme.
- Titelfolie ohne Kapitelanzeige und Footer; die übrigen 100 PDF-Seiten
  enthalten die Abschnittsnavigation.
- Einstieg und drei Arbeitsblöcke in der Navigation; drei Ausführungsphasen
  von ca. zehn Minuten, jeweils unmittelbar gefolgt von „Fragen?“.
- Block 1 behandelt zuerst IQB-Studio, Metadaten und Kodierschema,
  danach Testcenter und Antwortdaten. Das lokale Laden von Units und Antworten
  ist entsprechend getrennt. Das zusätzliche Beispiel zu `prepare_coded()`
  bleibt eine optionale Vertiefung in Skript und Handout.
- Alle Inhaltslinks der Folien öffnen ein neues Tab; Kapitelsprünge
  bleiben innerhalb der Präsentation.
- Die öffentliche Materialseite liegt unter
  https://sachseka.github.io/eatPrepTBAworkshop/; Folien und Downloads
  werden aus dem geprüften statischen Build auf `gh-pages` bereitgestellt.

## Dokumentierte Umgebung

- R 4.5.1, Windows; eatPrepTBA 0.9.8.9042 aus Commit
  `ea782df422f1aea853704dcfce7533273b429ba2`.
- eatAutoCode 0.5.0.9008 (`54f39a8e94f9a4d7e6fc05ccbfc607f183609b5a`)
  mit IQB-Autocoder `@iqb/responses` 5.5.0.
- writexl 2.0.1 für den Excel-Export.
- `renv.lock` hält die Paketversionen fest;
  `Daten/Ergebnisse/session-info.txt` dokumentiert die verwendete R-Umgebung.

## Datenaufbereitung und Beispiele

- `scripts/validate_workflow.R` prüft die erwarteten Ergebnisse der
  synthetischen Lesestudie: automatische und manuelle Kodierung,
  Ableitungen, Missing-Regeln, Personenauswahl und Exporte.
- Die Freitextantworten in `codes_manual$value` stimmen mit U4/TEXT in
  den Rohantworten überein. Die zusätzliche Spalte funktioniert bei der
  manuellen Kodierung; Skalierungsdaten und Kennwerte bleiben unverändert.
- Alle sieben Arbeitsskripte syntaktisch geprüft; in R00 wurden Versionsabfragen,
  Laden der Pakete und Dateiprüfung ohne erneute Installation ausgeführt.
- `scripts/validate_demonstration_data.R` prüft JSON-Import,
  gespeicherte Codes und Partial Credit der separaten Rechenaufgabe.
- Kodierschema-Prüfbericht und Metadatenvorschau sind ausdrücklich synthetisch.
  Die echten Aufrufe `get_coding_report()` und `add_metadata()` stehen in der
  API-Vorlage; Profildefinitionen können Internetzugriff erfordern.
- CSV-Exporte verwenden `write.csv2()` ohne Zeilennamen, mit Semikolon,
  Dezimalkomma, UTF-16LE und einer vorangestellten Zeile `sep=;`.
  Beim Rückimport wird diese Zeile mit `skip = 1` übersprungen.
- Direkter CSV-Aufruf in Microsoft Excel 16.0 geprüft: Das bisherige Format
  reproduziert den Fehler mit nur einer Spalte; die neue Variante trennt
  korrekt und erhält Umlaute sowie numerische Werte. Keine bestehenden
  Arbeitsmappen oder Excel-Einstellungen wurden verändert.
- Die echten Exporte wurden zusätzlich vollständig in Excel mit ihren
  CSV-Quelldaten verglichen: `psychometrics.csv` 37 × 21,
  `scaling_data.csv` 39 × 11 und `log_unit_times.csv` 1 × 10
  (jeweils ohne Überschrift). Scores, Wahrscheinlichkeiten und Zeiten sind
  Zahlen; vollständige Itemkennungen wie `U101` bleiben erhalten.
- `psychometrics.csv` exportiert alle Spalten und Kategoriezeilen der
  Kennwertetabelle, einschließlich der Basisvariablen ohne eigene Item-ID.
  `psychometrics.rds` bewahrt zusätzlich die ursprünglichen Datentypen.
  Die lokale Itemnummer `01` bleibt beim CSV-Rückimport mit
  `colClasses = c(item_id = "character")` erhalten; Excel liest sie als Zahl.
  Leere Missing-Zellen der Kennwerte- und Skalierungsdatei werden mit `na = ""`
  ausgegeben; beim Kennwerte-Rückimport erhält `na.strings = ""` die fehlenden
  Zeichenwerte. Der vollständige Kennwertexport wurde damit erneut in Excel geprüft.
- Nennerbeispiel U501 geprüft: 20 vorgesehene Fälle, 19 mit Score ungleich
  `NA`; sechs richtige Antworten ergeben 6/20 bzw. 6/19. Kategorie B ergibt
  entsprechend 7/20 bzw. 7/19. Wiederholte Codezeilen bleiben für die
  Kategorieauswertung erhalten und werden nur für Codeauszüge verdichtet.
- PBC am installierten Funktionscode und durch unabhängige Nachrechnung
  geprüft: U101/Code 1 rund 0,309 bei 39 Fällen, Kategorie A rund 0,312 bei
  38 Fällen. Der Vergleichsscore ist der mittlere Itemscore im Bereich,
  einschließlich des betrachteten Items; Kategorien schließen Missing-Codes aus.
- Alle erzeugten Dateien liegen unter `Daten/Ergebnisse/`. Die nummerierten
  RDS-Dateien 01–05 gehören zu derselben Studie und enden beim breiten
  Skalierungsdatensatz. Dieser enthält drei ursprüngliche Testcenter-Kennungen
  und acht Itemspalten. Ein zusätzlicher Personenschlüssel entfällt.
- Beide Optionen von `complete_design()` getrennt geprüft: P006/U5 zeigt
  die Umkodierung abschließender Auslassungen, P002/U2 den Erhalt von Not reached
  vor späterer Bearbeitung. Ungültige Antworten, manuelle Auslassungen,
  Personen ohne Status und nicht vorgesehene Items sind ebenfalls geprüft.
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
- ZIP-Wurzel ausschließlich `Syntaxen/`, `Daten/` und `WSeatPrepTBA.Rproj`;
  PDF, Quarto-Quellen und erzeugte Ergebnisse sind nicht enthalten.
- Das entpackte Minimalpaket in einem frischen Ordner prüfen: Setup ohne
  Installation sowie alle lokalen Skripte ausführen. Ergebnisse entstehen
  ausschließlich innerhalb von `Daten/`.
- Kommentarfassungen, lokale Paketbibliotheken, Arbeitsarchive und
  überholte DOCX-Ausgaben aus der Veröffentlichung ausschließen.

## Grenzen

Live-Anmeldung und Downloads mit tatsächlichen IQB-Studio- oder
Testcenter-Zugängen werden nicht ausgeführt. Die Demonstrationen nutzen
synthetische lokale Daten. Ein vollständiger Neuaufbau der Paketumgebung
aus dem Internet ist nicht Bestandteil dieser Prüfung.

Die Einbindung in IQB-Methods ist vorbereitet; deren Hauptwebsite-Build
und Veröffentlichung gehören nicht zur lokalen Workshopprüfung.
