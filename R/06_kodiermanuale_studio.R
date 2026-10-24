# 1. IQB-Studio-Zugang und Ausgabeordner
# Eigenes Konto nötig; im Offline-Workshop nicht ausführen.

library(eatPrepTBA)

# ---- studio-codebook-settings ----
studio_version <- "21.0.0" # Version der eigenen Anmeldeseite übernehmen
studio_workspace_id <- 1300 # Beispiel: eigene Workspace-ID einsetzen
selected_units <- c("UNIT-1", "UNIT-2") # Eigene Unit-Namen; NULL für alle
missing_profile <- "IQB-Standard" # Eigenen Profilnamen prüfen; NULL ohne Profil
export_path <- "outputs/codebooks_studio"
dir.create(export_path, recursive = TRUE, showWarnings = FALSE)
# ---- /studio-codebook-settings ----

# keyring nutzt den Passwortspeicher des Betriebssystems.
# ---- studio-codebook-login ----
login <- login_studio(app_version = studio_version, keyring = TRUE)
workspace <- access_workspace(login, ws_id = studio_workspace_id)
# ---- /studio-codebook-login ----

# 2. Codebuch aus den Kodierschemata erstellen
# only_coded: nur Variablen mit Codes; show_score: Scoreangaben anfordern.
# derived/manual/closed: abgeleitete, manuelle und geschlossene Variablen.

# ---- studio-codebook-prepare ----
cb_studio <- prepare_codebook(workspace, unit_keys = selected_units,
                              missings_profile = missing_profile,
                              only_coded = TRUE, show_score = TRUE,
                              derived = TRUE, manual = TRUE, closed = TRUE)
names(cb_studio)
head(cb_studio)
writexl::write_xlsx(cb_studio, file.path(export_path, "codebook.xlsx"))
# ---- /studio-codebook-prepare ----
# Scoreangaben stehen ggf. in der Beschreibung, nicht in einer code_score-Spalte.
# Das Profil ergänzt Missing-Codes; es legt keine Auswertungsregeln fest.

# 3. Kodiermanual als DOCX herunterladen

# ---- studio-codebook-docx ----
download_codebook(workspace, path = export_path, unit_keys = selected_units,
                  format = "docx", general_instructions = TRUE,
                  missings_profile = missing_profile, show_score = TRUE)
# ---- /studio-codebook-docx ----

# Dateiname: Workspace-Name aus IQB-Studio.
# general_instructions übernimmt auch allgemeine Kodieranweisungen.
