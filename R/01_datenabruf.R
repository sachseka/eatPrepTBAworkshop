# Vorlage für Realdaten: IQB-Studio-Metadaten und Testcenter-Daten abrufen.
# Für den Workshop ist dieser Abruf nicht erforderlich.
# Eigene Konten und Berechtigungen für beide Workspaces werden benötigt.
# Erst die Platzhalter ersetzen, dann abschnittsweise ausführen.

# ---- api-einstellungen ----
library(eatPrepTBA)

studio_url <- "https://STUDIO-ADRESSE/"
studio_version <- "VERSION-DER-ANMELDESEITE"
studio_workspace_id <- NA_integer_
testcenter_url <- "https://TESTCENTER-ADRESSE/"
testcenter_workspace_id <- NA_integer_
test_mode <- "run-hot-return"
# ---- /api-einstellungen ----

# Die genaue IQB-Studio-Version einschließlich eines Beta-Zusatzes übernehmen.
# Workspace-IDs und Anmeldemodus müssen zur eigenen Erhebung passen.
# ---- api-vorbereiten ----
dir.create("data_eigen", showWarnings = FALSE)
# ---- /api-vorbereiten ----

# 1. IQB-Studio: anmelden, Workspace wählen, Units laden.
# Die Anmeldung fragt die Zugangsdaten ab.
# metadata liefert Item-Verknüpfungen, unit_definition Seiteninformationen.

# ---- studio-daten-abrufen ----
studio_login <- login_studio(base_url = studio_url,
                             app_version = studio_version)
studio <- access_workspace(studio_login, ws_id = studio_workspace_id)

units <- get_units(studio, metadata = TRUE, unit_definition = TRUE)
saveRDS(units, "data_eigen/units.rds")
# ---- /studio-daten-abrufen ----

# coding_scheme enthält das Kodierschema. Optional: als Tabelle ansehen.
# code_responses(..., prepare = TRUE) ergänzt unit_codes bei Bedarf selbst.
# ---- studio-schema-ansehen ----
units <- add_coding_scheme(units)
names(units$unit_codes[[1]])
# ---- /studio-schema-ansehen ----

# 2. Testcenter: anmelden und den Workspace der Durchführung wählen.

# ---- testcenter-verbinden ----
testcenter_login <- login_testcenter(base_url = testcenter_url)
testcenter <- access_workspace(testcenter_login,
                               ws_id = testcenter_workspace_id)
# ---- /testcenter-verbinden ----

# 3. Antworten direkt abrufen.
# get_responses() liefert Rohantworten für die folgende Autokodierung.
# Nur eine Importvariante verwenden; ein CSV ist die Alternative zum API-Abruf.

# ---- antworten-abrufen ----
responses <- get_responses(testcenter)
saveRDS(responses, "data_eigen/responses.rds")

# Alternative, wenn bereits ein Antwortexport vorliegt:
# responses <- read_responses("data_eigen/Responses.csv")
# saveRDS(responses, "data_eigen/responses.rds")
# ---- /antworten-abrufen ----

# 4. Das vollständige Design abrufen.
# Im Workspace müssen Testpersonen-XML und zugehörige Booklet-XMLs liegen.
# units muss alle relevanten Units im Stand der Durchführung enthalten.
# Ein Antwort-CSV allein ersetzt diese Designinformationen nicht.

# ---- design-abrufen ----
design <- get_design(testcenter, units = units, mode = test_mode)
saveRDS(design, "data_eigen/design.rds")
# ---- /design-abrufen ----

# 5. Logs für die anschließende Logauswertung sichern.
# Alternativ: logs <- read_logs("data_eigen/Logs.csv")

# ---- logs-abrufen ----
logs <- get_logs(testcenter)
saveRDS(logs, "data_eigen/logs.rds")
# ---- /logs-abrufen ----

# 6. Stand des Abrufs festhalten.
# Nach einem IQB-Studio-Update neu anmelden und den Workspace erneut auswählen.

# ---- abruf-dokumentieren ----
retrieval_info <- c(
  paste("Abruf:", format(Sys.time(), tz = "Europe/Berlin", usetz = TRUE)),
  paste("eatPrepTBA:", packageVersion("eatPrepTBA")),
  paste("IQB-Studio:", studio_url, "Version:", studio_version),
  paste("IQB-Studio-Workspace:", studio_workspace_id),
  paste("Testcenter:", testcenter_url),
  paste("Testcenter-Workspace:", testcenter_workspace_id),
  paste("Anmeldemodus:", test_mode))
writeLines(retrieval_info, "data_eigen/abruf.txt", useBytes = TRUE)
capture.output(sessionInfo(), file = "data_eigen/session-info.txt")
# ---- /abruf-dokumentieren ----

# In R/03_datenaufbereitung.R den Import durch diese drei Zeilen ersetzen:
# units <- readRDS("data_eigen/units.rds")
# design <- readRDS("data_eigen/design.rds")
# responses <- readRDS("data_eigen/responses.rds")
# Dort außerdem manuelle Codes, Bereichszuordnung und Missing-Regeln anpassen.
