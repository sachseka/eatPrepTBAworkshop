# 1. Pakete

# Bei Bedarf installieren:
install.packages("pak")
pak::pak(c(
  "iqb-research/eatPrepTBA",
  "dplyr", "tidyr", "readr", "tibble", "writexl"
))

# Versionen prüfen:
packageVersion("eatPrepTBA")  # Workshopstand: 0.9.8.9043
packageVersion("eatAutoCode") # Workshopstand: 0.5.0.9008

# Laden:
library(eatPrepTBA) # eatAutoCode wird intern geladen; nicht separat laden.
library(dplyr)
library(tidyr)
library(readr)
library(tibble)
library(writexl)
