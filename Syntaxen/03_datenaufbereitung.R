# Vom Antwortexport zum Skalierungsdatensatz.
# Für eigene Daten Pfade, Bereiche und Missing-Regeln anpassen.
# Mehrere Testzeitpunkte getrennt aufbereiten.

# 1. Pakete und Ausgabeordner

library(eatPrepTBA) # lädt eatAutoCode mit; nicht separat laden
library(dplyr)
library(tidyr)
person_columns <- c("group_id", "login_name", "login_code")

dir.create("Daten/Ergebnisse", showWarnings = FALSE)

# 2. Beispieldaten einlesen
# Den Abruf eigener Daten zeigt Syntaxen/01_datenabruf.R.

units <- readRDS("Daten/units.rds")
design <- readRDS("Daten/design.rds")
responses <- read_responses("Daten/Responses.csv")

# Nach einem API-Abruf alternativ:
# responses <- readRDS("Daten/EigeneDaten/responses.rds")

count(responses, booklet_id)
saveRDS(responses, "Daten/Ergebnisse/01_responses.rds")

# Units und Booklet-Reihenfolge ansehen.
print(units |> select(unit_key, unit_label)) # sollte 6 Units zeigen
print(readr::read_csv("Daten/booklets.csv", show_col_types = FALSE) |>
  select(booklet_id, unit_booklet_no, unit_key) |> head(5))

# Im Design steht eine Zeile für eine vorgesehene Person und Variable.
print(design |> select(login_name, booklet_id, unit_key, variable_id) |> head(6))

# Eine Antwortzeile enthält die Antworten einer Person auf eine Unit.
responses |>
  select(login_name, booklet_id, unit_key, response_progress) |>
  head(4) |> print()

# Antworten mit Units und Testdesign abgleichen.
# Fehlende Antworten ergänzt später complete_design().

response_keys <- c("group_id", "login_name", "login_code",
                  "booklet_id", "unit_key")

unknown_units <- anti_join(responses, units, by = "unit_key")
outside_design <- anti_join(responses, design, by = response_keys)
missing_rows <- anti_join(design, responses, by = response_keys)

# Die ersten beiden Anzahlen sollten 0 sein; fehlende Antworten sind möglich.
tibble(
  Fall = c("Antwort ohne Unit", "Antwort außerhalb Design",
           "Designzeile ohne Antwort"),
  Anzahl = c(nrow(unknown_units), nrow(outside_design), nrow(missing_rows))
) |> print()

# 3. Automatisch kodieren
# code_id bezeichnet die Bewertung, code_score die Punktzahl.

coded_auto <- code_responses(responses, units, prepare = TRUE)
count(coded_auto, unit_key, code_status)
saveRDS(coded_auto, "Daten/Ergebnisse/02_coded_auto.rds")

# U3/TOTAL sollte kodiert sein; U4/TEXT benötigt einen manuellen Code.
coded_auto |>
  filter(login_name == "P001", unit_key %in% c("U3", "U4")) |>
  select(unit_key, variable_id, code_id, code_score, code_status) |>
  head(4) |> print()

# 4. Manuelle Codes ergänzen
# Ohne manuelle Codes genügt: coded <- coded_auto

codes_manual <- readr::read_csv("Daten/codes_manual.csv",
  col_types = readr::cols(.default = "c", code_id = "i"))

codes_manual |>
  select(login_name, value, code_id) |>
  head(3) |> print(width = 100)

# Ursprüngliche Antworten erneut kodieren, einschließlich Ableitungen.
coded <- code_responses(responses, units, prepare = TRUE,
                       codes_manual = codes_manual)
count(coded, code_status, code_type)
saveRDS(coded, "Daten/Ergebnisse/03_coded.rds")

# U4/TEXT sollte jetzt CODING_COMPLETE sein.
coded |>
  filter(unit_key == "U4", variable_id == "TEXT") |>
  select(login_name, variable_id, code_id, code_score, code_status) |>
  head(4) |> print()

# 5. Testdesign ergänzen und Missings zuweisen
# Standard: Auslassung und ungültige Antwort erhalten 0, Not reached erhält NA.
# code_type enthält danach die Missing-Art; code_status bleibt erhalten.

design_coded <- complete_design(coded, units, design,
  recode_omissions_to_not_reached = FALSE, preserve_not_reached = FALSE)

count(design_coded, id_used, code_type)
saveRDS(design_coded, "Daten/Ergebnisse/04_design_coded.rds")

# P002/U2: ausgelassen (0 Punkte). P003/U5: nicht erreicht (NA).
design_coded |>
  filter((login_name == "P002" & unit_key == "U2") |
         (login_name == "P003" & unit_key == "U5")) |>
  select(login_name, unit_key, variable_id, code_type, code_score) |>
  print()

# Weitere Missing-Fälle derselben Studie ansehen.
design_coded |>
  filter(code_id < 0, id_used) |>
  select(login_name, unit_key, variable_id, code_status, code_id, code_score) |>
  print()

# Alternative 1: abschließende Auslassungen als nicht erreicht behandeln.

