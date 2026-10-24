# Eigene Daten aus IQB-Studio und Testcenter abrufen.
# Benötigt eigene Zugänge; für die lokalen Workshopbeispiele nicht ausführen.

# 1. Einstellungen

# ---- api-einstellungen ----
library(eatPrepTBA)

studio_version <- "21.0.0" # genaue Version der Anmeldeseite übernehmen
studio_workspace_id <- 1300 # Beispiel; eigenen Workspace eintragen
testcenter_url <- "https://iqb-testcenter2.de/"
testcenter_workspace_id <- 35 # Beispiel; eigenen Workspace eintragen
# ---- /api-einstellungen ----

# Eigenen Ausgabeordner anlegen:
# ---- api-vorbereiten ----
dir.create("data_eigen", showWarnings = FALSE)
# ---- /api-vorbereiten ----

# 2. IQB-Studio: anmelden und Units laden
# Ohne base_url gilt https://www.iqb-studio.de/.
# Für eine andere Installation base_url ergänzen.
# keyring = TRUE speichert die Zugangsdaten lokal für weitere Anmeldungen.

# ---- studio-daten-abrufen ----
studio_login <- login_studio(app_version = studio_version, keyring = TRUE)
studio <- access_workspace(studio_login, ws_id = studio_workspace_id)

units <- get_units(studio, metadata = TRUE, unit_definition = TRUE)
saveRDS(units, "data_eigen/units.rds")
# ---- /studio-daten-abrufen ----

# metadata: Item-Verknüpfungen; unit_definition: Aufgabe und Seitenpositionen.

# Bei HTTP 401: Adresse und Zugangsdaten prüfen, einmal frisch eingeben:
# studio_login <- login_studio(app_version = studio_version, keyring = FALSE)
# Falsch gespeicherte Zugangsdaten ersetzen:
# studio_login <- login_studio(app_version = studio_version,
#                              keyring = TRUE, change_key = TRUE)
# Bei HTTP 521: genaue Studio-Version verwenden, einschließlich Beta-Zusatz.

# Kodierschema als Tabelle ergänzen und ansehen:
# ---- studio-schema-ansehen ----
units <- add_coding_scheme(units) # coding_scheme wird zu unit_codes aufbereitet.
View(units)
# ---- /studio-schema-ansehen ----
# Einzelne Tabelle öffnen: units$unit_codes[[1]]

# 3. Testcenter: anmelden und Workspace auswählen

# ---- testcenter-verbinden ----
testcenter_login <- login_testcenter(base_url = testcenter_url)
testcenter <- access_workspace(testcenter_login,
                               ws_id = testcenter_workspace_id)
# ---- /testcenter-verbinden ----

# 4. Antworten abrufen
# Das Ergebnis enthält Rohantworten für die spätere Kodierung.

# ---- antworten-abrufen ----
responses <- get_responses(testcenter)
saveRDS(responses, "data_eigen/responses.rds")

# Alternative, wenn bereits ein Antwortexport vorliegt:
# responses <- read_responses("data_eigen/Responses.csv")
# saveRDS(responses, "data_eigen/responses.rds")
# ---- /antworten-abrufen ----

# 5. Testdesign abrufen
# Benötigt Testpersonen-XML und Booklet-XMLs im Testcenter-Workspace.
# units muss zum Stand der Durchführung passen.

# ---- design-abrufen ----
design <- get_design(testcenter, units = units)
saveRDS(design, "data_eigen/design.rds")
# ---- /design-abrufen ----
# Standardfilter: Testpersonen-Logins mit mode = "run-hot-return".
# Bei anderem Testdurchführungsmodus mode ausdrücklich angeben.
# Dieser Filter betrifft das Design, nicht die Anmeldung am Testcenter.

# 6. Logs abrufen
# Alternativ: logs <- read_logs("data_eigen/Logs.csv")

# ---- logs-abrufen ----
logs <- get_logs(testcenter)
saveRDS(logs, "data_eigen/logs.rds")
# ---- /logs-abrufen ----

# 7. Abruf dokumentieren
# Nach einem IQB-Studio-Update neu anmelden und den Workspace erneut auswählen.

# ---- abruf-dokumentieren ----
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
writeLines(retrieval_info, "data_eigen/abruf.txt", useBytes = TRUE)
capture.output(sessionInfo(), file = "data_eigen/session-info.txt")
# ---- /abruf-dokumentieren ----

# Für eigene Daten den Import in R/03_datenaufbereitung.R ersetzen:
# units <- readRDS("data_eigen/units.rds")
# design <- readRDS("data_eigen/design.rds")
# responses <- readRDS("data_eigen/responses.rds")
# Dort außerdem manuelle Codes, Bereichszuordnung und Missing-Regeln anpassen.
