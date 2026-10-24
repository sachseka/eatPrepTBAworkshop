# Regressionstests für die synthetischen Log- und Exportbeispiele.
# Aus dem Projektordner nach 04_logs.R und 05_kodiermanuale.R ausführen.
library(dplyr)

times <- read.csv2("Daten/Ergebnisse/log_unit_times.csv", fileEncoding = "UTF-16LE")
sessions <- read.csv2("Daten/Ergebnisse/log_sessions.csv", fileEncoding = "UTF-16LE")
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
cb_csv <- read.csv2("Daten/Ergebnisse/codebook.csv", fileEncoding = "UTF-16LE",
                    colClasses = c(code_id = "character"))
stopifnot(identical(names(cb_csv), names(cb_selection)),
          isTRUE(all.equal(cb_csv, as.data.frame(cb_selection),
                           check.attributes = FALSE)))
csv_connection <- file("Daten/Ergebnisse/log_unit_times.csv", encoding = "UTF-16LE")
csv_lines <- readLines(csv_connection)
close(csv_connection)
stopifnot(grepl(';', csv_lines[1], fixed = TRUE),
          any(grepl('11,65', csv_lines, fixed = TRUE)))

# IQB-Studio-Vorlage nur parsen: keine Anmeldung und kein Serverzugriff.
invisible(parse("Syntaxen/06_kodiermanuale_studio.R", encoding = "UTF-8"))
stopifnot(all(c("missings_profile", "show_score", "missings") %in%
                names(formals(eatPrepTBA::prepare_codebook))),
          all(c("format", "general_instructions", "missings_profile") %in%
                names(formals(eatPrepTBA::download_codebook))))
cat("Logzeiten, Fokus, XLSX und IQB-Studio-API-Signaturen geprüft.\n")
