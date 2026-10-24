# WSeatPrepTBA.Rproj öffnen; die folgenden Abschnitte einzeln ausführen.

# 1. Pakete

# Bei Bedarf installieren:
# ---- pakete-installieren ----
install.packages("pak")
pak::pak(c(
  "iqb-research/eatPrepTBA",
  "dplyr", "tidyr", "readr", "tibble", "writexl"
))
# ---- /pakete-installieren ----

# Versionen prüfen:
# ---- paketversionen ----
packageVersion("eatPrepTBA")  # Workshopstand: 0.9.8.9042
packageVersion("eatAutoCode") # Workshopstand: 0.5.0.9008
# ---- /paketversionen ----

# Laden:
# ---- pakete-laden ----
library(eatPrepTBA) # eatAutoCode wird intern geladen; nicht separat laden.
library(dplyr)
library(tidyr)
library(readr)
library(tibble)
library(writexl)
# ---- /pakete-laden ----
# Beide Pakete haben code_responses(); hier wird die aus eatPrepTBA benötigt.

# 2. Sind die Beispieldateien da?

# ---- dateien-pruefen ----
files <- c("data/units.rds", "data/design.rds", "data/Responses.csv",
           "data/codes_manual.csv", "data/Logs.csv", "data/codebook.csv",
           "data/demo-pc-units.rds", "data/demo-pc-responses.csv",
           "data/demo-stored-codes.csv")
missing_files <- files[!file.exists(files)]
if (length(missing_files) > 0) {
  stop("Dateien fehlen: ", paste(missing_files, collapse = ", "),
       ". ZIP vollständig entpacken und WSeatPrepTBA.Rproj öffnen.")
} else {
  cat("Ja, alles da.\n")
}
# ---- /dateien-pruefen ----

# Die erste Kodierung folgt in R/02_daten_verstehen.R.
