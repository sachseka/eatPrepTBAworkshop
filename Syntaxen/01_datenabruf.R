# Eigene Daten aus IQB-Studio und Testcenter abrufen.
# Benötigt eigene Zugänge; für die lokalen Workshopbeispiele nicht ausführen.

# 1. Einstellungen

library(eatPrepTBA)

studio_version <- "21.0.0" # genaue Version der Anmeldeseite übernehmen
studio_workspace_id <- 1300 # Beispiel; eigenen Workspace eintragen
testcenter_url <- "https://iqb-testcenter2.de/" # Beispiel
testcenter_workspace_id <- 35 # Beispiel; eigenen Workspace eintragen

# Eigenen Ausgabeordner anlegen:
dir.create("Daten/EigeneDaten", showWarnings = FALSE)

# 2. IQB-Studio: anmelden und Units laden
# (keyring = TRUE speichert die Zugangsdaten lokal für weitere Anmeldungen.)

studio_login <- login_studio(app_version = studio_version, keyring = TRUE)
studio <- access_workspace(studio_login, ws_id = studio_workspace_id)

units <- get_units(studio, metadata = TRUE, unit_definition = TRUE)
saveRDS(units, "Daten/EigeneDaten/units.rds")

# Bei Fehler HTTP 401: Adresse und Zugangsdaten prüfen, einmal frisch eingeben:
# studio_login <- login_studio(app_version = studio_version, keyring = FALSE)
# Falsch gespeicherte Zugangsdaten ersetzen:
# studio_login <- login_studio(app_version = studio_version,
#                              keyring = TRUE, change_key = TRUE)
# Bei Fehler HTTP 521: genaue Studio-Version verwenden, einschließlich Beta-Zusatz.

# Kodierschema als Tabelle ergänzen und ansehen:
units <- add_coding_scheme(units) # coding_scheme wird zu unit_codes aufbereitet.
View(units)
# Einzelne Tabelle öffnen: units$unit_codes[[1]]

# Kodierschema im Workspace prüfen; noch keine Antworten kodieren:
coding_report <- get_coding_report(studio)
head(coding_report)
coding_report$validation_problems[[1]]
saveRDS(coding_report, "Daten/EigeneDaten/coding_report.rds")

# Metadaten aufbereiten; Profildefinitionen werden ggf. online nachgeladen.
units_meta <- add_metadata(units)
head(units_meta)
units_meta$unit_metadata[[1]]
units_meta$item_metadata[[1]]
saveRDS(units_meta, "Daten/EigeneDaten/units_metadata.rds")

# 3. Testcenter: anmelden und Workspace auswählen

testcenter_login <- login_testcenter(base_url = testcenter_url)
testcenter <- access_workspace(testcenter_login,
                               ws_id = testcenter_workspace_id)

# 4. Antworten abrufen
# Das Ergebnis enthält Rohantworten für die spätere Kodierung.

responses <- get_responses(testcenter)
saveRDS(responses, "Daten/EigeneDaten/responses.rds")

# Alternative, wenn bereits ein Antwortexport vorliegt:
# responses <- read_responses("Daten/EigeneDaten/Responses.csv")
# saveRDS(responses, "Daten/EigeneDaten/responses.rds")

# 5. Testdesign abrufen
# Benötigt Testpersonen-XML und Booklet-XMLs im Testcenter-Workspace.
# units muss zum Stand der Durchführung passen.

design <- get_design(testcenter, units = units)
saveRDS(design, "Daten/EigeneDaten/design.rds")

# Standardfilter: Testpersonen-Logins mit mode = "run-hot-return".
# Bei anderem Testdurchführungsmodus mode ausdrücklich angeben.
# Dieser Filter betrifft das Design, nicht die Anmeldung am Testcenter.
# Weitere Erklärungen siehe Folien/Vignetten.

# 6. Logs abrufen
# Alternativ: logs <- read_logs("Daten/EigeneDaten/Logs.csv")

logs <- get_logs(testcenter)
saveRDS(logs, "Daten/EigeneDaten/logs.rds")

# 7. Abruf dokumentieren
# Nach einem IQB-Studio-Update neu anmelden und den Workspace erneut auswählen.

retrieval_info <- c(
  paste("Abruf:", format(Sys.time(), tz = "Europe/Berlin", usetz = TRUE)),
  paste("eatPrepTBA:", packageVersion("eatPrepTBA")),
  paste("IQB-Studio:", studio_login@base_url,
        "Version:", studio_login@app_version),
  paste("IQB-Studio-Workspace:", studio_workspace_id),
  paste("Testcenter:", testcenter_url),
  paste("Testcenter-Workspace:", testcenter_workspace_id),
  paste("Testdurchführungsmodus im Design:",
        paste(unique(design$login_mode), collapse = ", ")))
writeLines(retrieval_info, "Daten/EigeneDaten/abruf.txt", useBytes = TRUE)
capture.output(sessionInfo(), file = "Daten/EigeneDaten/session-info.txt")
