# Vom Antwortexport zum Skalierungsdatensatz.
# Das R-Projekt öffnen und die Abschnitte der Reihe nach ausführen.
# Für eigene Daten Pfade, Bereichszuordnung und Missing-Regeln anpassen.
# Voraussetzung: ein Testzeitpunkt; mehrere Zeitpunkte getrennt aufbereiten.

# ---- workflow-start ----
library(eatPrepTBA)
library(dplyr)
library(tidyr)
person_columns <- c("group_id", "login_name", "login_code")

dir.create("outputs", showWarnings = FALSE)
dir.create("checkpoints", showWarnings = FALSE)
# ---- /workflow-start ----

# 1. Antworten, Units und vollständiges Design einlesen.
# Units und Design müssen zur tatsächlichen Durchführung passen.
# R/01_datenabruf.R zeigt den Abruf für eigene Zugänge.

# ---- daten-einlesen ----
units <- readRDS("data/units.rds")
design <- readRDS("data/design.rds")
responses <- read_responses("data/Responses.csv")

# Bei einem gespeicherten API-Abruf diese Zeile statt read_responses() nutzen:
# responses <- readRDS("data_eigen/responses.rds")

count(responses, booklet_id)
saveRDS(responses, "checkpoints/01_responses.rds")
# ---- /daten-einlesen ----

# Units und die Reihenfolge in den Booklets ansehen.
# ---- studie-units-booklets-vorschau ----
print(units |> select(unit_key, unit_label))
print(readr::read_csv("data/booklets.csv", show_col_types = FALSE) |>
  select(booklet_id, unit_booklet_no, unit_key) |> head(5))
# ---- /studie-units-booklets-vorschau ----

# Eine Designzeile beschreibt eine vorgesehene Person-Variable-Kombination.
# ---- design-rohdaten-vorschau ----
print(design |> select(login_name, booklet_id, unit_key, variable_id) |> head(6))
# ---- /design-rohdaten-vorschau ----

# Die eingelesenen Antworten.
# ---- antwortdaten-vorschau ----
responses |>
  select(login_name, booklet_id, unit_key, response_progress) |>
  head(4) |> print()
# ---- /antwortdaten-vorschau ----

# Fehlende Antworten auf vorgesehene Aufgaben sind normal.
# Vorhandene Antworten ohne passende Metadaten sind ein anderer Fall.
# Eine Antwortzeile enthält mehrere Variablen; eine Designzeile nur eine.

# ---- daten-abgleichen ----
response_keys <- c("group_id", "login_name", "login_code",
                   "booklet_id", "unit_key")

unknown_units <- anti_join(responses, units, by = "unit_key")
outside_design <- anti_join(responses, design, by = response_keys)
missing_rows <- anti_join(design, responses, by = response_keys)
# ---- /daten-abgleichen ----

# Fehlende Antworten sind Teil des Designs.
# ---- datenabgleich-vorschau ----
tibble(
  Fall = c("Antwort ohne Unit", "Antwort außerhalb Design",
           "Designzeile ohne Antwort"),
  Anzahl = c(nrow(unknown_units), nrow(outside_design), nrow(missing_rows))
) |> print()
# ---- /datenabgleich-vorschau ----

# 2. Automatisch kodieren und die Status ansehen.
# code_id ist ein Code, code_score die zugehörige Punktzahl.
# Offene manuelle Kodierungen werden im nächsten Abschnitt ergänzt.

# ---- automatisch-kodieren ----
coded_auto <- code_responses(responses, units, prepare = TRUE)
count(coded_auto, unit_key, code_status)
saveRDS(coded_auto, "checkpoints/02_coded_auto.rds")
# ---- /automatisch-kodieren ----

# Ergebnis der automatischen Kodierung.
# ---- auto-vorschau ----
coded_auto |>
  filter(login_name == "P001", unit_key %in% c("U3", "U4")) |>
  select(unit_key, variable_id, code_id, code_score, code_status) |>
  head(4) |> print()
# ---- /auto-vorschau ----

# 3. Manuelle Codes ergänzen.
# Ohne manuelle Kodierung genügt stattdessen: coded <- coded_auto
# Wieder ursprüngliche Antworten nutzen: Ableitungen werden neu kodiert.

