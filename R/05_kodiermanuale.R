# 1. Vorbereitetes Codebuch einlesen

library(dplyr)
dir.create("outputs", showWarnings = FALSE)

# ---- codebook-read ----
cb <- readr::read_csv("data/codebook.csv", show_col_types = FALSE,
                      col_types = readr::cols(code_id = readr::col_character()))
count(cb, unit_key, variable_id) # 10 Variablen aus 6 Units
# ---- /codebook-read ----

# ---- codebuch-vorschau ----
cb |>
  select(unit_key, variable_id, code_id, code_label, code_score) |>
  head(4) |> print()
# ---- /codebuch-vorschau ----
# Synthetische Lehrtabelle mit eigener numerischer Score-Spalte.

# 2. Units auswählen

# ---- codebook-select ----
selected_cb <- cb |>
  filter(unit_key %in% c("U3", "U4")) |>
  select(unit_key, variable_id, code_id, code_label, code_score)
# ---- /codebook-select ----

# ---- codebuch-auswahl-vorschau ----
selected_cb |>
  filter(unit_key == "U4", variable_id == "TEXT") |>
  print() # Code 2: Score 1; Code 1: Score 0.5
# ---- /codebuch-auswahl-vorschau ----
# Code-ID bezeichnet die Kategorie, code_score die Punktzahl.
# Bei U3 ist TOTAL das Item; Q1 und Q2 sind seine Basisvariablen.

# 3. Excel und CSV speichern

# ---- codebook-excel ----
writexl::write_xlsx(list(Codebuch = cb, Auswahl = selected_cb),
                    "outputs/codebook.xlsx")
readr::write_csv(selected_cb, "outputs/codebook.csv")
# ---- /codebook-excel ----

# Excel enthält zwei Blätter: Codebuch und Auswahl.
# ---- codebuch-dateien-vorschau ----
codebook_files <- c("outputs/codebook.xlsx", "outputs/codebook.csv")
tibble(Datei = basename(codebook_files),
       Bytes = file.info(codebook_files)$size) |> print()
# ---- /codebuch-dateien-vorschau ----

# Für eigene Daten: prepare_codebook() und DOCX-Download in Skript 06.
