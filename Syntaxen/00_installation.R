# 1. Pakete

# Bei Bedarf installieren:
install.packages("pak")
pak::pak(c(
  "iqb-research/eatPrepTBA",
  "dplyr", "tidyr", "readr", "tibble", "writexl"
))

# Versionen prüfen:
packageVersion("eatPrepTBA")  # Workshopstand: 0.9.8.9042
packageVersion("eatAutoCode") # Workshopstand: 0.5.0.9008

# Laden:
library(eatPrepTBA) # eatAutoCode wird intern geladen; nicht separat laden.
library(dplyr)
library(tidyr)
library(readr)
library(tibble)
library(writexl)

# 2. Sind die Beispieldateien da?

files <- c("Daten/units.rds", "Daten/design.rds", "Daten/Responses.csv",
           "Daten/codes_manual.csv", "Daten/Logs.csv", "Daten/codebook.csv",
           "Daten/demo-pc-units.rds", "Daten/demo-pc-responses.csv",
           "Daten/demo-stored-codes.csv", "Daten/demo-coding-report.rds",
           "Daten/demo-metadata-prepared.rds")
missing_files <- files[!file.exists(files)]
if (length(missing_files) > 0) {
  stop("Dateien fehlen: ", paste(missing_files, collapse = ", "),
       ". ZIP vollständig entpacken und WSeatPrepTBA.Rproj öffnen.")
} else {
  cat("Ja, alles da.\n")
}