# ---- manuelle-codes-einlesen ----
codes_manual <- readr::read_csv("data/codes_manual.csv",
  col_types = readr::cols(.default = "c", code_id = "i"))

# ---- /manuelle-codes-einlesen ----

# Die eingelesenen manuellen Codes.
# ---- manuelle-codes-vorschau ----
head(codes_manual, 3) |> print(width = 90)
# ---- /manuelle-codes-vorschau ----

# ---- manuell-kodieren ----
coded <- code_responses(responses, units, prepare = TRUE,
                        codes_manual = codes_manual)
count(coded, code_status, code_type)
saveRDS(coded, "checkpoints/03_coded.rds")
# ---- /manuell-kodieren ----

# Nach dem Ergänzen manueller Codes.
# ---- manuell-vorschau ----
coded |>
  filter(unit_key == "U4", variable_id == "TEXT") |>
  select(login_name, variable_id, code_id, code_score, code_status) |>
  head(4) |> print()
# ---- /manuell-vorschau ----

# 4. Fehlende Designzeilen ergänzen und Missing-Arten zuweisen.
# Hier gelten die Paketvoreinstellungen: beide Optionen sind FALSE.
# Auslassung und ungültige Antwort erhalten 0 Punkte, Not reached erhält NA.

# ---- design-ergaenzen ----
design_coded <- complete_design(coded, units, design,
  recode_omissions_to_not_reached = FALSE, preserve_not_reached = FALSE)

count(design_coded, id_used, code_type)
saveRDS(design_coded, "checkpoints/04_design_coded.rds")
# ---- /design-ergaenzen ----

# Ergänzte Antworten mit Missing-Art.
# ---- design-vorschau ----
design_coded |>
  filter((login_name == "P002" & unit_key == "U2") |
         (login_name == "P003" & unit_key == "U5")) |>
  select(login_name, unit_key, variable_id, code_type, code_score) |>
  print()
# ---- /design-vorschau ----

# Vergleich mit der Einstellung der aktuellen Referenzstudien-Vignette:
# Abschließende Auslassungen werden NR; vorhandenes NR bleibt geschützt.
# Für diese Regel im eigenen Projekt den obigen Aufruf entsprechend ändern.

# ---- missing-regeln-vergleichen ----
omissions_reclassified <- complete_design(coded, units, design,
  recode_omissions_to_not_reached = TRUE, preserve_not_reached = TRUE)

count(omissions_reclassified, id_used, code_type)
# ---- /missing-regeln-vergleichen ----

# Dieselbe Antwort, andere Missing-Regel.
# ---- missing-vergleich-vorschau ----
bind_rows(Standard = design_coded, Alternative = omissions_reclassified,
          .id = "Regel") |>
  filter(login_name == "P006", unit_key == "U5") |>
  select(Regel, login_name, unit_key, code_type, code_score) |>
  print()
# ---- /missing-vergleich-vorschau ----

# Die endgültige Missing-Art steht in code_type; code_status bleibt erhalten.
# id_used bedeutet: mindestens ein gespeicherter Kodierstatus ist vorhanden.
# Zusätzliche Ausschlussregeln im Auswertungskonzept festhalten.

# ---- teilnahme-auswaehlen ----
analysis_data <- filter(design_coded, id_used)
count(design_coded, id_used)
# ---- /teilnahme-auswaehlen ----

# Die ausgewählten Analysedaten.
# ---- teilnahme-vorschau ----
analysis_data |>
  select(login_name, unit_key, variable_id, id_used, code_score) |>
  head(4) |> print()
distinct(analysis_data, login_name) |> summarise(n_personen = n()) |> print()
# ---- /teilnahme-vorschau ----

# 5. Variablen mit den Auswertungsitems verbinden.
# Variablen ohne Item-ID ansehen, bevor sie aus dem Datensatz entfernt werden.
# Item-IDs bleiben Text, damit zum Beispiel führende Nullen erhalten bleiben.

# ---- items-zuordnen ----
design_items <- add_item_id(design_coded, units)
item_data <- add_item_id(analysis_data, units)

unmapped <- item_data |>
  filter(is.na(item_id) | trimws(item_id) == "") |>
  distinct(unit_key, variable_id)
print(unmapped)

item_data <- filter(item_data, !is.na(item_id), trimws(item_id) != "")
item_data <- mutate(item_data, item = paste0(unit_key, "__", item_id))
# ---- /items-zuordnen ----