omissions_reclassified <- complete_design(coded, units, design,
  recode_omissions_to_not_reached = TRUE, preserve_not_reached = FALSE)

count(omissions_reclassified, id_used, code_type)

# P006/U5 sollte mit der Alternative NA statt 0 Punkte erhalten.
bind_rows(Standard = design_coded, Alternative = omissions_reclassified,
          .id = "Regel") |>
  filter(login_name == "P006", unit_key == "U5") |>
  select(Regel, login_name, unit_key, code_type, code_score) |>
  print()

# Alternative 2: erkanntes Not reached auch vor späterer Bearbeitung erhalten.
not_reached_preserved <- complete_design(coded, units, design,
  recode_omissions_to_not_reached = FALSE, preserve_not_reached = TRUE)

bind_rows(Standard = design_coded, Alternative = not_reached_preserved,
          .id = "Regel") |>
  filter(login_name == "P002", unit_key == "U2") |>
  select(Regel, login_name, unit_key, code_type, code_score) |>
  print()

# Die gewünschte Kombination oben im design_coded-Aufruf einstellen.
# Weitere Fälle: https://iqb-research.github.io/eatPrepTBA/articles/missing-examples.html

# 6. Personen auswählen
# id_used: mindestens ein gespeicherter Kodierstatus ist vorhanden.

analysis_data <- filter(design_coded, id_used)
count(design_coded, id_used)

analysis_data |>
  select(login_name, unit_key, variable_id, id_used, code_score) |>
  head(4) |> print()
distinct(analysis_data, login_name) |>
  summarise(n_personen = n()) |> print() # sollte 39 Personen ergeben

# 7. Items zuordnen
# Variablen ohne Item-ID bleiben außerhalb des Skalierungsdatensatzes.
# Die Itemnummer bleibt Text, damit die führende Null erhalten bleibt.

design_items <- add_item_id(design_coded, units)
item_data <- add_item_id(analysis_data, units)

unmapped <- item_data |>
  filter(is.na(item_id) | trimws(item_id) == "") |>
  distinct(unit_key, variable_id)
print(unmapped) # sollte U3/Q1 und U3/Q2 zeigen

item_data <- filter(item_data, !is.na(item_id), trimws(item_id) != "")
item_data <- mutate(item_data, item = paste0(unit_key, item_id))

# U3/TOTAL und U4/TEXT sind jeweils ein Item.
item_data |>
  filter(login_name == "P001", unit_key %in% c("U3", "U4")) |>
  select(unit_key, variable_id, item_id, item, code_score) |>
  print()

# 8. Offene Itemkodierungen prüfen
# Bei einem Abbruch unresolved ansehen und die Kodierung klären.

unresolved <- item_data |>
  filter(code_status %in% c("UNSET", "CODING_INCOMPLETE", "DERIVE_PENDING",
                           "CODING_ERROR", "DERIVE_ERROR",
                           "INTENDED_INCOMPLETE") |
         code_type %in% c("NO_CODING", "CODING_INCOMPLETE", "DERIVE_PENDING",
                          "INTENDED_INCOMPLETE"))
stopifnot(nrow(unresolved) == 0) # sollte ohne Fehler durchlaufen

# Sollte eine leere Tabelle ergeben.
unresolved |>
  select(login_name, item, code_status, code_type) |>
  head(4) |> print()

# 9. Missing-Anteile berechnen
# n_items zählt vorgesehene Items; Aufgaben außerhalb des Designs zählen nicht.

missing_summary <- summarise_missings(design_items)
missing_summary_used <- summarise_missings(design_items, used_only = TRUE)

select(missing_summary, all_of(person_columns), id_used, n_items,
       n_not_reached, n_by_omission, prop_missing)
