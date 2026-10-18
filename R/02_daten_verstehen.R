# Antworten, Variablen, Codes und Scores an einem kleinen Beispiel verstehen.
# Das R-Projekt öffnen und die Abschnitte der Reihe nach ausführen.
# Alle Antworten sind erfunden. Die Regeln folgen dem IQB-Studio-Tutorial.
# Die größere Mini-Studie steht separat in 03_datenaufbereitung.R.

# ---- demo-einlesen ----
library(eatPrepTBA)
library(dplyr)
library(tidyr)

pc_units <- readRDS("data/demo-pc-units.rds")
pc_responses <- read_responses("data/demo-pc-responses.csv")

select(pc_units, unit_key, unit_label)
select(pc_responses, login_name, unit_key, response_progress)
# ---- /demo-einlesen ----

# Mehr von der Unit-Tabelle ansehen.
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

# 1. JSON ansehen: In einer Tabellenzelle stehen mehrere Antworten.
# id nennt die Variable, value ihren Wert und status den Bearbeitungsstatus.
# Die Anführungszeichen zeigen: Auch die eingegebenen Zahlen sind hier Text.

# ---- json-ansehen ----
cat(jsonlite::prettify(pc_responses$responses[[1]]))
# ---- /json-ansehen ----

# 2. Rohantworten entpacken. Dabei werden noch keine Punkte vergeben.
# value bleibt zunächst eine Listenspalte, weil Werte auch Listen sein können.

# ---- antworten-entpacken ----
raw_values <- prepare_responses(pc_responses)
select(raw_values, login_name, variable_id, value, variable_status)
# ---- /antworten-entpacken ----

# Im Beispiel enthält jedes Antwortfeld genau einen Wert.
# Bei Mehrfachantworten würde unnest_longer() mehrere Zeilen erzeugen.

# ---- antwortwerte-anzeigen ----
raw_values <- unnest_longer(raw_values, value, keep_empty = TRUE)
select(raw_values, login_name, variable_id, value, variable_status)
# ---- /antwortwerte-anzeigen ----

# 3. Das Kodierschema ansehen: Drei Basisvariablen liefern je 0 oder 1 Punkt.
# Variable 01 summiert deren Punkte und vergibt daraus 0, 1 oder 2 Punkte.
# Die zusätzlichen Regeln für Tausender-Schreibweisen sind hier ausgelassen.

# ---- pc-schema-ansehen ----
pc_rules <- pc_units |>
  select(unit_key, unit_codes) |>
  unnest(unit_codes) |>
  unnest(variable_codes) |>
  select(variable_id, variable_source_type, code_id, code_score)
pc_rules
# ---- /pc-schema-ansehen ----

# Das ausgelesene Kodierschema für Partial Credit.
# ---- pc-regeln-vorschau ----
pc_rules |>
  filter(variable_id %in% c("01a", "01")) |>
  print()
# ---- /pc-regeln-vorschau ----

# 4. Automatisch kodieren. Dazu wieder die ursprünglichen Antworten verwenden.
# prepare = TRUE liefert eine Tabelle mit Codes, Scores und Metadaten.

# ---- pc-kodieren ----
pc_coded <- code_responses(pc_responses, pc_units, prepare = TRUE)
pc_coded |>
  filter(login_name == "D1") |>
  select(variable_id, value, code_id, code_score, code_status)
# ---- /pc-kodieren ----

# 5. Nur die abgeleitete Variable 01 bildet hier das Auswertungsitem.
# Code 1 bedeutet 2 Punkte; Code 2 bedeutet 1 Punkt. Codes sind keine Scores.

# ---- pc-items-zuordnen ----
pc_items <- add_item_id(pc_coded, pc_units)
pc_items <- filter(pc_items, !is.na(item_id))
select(pc_items, login_name, item_id, value, code_id, code_score)
# ---- /pc-items-zuordnen ----

# 6. Alternative: Im Export stehen bereits Codes, etwa bei StarS-Daten.
# Auch diese Datei ist nachgebildet. Sie enthält fertige Codes für Variable 01.
# prepare_coded() liest sie aus; es kodiert und prüft keine Antworten neu.

# ---- vorhandene-codes-entpacken ----
pc_stored <- read_responses("data/demo-stored-codes.csv")
stored_codes <- prepare_coded(pc_stored)
select(stored_codes, login_name, variable_id, value, code_id, code_score)
# ---- /vorhandene-codes-entpacken ----

# Für eigene Daten zuerst prüfen: Welche Variablen sind Items? Welche Codes
# sind gültig? Welche Missing-Regeln gelten? Ein Studiendesign fehlt hier noch.
# Diese Tabelle ersetzt deshalb nicht den vollständigen Aufbereitungsworkflow.