# Aus Variablen werden Auswertungsitems.
# ---- items-vorschau ----
item_data |>
  filter(login_name == "P001", unit_key %in% c("U3", "U4")) |>
  select(unit_key, variable_id, item_id, item, code_score) |>
  print()
# ---- /items-vorschau ----

# 6. Noch offene Itemkodierungen finden.
# Bei einem Abbruch die jeweilige Tabelle ansehen und die Ursache klären.

# ---- offene-codes-pruefen ----
unresolved <- item_data |>
  filter(code_status %in% c("UNSET", "CODING_INCOMPLETE", "DERIVE_PENDING",
                            "CODING_ERROR", "DERIVE_ERROR",
                            "INTENDED_INCOMPLETE") |
         code_type %in% c("NO_CODING", "CODING_INCOMPLETE", "DERIVE_PENDING",
                           "INTENDED_INCOMPLETE"))
stopifnot(nrow(unresolved) == 0)
# ---- /offene-codes-pruefen ----

# Noch offene Itemkodierungen.
# ---- offene-codes-vorschau ----
unresolved |>
  select(login_name, item, code_status, code_type) |>
  head(4) |> print()
# ---- /offene-codes-vorschau ----


# 7. Missing-Anzahlen und Anteile pro Person berechnen.
# Gezählt werden vorgesehene Items, auch für Personen ohne gespeicherte Antwort.
# Fehlende Aufgaben außerhalb des Designs gehören nicht in diesen Nenner.

# ---- missings-zusammenfassen ----
missing_summary <- summarise_missings(design_items)
missing_summary_used <- summarise_missings(design_items, used_only = TRUE)

select(missing_summary, all_of(person_columns), id_used, n_items,
       n_not_reached, n_by_omission, prop_missing)
readr::write_csv(missing_summary, "outputs/missing_summary.csv")
# ---- /missings-zusammenfassen ----

# Missing-Anteile je Person.
# ---- missing-uebersicht-vorschau ----
missing_summary |>
  select(login_name, n_items, n_not_reached, n_by_omission, prop_missing) |>
  head(4) |> print()
# ---- /missing-uebersicht-vorschau ----

# 8. Psychometrische Kennwerte berechnen.
# Im Beispiel gehören alle Units zu Lesen. Eigene Bereiche pro Unit zuordnen.
# code_pbc bezieht den eigenen Itemscore in den Bereichsmittelwert mit ein.

# ---- kennwerte-berechnen ----
domains <- distinct(units, unit_key)
domains$domain <- "Lesen"

psychometrics <- evaluate_psychometrics(analysis_data, units, domains = domains)
psychometrics <- add_item_id(psychometrics, units)

code_stats <- psychometrics |>
  select(item_id, unit_key, variable_id, code_id, code_score,
         code_n, code_p_valid, code_pbc) |>
  distinct()
readr::write_csv(code_stats, "outputs/psychometrics.csv")
# ---- /kennwerte-berechnen ----

# Kennwerte je Item und Code.
# ---- kennwerte-vorschau ----
code_stats |>
  filter(item_id == "U1_Q1") |>
  select(item_id, code_id, code_n, code_p_valid, code_pbc) |>
  head(4) |> print()
# ---- /kennwerte-vorschau ----

# Antwortkategorien: Welche Auswahl wurde getroffen?
# ---- kennwerte-kategorien ----
category_stats <- psychometrics |>
  filter(item_id == "U1_Q1", !is.na(category_id)) |>
  select(category_id, code_id, category_n, category_p_valid, category_pbc)
print(category_stats)
# ---- /kennwerte-kategorien ----

# Codes: Mehrere Antwortkategorien können denselben Code erhalten.
# distinct() entfernt wiederholte Codezeilen aus der gemeinsamen Ausgabe.
# ---- kennwerte-codes ----
code_stats_mc <- psychometrics |>
  filter(item_id == "U1_Q1") |>
  select(code_id, code_score, code_n, code_p_valid, code_pbc) |>
  distinct()
print(code_stats_mc)
# ---- /kennwerte-codes ----

# Scores direkt in den Person-Item-Daten zählen.
# evaluate_psychometrics() liefert keine eigenen score_*-Kennwerte.
# ---- kennwerte-scores ----
score_stats <- item_data |>
  filter(item_id == "U1_Q1") |>
  count(code_score, name = "score_n") |>
  mutate(score_p = score_n / sum(score_n))
