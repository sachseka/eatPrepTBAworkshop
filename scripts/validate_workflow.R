# Interne Prüfung der synthetischen Workshop-Lehrfälle.
# Aus dem Projektordner ausführen. Nicht als Vorlage für eigene Daten gedacht.
source("Syntaxen/03_datenaufbereitung.R", encoding = "UTF-8")

case <- function(person, unit, variable) {
  dplyr::filter(design_coded, login_name == person,
                unit_key == unit, variable_id == variable)
}

# Umfang der unabhängig festgelegten Mini-Studie.
stopifnot(nrow(units) == 6L, nrow(design) == 340L, nrow(responses) == 193L)
stopifnot(nrow(scaling_data) == 39L, ncol(scaling_data) == 12L)
stopifnot(length(item_columns) == 8L)

# Innere Auslassung, Not reached, ungültige Antwort und manuelle Auslassung.
stopifnot(case("P002", "U2", "Q1")$code_type == "MISSING_BY_OMISSION")
stopifnot(case("P003", "U5", "Q1")$code_type == "MISSING_NOT_REACHED")
stopifnot(case("P004", "U1", "Q1")$code_type == "MISSING_INVALID_RESPONSE")
stopifnot(case("P005", "U4", "TEXT")$code_id == -99L)
stopifnot(case("P006", "U5", "Q1")$code_type == "MISSING_BY_OMISSION")
stopifnot(all(is.na(case("P003", "U5", "Q1")$code_score)))

# Die Person ohne gespeicherte Antwort bleibt im Design, nicht im Export.
stopifnot(!any(dplyr::filter(design_coded, login_name == "P040")$id_used))
stopifnot(!"P040" %in% scaling_data$login_name)
stopifnot(is.na(dplyr::filter(scaling_data, login_name == "P001")$U6__U6_Q1))
stopifnot(all(na.omit(unlist(scaling_data[item_columns])) %in% c(0, 0.5, 1)))

# Beide Regeln müssen den beabsichtigten Unterschied bei P006 zeigen.
reclassified <- dplyr::filter(omissions_reclassified, login_name == "P006",
                              unit_key == "U5", variable_id == "Q1")
stopifnot(reclassified$code_type == "MISSING_NOT_REACHED")
stopifnot(is.na(reclassified$code_score))

# Die Zusammenfassung zählt Items, nicht die zusätzlichen Basisvariablen.
stopifnot(nrow(missing_summary) == 40L, nrow(missing_summary_used) == 39L)
stopifnot(dplyr::filter(missing_summary, login_name == "P001")$n_items == 7L)
stopifnot(dplyr::filter(missing_summary, login_name == "P021")$n_items == 6L)
stopifnot(dplyr::filter(missing_summary, login_name == "P003")$n_not_reached == 2L)
stopifnot(dplyr::filter(missing_summary, login_name == "P002")$n_by_omission == 1L)

# Das MC-Beispiel trennt Antwortkategorien, Codes und Punktzahlen.
categories_by_id <- arrange(category_stats, category_id)
stopifnot(identical(categories_by_id$category_id, c("A", "B", "C")))
stopifnot(all(categories_by_id$category_n == c(21, 5, 12)))
stopifnot(all(code_stats_mc$code_id == c(-98, 0, 1)))
stopifnot(all(code_stats_mc$code_n == c(1, 17, 21)))
stopifnot(all(score_stats$code_score == c(0, 1)))
stopifnot(all(score_stats$score_n == c(18, 21)))
stopifnot(!any(grepl("^score_", names(psychometrics))))
stopifnot(isTRUE(all.equal(sum(category_stats$category_p_valid), 38 / 39)))

# Der CSV-Export erhält die Werte und die Zuordnung zu den Personen.
exported <- read.csv2("Daten/Ergebnisse/scaling_data.csv", fileEncoding = "UTF-16LE")
stopifnot(identical(names(exported), names(scaling_data)))
stopifnot(isTRUE(all.equal(as.data.frame(exported), as.data.frame(scaling_data),
                           check.attributes = FALSE)))
csv_connection <- file("Daten/Ergebnisse/scaling_data.csv", encoding = "UTF-16LE")
csv_lines <- readLines(csv_connection)
close(csv_connection)
stopifnot(grepl(';', csv_lines[1], fixed = TRUE),
          any(grepl('0,5', csv_lines, fixed = TRUE)))
stopifnot(identical(readRDS("Daten/Zwischenstaende/05_scaling_data.rds"), scaling_data))
stopifnot(nrow(person_key) == 39L, !anyDuplicated(person_key$person_id))

report <- c(report, "Workshop-Lehrfälle und Export erfolgreich geprüft.")
writeLines(report, "Daten/Ergebnisse/validation.txt", useBytes = TRUE)
cat("Workshop-Lehrfälle und Export erfolgreich geprüft.\n")
