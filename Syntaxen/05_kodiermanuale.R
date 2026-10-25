# 1. Vorbereitetes Codebuch einlesen

library(dplyr)
dir.create("Daten/Ergebnisse", showWarnings = FALSE)

cb <- readr::read_csv("Daten/codebook.csv", show_col_types = FALSE,
                      col_types = readr::cols(code_id = readr::col_character()))
count(cb, unit_key, variable_id) # 10 Variablen aus 6 Units

cb |>
  select(unit_key, variable_id, code_id, code_label, code_score) |>
  head(4) |> print()
# Synthetische Lehrtabelle mit eigener numerischer Score-Spalte.

# 2. Units auswählen

selected_cb <- cb |>
  filter(unit_key %in% c("U3", "U4")) |>
  select(unit_key, variable_id, code_id, code_label, code_score)

selected_cb |>
  filter(unit_key == "U4", variable_id == "TEXT") |>
  print() # Code 2: Score 1; Code 1: Score 0.5
# Code-ID bezeichnet die Kategorie, code_score die Punktzahl.
# Bei U3 ist TOTAL das Item; Q1 und Q2 sind seine Basisvariablen.

# 3. Excel und CSV speichern

# Excel enthält zwei Blätter: Codebuch und Auswahl.
writexl::write_xlsx(list(Codebuch = cb, Auswahl = selected_cb),
                    "Daten/Ergebnisse/codebook.xlsx")

write.csv2(selected_cb, "Daten/Ergebnisse/codebook.csv",
           row.names = FALSE, na = "")

# Für eigene Daten: prepare_codebook() und DOCX-Download in Skript 06.
