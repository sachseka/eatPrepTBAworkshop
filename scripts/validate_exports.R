# Regressionstests für die synthetischen Log- und Exportbeispiele.
# Aus dem Projektordner nach 04_logs.R und 05_kodiermanuale.R ausführen.
library(dplyr)

times <- read.csv2("Daten/Ergebnisse/log_unit_times.csv", na.strings = "")
sessions <- read.csv2("Daten/Ergebnisse/log_sessions.csv", na.strings = "")
log_results <- readRDS("Daten/Ergebnisse/log_qc.rds")

# P001: 12.100 - 450 = 11.650 ms; Laden: 450 - 100 = 350 ms.
# Fokusverlust von 4.000 bis 6.500 ms. P002 hat keinen Player-Start.
p1_times <- filter(times, login_name == "P001")
p1_session <- filter(sessions, login_name == "P001")
p2_session <- filter(sessions, login_name == "P002")
stopifnot(nrow(p1_times) == 1L, nrow(times) == 1L,
          isTRUE(all.equal(p1_times$unit_time_s, 11.65)),
          isTRUE(all.equal(p1_times$unit_loadtime_s, 0.35)),
          p1_session$log_qc_flag == "ok",
          p1_session$n_focus_lost == 1L, p1_session$focus_lost_s == 2.5,
          !p1_session$has_unresolved_focus_loss,
          p2_session$log_qc_flag == "critical",
          p2_session$n_focus_lost == 1L, p2_session$focus_lost_s == 0,
          p2_session$has_unresolved_focus_loss,
          !"P002" %in% times$login_name,
          all(c("qc", "unit_times", "focus") %in% names(log_results)))

# Excel-Export öffnen: Tabellenblätter, Datenzeilen und Scorewerte prüfen.
xlsx <- "Daten/Ergebnisse/codebook.xlsx"
stopifnot(identical(openxlsx::getSheetNames(xlsx), c("Codebuch", "Auswahl")))
cb_full <- openxlsx::read.xlsx(xlsx, sheet = "Codebuch")
cb_selection <- openxlsx::read.xlsx(xlsx, sheet = "Auswahl")
u4 <- filter(cb_selection, unit_key == "U4", variable_id == "TEXT")
stopifnot(nrow(cb_full) == 22L, nrow(cb_selection) == 10L,
          setequal(cb_selection$unit_key, c("U3", "U4")),
          identical(u4$code_score[match(c("2", "1", "0"), u4$code_id)],
                    c(1, 0.5, 0)))

# CSV bleibt ohne Zeilennummern; Dezimalkomma und Beschriftungen bleiben erhalten.
cb_csv <- read.csv2("Daten/Ergebnisse/codebook.csv", na.strings = "",
                    colClasses = c(code_id = "character"))
stopifnot(identical(names(cb_csv), names(cb_selection)),
          isTRUE(all.equal(cb_csv, as.data.frame(cb_selection),
                           check.attributes = FALSE)))
csv_lines <- readLines("Daten/Ergebnisse/log_unit_times.csv")
stopifnot(grepl(';', csv_lines[1], fixed = TRUE),
          any(grepl('11,65', csv_lines, fixed = TRUE)))

# Fehlende Werte erscheinen auch in den Log- und Codebuch-CSV als leere Zellen.
csv_tables <- list(log_inventory = inventory, log_anomalies = anomalies,
                   log_unit_times = times, log_sessions = session_overview,
                   codebook = selected_cb)
for (name in names(csv_tables)) {
  csv_path <- file.path("Daten/Ergebnisse", paste0(name, ".csv"))
  cells <- read.csv2(csv_path, colClasses = "character", na.strings = character())
  expected <- as.data.frame(csv_tables[[name]])
  stopifnot(identical(dim(cells), dim(expected)), identical(names(cells), names(expected)))
  stopifnot(all(as.matrix(cells)[is.na(expected)] == ""))
}

# IQB-Studio-Vorlage nur parsen: keine Anmeldung und kein Serverzugriff.
invisible(parse("Syntaxen/06_kodiermanuale_studio.R", encoding = "UTF-8"))
stopifnot(all(c("missings_profile", "show_score", "missings") %in%
                names(formals(eatPrepTBA::prepare_codebook))),
          all(c("format", "general_instructions", "missings_profile") %in%
                names(formals(eatPrepTBA::download_codebook))))
cat("Logzeiten, Fokus, XLSX und IQB-Studio-API-Signaturen geprüft.\n")