print(score_stats)
# ---- /kennwerte-scores ----

# 9. Eine Zeile pro Person und eine Punktespalte pro Item erzeugen.
# unit_key__item_id unterscheidet gleich benannte Items aus zwei Units.
# NA bleibt NA; ein nicht vorgesehenes Item darf nicht 0 Punkte erhalten.

# ---- score-datensatz-erstellen ----
scaling_data <- item_data |>
  select(group_id, login_name, login_code, item, code_score) |>
  pivot_wider(names_from = item, values_from = code_score) |>
  arrange(group_id, login_name, login_code) |>
  mutate(person_id = row_number(), .before = 1)
# ---- /score-datensatz-erstellen ----

# Der fertig gescorte Datensatz.
# ---- datensatz-vorschau ----
scaling_data |>
  select(person_id, login_name, U1__U1_Q1, U3__U3_TOTAL, U5__U5_Q1) |>
  head(4) |> print()
# ---- /datensatz-vorschau ----

# ---- datensatz-pruefen ----
person_key <- select(scaling_data, person_id, group_id, login_name, login_code)
item_columns <- setdiff(names(scaling_data), names(person_key))
persons <- distinct(item_data, group_id, login_name, login_code)
stopifnot(nrow(scaling_data) == nrow(persons))
stopifnot(all(vapply(scaling_data[item_columns], is.numeric, logical(1))))
# ---- /datensatz-pruefen ----

# Die Zuordnung der Personen.
# ---- schluessel-vorschau ----
person_key |> head(4) |> print()
# ---- /schluessel-vorschau ----

# 10. Daten und Zuordnung sichern.
# person_id gilt für diesen Export. Für Folgelieferungen feste IDs weiterführen.
# Die Long-Daten bewahren die Unterschiede zwischen den Missing-Arten.

# ---- daten-exportieren ----
readr::write_csv(scaling_data, "outputs/scaling_data.csv")
readr::write_csv(person_key, "outputs/person_key.csv")
saveRDS(analysis_data, "outputs/analysis_long.rds")
saveRDS(design_items, "outputs/design_items.rds")
saveRDS(scaling_data, "checkpoints/05_scaling_data.rds")

missing_counts <- count(design_coded, id_used, code_type)
readr::write_csv(missing_counts, "outputs/missing_counts.csv")
# ---- /daten-exportieren ----

# Diese Dateien liegen jetzt vor.
# ---- export-vorschau ----
export_files <- c("scaling_data.csv", "person_key.csv", "analysis_long.rds",
                  "design_items.rds", "missing_counts.csv")
tibble(Datei = export_files,
       Bytes = file.info(file.path("outputs", export_files))$size) |> print()
# ---- /export-vorschau ----

# 11. Umfang, Entscheidungen und Paketversionen dokumentieren.
# Die technischen Lehrfallprüfungen stehen in scripts/validate_workflow.R.

# ---- workflow-dokumentieren ----
report <- c(
  "Workflow erfolgreich ausgeführt; allgemeine Prüfungen bestanden.",
  paste("eatPrepTBA:", packageVersion("eatPrepTBA")),
  paste("eatAutoCode:", packageVersion("eatAutoCode")),
  paste("Units:", nrow(units)),
  paste("Designzeilen:", nrow(design)),
  paste("Antwortzeilen:", nrow(responses)),
  paste("Personen im Export:", nrow(scaling_data)),
  paste("Itemspalten:", length(item_columns)),
  "Missing-Regeln: Paketvoreinstellungen; beide NR-Optionen FALSE.",
  "Auswahl: id_used = TRUE; verknüpfte Itemvariablen.",
  "Keine offenen Itemkodierungen im exportierten Datensatz.",
  "Fehlende Werte bleiben NA; Long-Daten und Personenschlüssel gesichert.")

writeLines(report, "outputs/validation.txt", useBytes = TRUE)
capture.output(sessionInfo(), file = "outputs/session-info.txt")
cat(paste(report, collapse = "\n"), "\n")
# ---- /workflow-dokumentieren ----

# Weiterarbeiten: R/04_logs.R und R/05_kodiermanuale.R separat ausführen.
