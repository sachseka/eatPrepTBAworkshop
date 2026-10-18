# Vor dem Workshop WSeatPrepTBA.Rproj öffnen.
# Die Installation einmalig ausführen, falls die Pakete noch fehlen.
# Dafür bei Bedarf die führenden # der folgenden Zeilen entfernen.
# install.packages("pak")
# pak::pak(c(
#   "iqb-research/eatPrepTBA@5e1a0ac1fe736bcafd6338231bf57df1172c9d56",
#   "dplyr", "tidyr", "readr", "tibble", "writexl"
# ))

# Ab hier läuft der lokale Funktionstest ohne Serverzugriff.
needed <- c("eatPrepTBA", "eatAutoCode", "dplyr", "tidyr", "readr",
            "tibble", "writexl")
missing_packages <- needed[
  !vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Bitte zuerst installieren: ", paste(missing_packages, collapse = ", "))
}

versions <- vapply(needed, function(p) as.character(packageVersion(p)),
                   character(1))
print(versions)
if (packageVersion("eatPrepTBA") < "0.9.8.9041") {
  stop("Bitte den dokumentierten Paketstand installieren; siehe setup.html.")
}

files <- c("data/units.rds", "data/design.rds", "data/Responses.csv",
           "data/codes_manual.csv", "data/Logs.csv", "data/codebook.csv")
missing_files <- files[!file.exists(files)]
if (length(missing_files) > 0) {
  stop("Dateien fehlen: ", paste(missing_files, collapse = ", "),
       ". ZIP vollständig entpacken und WSeatPrepTBA.Rproj öffnen.")
}

# Eine kleine Antwort lokal kodieren. Es werden keine Server angesprochen.
units <- readRDS("data/units.rds")
responses <- eatPrepTBA::read_responses("data/Responses.csv")
one <- responses[responses$unit_key == "U1" & responses$login_name == "P001", ]
coded <- eatPrepTBA::code_responses(one, units, prepare = TRUE)
stopifnot(nrow(coded) == 2L, all(coded$code_status == "CODING_COMPLETE"))
cat("Setup OK: lokale Autokodierung funktioniert.\n")