# sep=; gibt Excel das Trennzeichen beim Öffnen vor.
csv <- file("Daten/Ergebnisse/missing_summary.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(missing_summary, csv, row.names = FALSE)
close(csv)

missing_summary |>
  select(login_name, n_items, n_not_reached, n_by_omission, prop_missing) |>
  head(4) |> print()

# 10. Kennwerte berechnen
# Im Beispiel gehören alle Units zu Lesen; die Zuordnung für eigene Daten ändern.

domains <- distinct(units, unit_key)
domains$domain <- "Lesen"

psychometrics <- evaluate_psychometrics(analysis_data, units, domains = domains)
psychometrics <- add_item_id(psychometrics, units)

psychometrics <- psychometrics |>
  mutate(item = if_else(is.na(item_id), NA_character_, paste0(unit_key, item_id))) |>
  relocate(unit_key, variable_id, item, item_id)

# Alle Spalten und Kategoriezeilen exportieren, auch die der Basisvariablen.
csv <- file("Daten/Ergebnisse/psychometrics.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(psychometrics, csv, row.names = FALSE, na="")
close(csv)
saveRDS(psychometrics, "Daten/Ergebnisse/psychometrics.rds")

psychometrics |>
  filter(item == "U101") |>
  select(item, code_id, code_n, category_id, category_n) |>
  head(4) |> print()

# Kennungen und Herkunft der Variablen ansehen.
variable_info <- psychometrics |>
  filter(unit_key == "U3") |>
  distinct(unit_key, variable_id, item, item_id, variable_source_type)
print(variable_info) # Q1/Q2: BASE; TOTAL: SUM_SCORE

code_info <- psychometrics |>
  filter(item == "U301") |>
  distinct(code_id, code_type, code_score)
print(code_info) # Code 1: Teilpunkte; Code 2: volle Punktzahl

# Antwortkategorien unterscheiden die gewählten Antworten: A, B und C.
category_stats <- psychometrics |>
  filter(unit_key == "U1", item_id == "01", !is.na(category_id)) |>
  select(category_id, code_id, category_n, category_p_valid, category_pbc)
print(category_stats) # sollte A: 21, B: 5 und C: 12 Antworten zeigen

# B und C erhalten denselben Code; distinct() entfernt wiederholte Codezeilen.
code_stats_mc <- psychometrics |>
  filter(unit_key == "U1", item_id == "01") |>
  select(code_id, code_score, code_n, code_p_valid, code_pbc) |>
  distinct()
print(code_stats_mc) # sollte für Code 0 insgesamt 17 Antworten zeigen

# Total zählt alle vorgesehenen Fälle; valid zählt Scores ungleich NA.
denominator_stats <- psychometrics |>
  filter(item == "U501") |>
  distinct(code_id, code_score, code_n, code_n_total, code_n_valid)
print(denominator_stats) # insgesamt 20 Fälle, davon 19 mit gültigem Score

proportion_stats <- psychometrics |>
  filter(item == "U501") |>
  distinct(code_id, code_n, code_p_total, code_p_valid)
print(proportion_stats) # Code 1: 6/20 = 0.30 und 6/19 = 0.316

# Kategorien verwenden dieselben Nenner, zählen aber einzelne Antwortwerte.
category_details <- psychometrics |>
  filter(item == "U501", !is.na(category_id)) |>
  select(category_id, category_label, category_n,
         category_p_total, category_p_valid)
print(category_details)

# PBC: Zusammenhang mit dem mittleren Itemscore im Bereich.
discrimination_stats <- psychometrics |>
  filter(item == "U101", !is.na(category_id)) |>
  select(category_id, code_id, domain, category_pbc, code_pbc)
print(discrimination_stats)

# Scorehäufigkeiten direkt zählen; evaluate_psychometrics() liefert sie nicht.
score_stats <- item_data |>
  filter(unit_key == "U1", item_id == "01") |>
  count(code_score, name = "score_n") |>
  mutate(score_p = score_n / sum(score_n))
print(score_stats) # sollte 18 Personen mit 0 und 21 mit 1 Punkt zeigen

# 11. Skalierungsdatensatz erstellen
# Eine Zeile pro Person, eine Spalte pro Item. NA bleibt erhalten.

scaling_data <- item_data |>
  select(group_id, login_name, login_code, item, code_score) |>
  pivot_wider(names_from = item, values_from = code_score) |>
  arrange(group_id, login_name, login_code)

scaling_data |>
  select(login_name, U101, U301, U501) |>
  head(4) |> print()

# View(scaling_data) # optional: die gesamte Tabelle in RStudio öffnen

item_columns <- setdiff(names(scaling_data), person_columns)
persons <- distinct(item_data, group_id, login_name, login_code)
stopifnot(nrow(scaling_data) == nrow(persons))
stopifnot(all(vapply(scaling_data[item_columns], is.numeric, logical(1))))

# 12. Ergebnisse speichern
# Long-Daten enthalten auch Codes und Missing-Arten.

csv <- file("Daten/Ergebnisse/scaling_data.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(scaling_data, csv, row.names = FALSE, na="")
close(csv)
saveRDS(analysis_data, "Daten/Ergebnisse/analysis_long.rds")
saveRDS(design_items, "Daten/Ergebnisse/design_items.rds")
saveRDS(scaling_data, "Daten/Ergebnisse/05_scaling_data.rds")

missing_counts <- count(design_coded, id_used, code_type)
csv <- file("Daten/Ergebnisse/missing_counts.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(missing_counts, csv, row.names = FALSE, na="")
close(csv)

# Sollte vier vorhandene Dateien mit einer Größe über 0 Bytes zeigen.
export_files <- c("scaling_data.csv", "analysis_long.rds",
                 "design_items.rds", "missing_counts.csv")
tibble(Datei = export_files,
       Bytes = file.info(file.path("Daten/Ergebnisse", export_files))$size) |> print()

# 13. Aufbereitung dokumentieren
# Nach Änderungen an Auswahl oder Missing-Regeln die Angaben unten anpassen.

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
  "Fehlende Werte bleiben NA; Testcenter-Kennungen bleiben im Datensatz.")

writeLines(report, "Daten/Ergebnisse/validation.txt", useBytes = TRUE)
capture.output(sessionInfo(), file = "Daten/Ergebnisse/session-info.txt")
cat(paste(report, collapse = "\n"), "\n")

# Weiterarbeiten: Syntaxen/04_logs.R und Syntaxen/05_kodiermanuale.R separat ausführen.
