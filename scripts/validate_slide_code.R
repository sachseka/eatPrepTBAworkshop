# Autorenprüfung: Die lokalen Folien-Chunks müssen der Reihe nach laufen.
# API-Beispiele werden ausgelassen; es wird kein Server kontaktiert.
slides <- readLines("workshop.qmd", encoding = "UTF-8", warn = FALSE)
starts <- grep(paste0("^<!-- r-source: R/(03_datenaufbereitung|",
                       "02_daten_verstehen|04_logs|05_kodiermanuale)\\.R#"), slides)
chunks <- character()
for (start in starts) {
  end <- start + which(slides[(start + 1):length(slides)] == "<!-- /r-source -->")[1]
  block <- slides[(start + 1):(end - 1)]
  block <- block[!grepl("^```|^#\\|", block)]
  chunks <- c(chunks, block, "")
}
stopifnot(length(starts) >= 25L)
eval(parse(text = chunks), envir = .GlobalEnv)
stopifnot(nrow(scaling_data) == 39L, length(item_columns) == 8L,
          file.exists("outputs/codebook.xlsx"))
cat(length(starts), "lokale Folien-Codeblöcke der Reihe nach ausgeführt.\n")
