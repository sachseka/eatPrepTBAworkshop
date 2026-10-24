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

writexl::write_xlsx(list(Codebuch = cb, Auswahl = selected_cb),
                    "Daten/Ergebnisse/codebook.xlsx")

# sep=; gibt Excel das Trennzeichen beim Öffnen vor.
csv <- file("Daten/Ergebnisse/codebook.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(selected_cb, csv, row.names = FALSE)
close(csv)

# Excel enthält zwei Blätter: Codebuch und Auswahl.
codebook_files <- c("Daten/Ergebnisse/codebook.xlsx", "Daten/Ergebnisse/codebook.csv")
tibble(Datei = basename(codebook_files),
       Bytes = file.info(codebook_files)$size) |> print()

# Für eigene Daten: prepare_codebook() und DOCX-Download in Skript 06.
