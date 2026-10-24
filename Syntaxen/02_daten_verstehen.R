# Rechenbeispiel: Antworten, Codes und Scores
# Synthetische Daten; Kodierschema nach dem IQB-Studio-Tutorial zu Partial Credit:
# https://iqb-research.github.io/IQB-Methods/docs/studio/partial_credit.html#numerische-kurzantwort

# 1. Pakete und Daten

library(eatPrepTBA) # eatAutoCode nicht separat laden.
library(dplyr)
library(tidyr)

pc_units <- readRDS("Daten/demo-pc-units.rds")
pc_responses <- read_responses("Daten/demo-pc-responses.csv")

select(pc_units, unit_key, unit_label)
select(pc_responses, login_name, unit_key, response_progress)

# View(pc_units) # die vollständige Tabelle in RStudio öffnen

# Spalten und verschachtelte Tabellen ansehen:

pc_units |>
  select(unit_key, unit_label, coding_scheme, unit_variables, items_list) |>
  print(width = 90)
names(pc_units)

# [[1]] öffnet die Tabelle für die erste Unit innerhalb einer Listenspalte.
print(pc_units$unit_variables[[1]] |> select(variable_id, variable_type))
print(pc_units$items_list[[1]] |> select(variable_id, item_id))

# 2. Metadaten und Kodierbericht ansehen
# Synthetischer Metadatenauszug; im Workshop ohne Serverabruf.

metadata_demo <- readRDS("Daten/demo-metadata-prepared.rds")
select(metadata_demo, unit_key, unit_metadata, item_metadata)
metadata_demo$unit_metadata[[1]]
metadata_demo$item_metadata[[1]]

# Synthetischer Prüfbericht: Die zweite Unit enthält absichtlich einen Fehler.
coding_report_demo <- readRDS("Daten/demo-coding-report.rds")
select(coding_report_demo, unit_key, variable_id, validation, coding_type)
coding_report_demo$validation_problems[[2]]

# 3. JSON ansehen
# id = Variable, value = Antwort, status = Bearbeitungsstatus.
# Auch die eingegebenen Zahlen sind hier als Text gespeichert.

cat(jsonlite::prettify(pc_responses$responses[[1]]))

# 4. Rohantworten entpacken
# value bleibt zunächst eine Listenspalte; Punkte werden noch nicht vergeben.

raw_values <- prepare_responses(pc_responses)
select(raw_values, login_name, variable_id, value, variable_status)

# 5. Kodierschema ansehen
# Drei Basisvariablen liefern je 0 oder 1 Punkt; 01 vergibt daraus 0–2 Punkte.
# Zusätzliche Regeln für Tausender-Schreibweisen sind hier ausgelassen.

pc_rules <- pc_units |>
  select(unit_key, unit_codes) |>
  unnest(unit_codes) |>
  unnest(variable_codes) |>
  select(variable_id, variable_source_type, code_id, code_score)
pc_rules

# Basisvariable 01a und abgeleitete Variable 01 vergleichen:

pc_rules |>
  filter(variable_id %in% c("01a", "01")) |>
  print()

# 6. Automatisch kodieren
# Wieder die ursprünglichen Antworten verwenden.
# prepare = TRUE liefert eine Tabelle mit Codes, Scores und Metadaten.

pc_coded <- code_responses(pc_responses, pc_units, prepare = TRUE)
pc_coded |>
  filter(login_name == "D1") |>
  select(variable_id, value, code_id, code_score, code_status)

# Hat die Kodierung funktioniert?

nrow(pc_coded) == 16 # sollte TRUE sein: 4 Personen mit je 4 Variablen
all(pc_coded$code_status == "CODING_COMPLETE") # sollte TRUE sein

# 7. Auswertungsitem auswählen
# Nur 01 ist hier ein Item. Code 1 = 2 Punkte; Code 2 = 1 Punkt.

pc_items <- add_item_id(pc_coded, pc_units)
pc_items <- filter(pc_items, !is.na(item_id))
select(pc_items, login_name, item_id, value, code_id, code_score)

# 8. Bereits gespeicherte Codes einlesen, z. B. bei StarS-Daten
# Die synthetische Datei enthält fertige Codes für Variable 01.
# prepare_coded() liest sie aus; es kodiert nicht neu.

pc_stored <- read_responses("Daten/demo-stored-codes.csv")
stored_codes <- prepare_coded(pc_stored)
select(stored_codes, login_name, variable_id, value, code_id, code_score)
