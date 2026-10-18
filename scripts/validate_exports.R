# Regressionstests für die synthetischen Log- und Exportbeispiele.
# Aus dem Projektordner nach 04_logs.R und 05_kodiermanuale.R ausführen.
library(dplyr)

times <- readr::read_csv("outputs/log_unit_times.csv", show_col_types = FALSE)
sessions <- readr::read_csv("outputs/log_sessions.csv", show_col_types = FALSE)
log_results <- readRDS("outputs/log_qc.rds")

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
xlsx <- "outputs/codebook.xlsx"
stopifnot(identical(openxlsx::getSheetNames(xlsx), c("Codebuch", "Auswahl")))
cb_full <- openxlsx::read.xlsx(xlsx, sheet = "Codebuch")
cb_selection <- openxlsx::read.xlsx(xlsx, sheet = "Auswahl")
u4 <- filter(cb_selection, unit_key == "U4", variable_id == "TEXT")
stopifnot(nrow(cb_full) == 22L, nrow(cb_selection) == 10L,
          setequal(cb_selection$unit_key, c("U3", "U4")),
          identical(u4$code_score[match(c("2", "1", "0"), u4$code_id)],
                    c(1, 0.5, 0)))

# IQB-Studio-Vorlage nur parsen: keine Anmeldung und kein Serverzugriff.
invisible(parse("R/06_kodiermanuale_studio.R", encoding = "UTF-8"))
stopifnot(all(c("missings_profile", "show_score", "missings") %in%
                names(formals(eatPrepTBA::prepare_codebook))),
          all(c("format", "general_instructions", "missings_profile") %in%
                names(formals(eatPrepTBA::download_codebook))))
cat("Logzeiten, Fokus, XLSX und IQB-Studio-API-Signaturen geprüft.\n")
