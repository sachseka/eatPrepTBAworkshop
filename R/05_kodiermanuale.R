# Ein lokales Codebuch auswählen und als Excel/CSV speichern.
# Zuerst WSeatPrepTBA.Rproj öffnen. Benötigt dplyr, readr und writexl.
library(dplyr)
dir.create("outputs", showWarnings = FALSE)

# 1. Lokales Codebuch einlesen und einen Überblick gewinnen.
# ---- codebook-read ----
cb <- readr::read_csv("data/codebook.csv", show_col_types = FALSE,
                      col_types = readr::cols(code_id = readr::col_character()))
count(cb, unit_key, variable_id)
# ---- /codebook-read ----

# Die eingelesene Codebuchtabelle.
# ---- codebuch-vorschau ----
cb |>
  select(unit_key, variable_id, code_id, code_label, code_score) |>
  head(4) |> print()
# ---- /codebuch-vorschau ----
# Diese Lehrtabelle stammt aus den synthetischen Kodierschemata.
# Sie hat eine eigene numerische Score-Spalte.

# 2. Units auswählen und Code von Score unterscheiden.
# ---- codebook-select ----
selected_cb <- cb |>
  filter(unit_key %in% c("U3", "U4")) |>
  select(unit_key, variable_id, code_id, code_label, code_score)
# ---- /codebook-select ----

# Die ausgewählten manuellen Codes.
# ---- codebuch-auswahl-vorschau ----
selected_cb |>
  filter(unit_key == "U4", variable_id == "TEXT") |>
  print()
# ---- /codebuch-auswahl-vorschau ----
# U4/TEXT: Code 2 bedeutet Score 1, Code 1 bedeutet Score 0.5.
# Eine Code-ID ist eine Kategorie, kein automatisch verwendbarer Testscore.
# U3/TOTAL ist abgeleitet; seine Q1/Q2-Zeilen sind keine zusätzlichen Items.
# Fehlende Antworten brauchen eine eigene, dokumentierte Missing-Regel.

# 3. Gesamtes Codebuch und Auswahl als zwei Excel-Blätter speichern.
# ---- codebook-excel ----
writexl::write_xlsx(list(Codebuch = cb, Auswahl = selected_cb),
                    "outputs/codebook.xlsx")
readr::write_csv(selected_cb, "outputs/codebook.csv")
# ---- /codebook-excel ----

# Das gespeicherte Codebuch.
# ---- codebuch-dateien-vorschau ----
codebook_files <- c("outputs/codebook.xlsx", "outputs/codebook.csv")
tibble(Datei = basename(codebook_files),
       Bytes = file.info(codebook_files)$size) |> print()
# ---- /codebuch-dateien-vorschau ----

# Den DOCX-Download aus IQB-Studio zeigt R/06_kodiermanuale_studio.R.
