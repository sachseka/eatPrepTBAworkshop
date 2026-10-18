# Aus den Kodierschemata der Studie in IQB-Studio ein Codebuch erstellen.
# Das Codebuch dokumentiert Codes und Bewertungen für Auswertung/Weitergabe.
# prepare_codebook() bereitet diese Angaben als Tabelle auf.
# Ein vorhandenes Codebuch ist dafür nicht erforderlich.
# Erst Adresse, Version, Workspace, Unit-Namen und Profilnamen anpassen.
# Die unveränderte Vorlage stoppt vor der Anmeldung.
library(eatPrepTBA)

# 1. Zugang vorbereiten: Angaben der eigenen Studie eintragen und anmelden.
# ---- studio-codebook-settings ----
studio_url <- "https://STUDIO-ADRESSE/"
studio_version <- "VERSION-DER-ANMELDESEITE"
studio_workspace_id <- NA_integer_
selected_units <- c("UNIT-1", "UNIT-2")  # NULL wählt alle Units.
missing_profile <- "IQB-Standard"  # Name in IQB-Studio; NULL ohne Profil.
export_path <- "outputs/codebooks_studio"
if (is.na(studio_workspace_id)) {
  stop("Zuerst IQB-Studio-Adresse, Version, Workspace, Units und Profil anpassen.")
}
dir.create(export_path, recursive = TRUE, showWarnings = FALSE)
# ---- /studio-codebook-settings ----

# Anmeldung und Workspace-Zugriff benötigen ein eigenes Konto.
# ---- studio-codebook-login ----
login <- login_studio(base_url = studio_url, app_version = studio_version)
workspace <- access_workspace(login, ws_id = studio_workspace_id)
# ---- /studio-codebook-login ----

# 2. Aus den Kodierschemata der ausgewählten Units ein Codebuch erstellen.
# Die resultierende Tabelle ansehen und nach Excel schreiben.
# only_coded: nur Variablen mit Codes. show_score: Scoreangaben anfordern.
# derived: abgeleitete Variablen. manual: manuell kodierte Variablen.
# closed: geschlossen kodierbare Variablen; TRUE nimmt sie jeweils mit auf.
# ---- studio-codebook-prepare ----
cb_studio <- prepare_codebook(workspace, unit_keys = selected_units,
                              missings_profile = missing_profile,
                              only_coded = TRUE, show_score = TRUE,
                              derived = TRUE, manual = TRUE, closed = TRUE)
names(cb_studio)
head(cb_studio)
writexl::write_xlsx(cb_studio, file.path(export_path, "codebook.xlsx"))
# ---- /studio-codebook-prepare ----
# show_score fordert Scoreangaben aus IQB-Studio an, etwa in der Beschreibung.
# Eine separate numerische Spalte code_score ist hier nicht garantiert.
# Das Profil ergänzt Missing-Codes pro Variable; es definiert keine Scores.
# Ein unbekannter Profilname führt vor dem Download zu einem Fehler.

# 3. Das Kodiermanual direkt aus IQB-Studio als DOCX herunterladen.
# ---- studio-codebook-docx ----
download_codebook(workspace, path = export_path, unit_keys = selected_units,
                  format = "docx", general_instructions = TRUE,
                  missings_profile = missing_profile, show_score = TRUE)
# ---- /studio-codebook-docx ----

# Der Dateiname stammt aus dem Workspace-Namen in IQB-Studio.
# general_instructions übernimmt auch allgemeine Kodieranweisungen.
