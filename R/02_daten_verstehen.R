# Rechenbeispiel: Antworten, Codes und Scores
# Synthetische Daten; das Kodierschema folgt dem IQB-Studio-Tutorial.

# 1. Pakete und Daten

# ---- demo-einlesen ----
library(eatPrepTBA) # eatAutoCode nicht separat laden.
library(dplyr)
library(tidyr)

pc_units <- readRDS("data/demo-pc-units.rds")
pc_responses <- read_responses("data/demo-pc-responses.csv")

select(pc_units, unit_key, unit_label)
select(pc_responses, login_name, unit_key, response_progress)
# ---- /demo-einlesen ----
# View(pc_units) # die vollständige Tabelle in RStudio öffnen

# Spalten und verschachtelte Tabellen ansehen:
# ---- demo-units-vorschau ----
pc_units |>
  select(unit_key, unit_label, coding_scheme, unit_variables, items_list) |>
  print(width = 90)
names(pc_units)
# ---- /demo-units-vorschau ----

# [[1]] öffnet die Tabelle für die erste Unit innerhalb einer Listenspalte.
# ---- demo-unit-tabellen ----
print(pc_units$unit_variables[[1]] |> select(variable_id, variable_type))
print(pc_units$items_list[[1]] |> select(variable_id, item_id))
# ---- /demo-unit-tabellen ----

# 2. JSON ansehen
# id = Variable, value = Antwort, status = Bearbeitungsstatus.
# Auch die eingegebenen Zahlen sind hier als Text gespeichert.

# ---- json-ansehen ----
cat(jsonlite::prettify(pc_responses$responses[[1]]))
# ---- /json-ansehen ----

# 3. Rohantworten entpacken
# value bleibt zunächst eine Listenspalte; Punkte werden noch nicht vergeben.

# ---- antworten-entpacken ----
raw_values <- prepare_responses(pc_responses)
select(raw_values, login_name, variable_id, value, variable_status)
# ---- /antworten-entpacken ----

# Hier hat jedes Feld einen Wert; bei Mehrfachantworten entstehen mehr Zeilen.

# ---- antwortwerte-anzeigen ----
raw_values <- unnest_longer(raw_values, value, keep_empty = TRUE)
select(raw_values, login_name, variable_id, value, variable_status)
# ---- /antwortwerte-anzeigen ----

# 4. Kodierschema ansehen
# Drei Basisvariablen liefern je 0 oder 1 Punkt; 01 vergibt daraus 0–2 Punkte.
# Zusätzliche Regeln für Tausender-Schreibweisen sind hier ausgelassen.

# ---- pc-schema-ansehen ----
pc_rules <- pc_units |>
  select(unit_key, unit_codes) |>
  unnest(unit_codes) |>
  unnest(variable_codes) |>
  select(variable_id, variable_source_type, code_id, code_score)
pc_rules
# ---- /pc-schema-ansehen ----

# Basisvariable 01a und abgeleitete Variable 01 vergleichen:
# ---- pc-regeln-vorschau ----
pc_rules |>
  filter(variable_id %in% c("01a", "01")) |>
  print()
# ---- /pc-regeln-vorschau ----

# 5. Automatisch kodieren
# Wieder die ursprünglichen Antworten verwenden.
# prepare = TRUE liefert eine Tabelle mit Codes, Scores und Metadaten.

# ---- pc-kodieren ----
pc_coded <- code_responses(pc_responses, pc_units, prepare = TRUE)
pc_coded |>
  filter(login_name == "D1") |>
  select(variable_id, value, code_id, code_score, code_status)
# ---- /pc-kodieren ----

# Hat die Kodierung funktioniert?
# ---- pc-kodierung-pruefen ----
nrow(pc_coded) == 16 # sollte TRUE sein: 4 Personen mit je 4 Variablen
all(pc_coded$code_status == "CODING_COMPLETE") # sollte TRUE sein
# ---- /pc-kodierung-pruefen ----

# 6. Auswertungsitem auswählen
# Nur 01 ist hier ein Item. Code 1 = 2 Punkte; Code 2 = 1 Punkt.

# ---- pc-items-zuordnen ----
pc_items <- add_item_id(pc_coded, pc_units)
pc_items <- filter(pc_items, !is.na(item_id))
select(pc_items, login_name, item_id, value, code_id, code_score)
# ---- /pc-items-zuordnen ----

# 7. Bereits gespeicherte Codes einlesen, z. B. bei StarS-Daten
# Die synthetische Datei enthält fertige Codes für Variable 01.
# prepare_coded() liest sie aus; es kodiert nicht neu.

# ---- vorhandene-codes-entpacken ----
pc_stored <- read_responses("data/demo-stored-codes.csv")
stored_codes <- prepare_coded(pc_stored)
select(stored_codes, login_name, variable_id, value, code_id, code_score)
# ---- /vorhandene-codes-entpacken ----

# Testdesign und Missings folgen in R/03_datenaufbereitung.R.
