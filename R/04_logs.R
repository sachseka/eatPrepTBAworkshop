# 1. Pakete und Logdaten

library(eatPrepTBA)
library(dplyr)
dir.create("outputs", showWarnings = FALSE)

# ---- logs-read ----
logs <- read_logs("data/Logs.csv")
# Alternativ nach API-Abruf: logs <- readRDS("data_eigen/logs.rds")

# Ältere Exporte haben keinen getrennten Unit-Alias.
if (!"unit_alias" %in% names(logs)) logs$unit_alias <- logs$unit_key

count(logs, group_id, login_name, booklet_id) # P001: 9, P002: 6 Ereignisse
# ---- /logs-read ----

# Einzelne Ereignisse ansehen:
# ---- logs-rohdaten-vorschau ----
logs |>
  filter(startsWith(log_entry, "PLAYER") | startsWith(log_entry, "FOCUS")) |>
  select(login_name, unit_key, ts, log_entry) |>
  head(4) |> print(width = 90)
# ---- /logs-rohdaten-vorschau ----

# 2. Ereignistypen zählen

# ---- logs-inventory ----
inventory <- summarise_log_inventory(logs)
# ---- /logs-inventory ----

# ---- logs-inventar-vorschau ----
inventory |>
  select(log_type, n, known_log_type, supported_parser) |>
  head(5) |> print()
# ---- /logs-inventar-vorschau ----

# 3. Auffälligkeiten prüfen

# ---- logs-qc ----
anomalies <- detect_log_anomalies(logs)
qc <- summarise_log_qc(logs, anomalies = anomalies)

anomalies |>
  select(login_name, booklet_id, anomaly_code, severity, evidence)
# ---- /logs-qc ----

# ---- logs-qc-vorschau ----
qc |>
  select(login_name, booklet_id, log_qc_flag, n_anomalies) |>
  print() # P001: ok; P002: critical
# ---- /logs-qc-vorschau ----
# Bei P002 startet der Player nicht. QC-Flags vor einem Ausschluss prüfen.

# 4. Bearbeitungs- und Ladezeiten je Unit

# ---- logs-times ----
unit_times <- estimate_unit_times(logs, include_environment = FALSE)

# Millisekunden in Sekunden umrechnen:
times <- unit_times |>
  transmute(group_id, login_name, login_code, booklet_id, unit_key,
            unit_n_play, unit_time_s = unit_time / 1000,
            unit_loadtime_s = unit_loadtime / 1000,
            n_run_no_load, n_failed_loadings)
# ---- /logs-times ----

# ---- logs-zeiten-vorschau ----
times |>
  select(login_name, unit_key, unit_time_s, unit_loadtime_s) |>
  print() # P001: 11,65 s Bearbeitung, 0,35 s Laden; P002: keine Zeitzeile
# ---- /logs-zeiten-vorschau ----
# unit_time: ab RUNNING bis zum nächsten Laden oder beobachteten Ende.
# Enthält auch Fokusverluste; ohne RUNNING fehlt die Zeitzeile.
# unit_loadtime: Zeit zwischen LOADING und RUNNING.

# 5. Fokusverluste je Session

# ---- logs-focus ----
focus <- summarise_log_focus(logs)
focus_summary <- focus |>
  transmute(group_id, login_name, login_code, booklet_id,
            n_focus_lost, n_focus_regained,
            focus_lost_s = total_focus_lost_time / 1000,
            max_focus_lost_s = max_focus_lost_time / 1000,
            has_unresolved_focus_loss)
# ---- /logs-focus ----

# ---- logs-fokus-vorschau ----
focus_summary |>
  select(login_name, n_focus_lost, focus_lost_s, has_unresolved_focus_loss) |>
  print() # P001: 2,5 s; P002: offener Fokusverlust
# ---- /logs-fokus-vorschau ----
# Nur abgeschlossene Intervalle (HAS_NOT -> HAS) zählen zur Dauer.
# Daher steht bei P002 trotz Fokusverlust eine Summe von 0 Sekunden.
# Ein Fokusverlust allein belegt keine Unaufmerksamkeit oder Täuschung.

# 6. Ergebnisse zusammenführen und speichern

# ---- logs-export ----
session_keys <- c("group_id", "login_name", "login_code", "booklet_id")
session_overview <- qc |>
  select(all_of(session_keys), log_qc_flag) |>
  left_join(focus_summary, by = session_keys)

readr::write_csv(inventory, "outputs/log_inventory.csv")
readr::write_csv(anomalies, "outputs/log_anomalies.csv")
readr::write_csv(times, "outputs/log_unit_times.csv")
readr::write_csv(session_overview, "outputs/log_sessions.csv")
saveRDS(list(inventory = inventory, anomalies = anomalies, qc = qc,
             unit_times = unit_times, focus = focus), "outputs/log_qc.rds")
# ---- /logs-export ----

# ---- logs-session-vorschau ----
session_overview |>
  select(login_name, log_qc_flag, n_focus_lost, focus_lost_s) |>
  print()
# ---- /logs-session-vorschau ----

# Fokusdauer gilt pro Session: nicht von jeder einzelnen Unit-Zeit abziehen.
