# Logdaten: Überblick, Zeiten und Fokusverluste.
# Zuerst WSeatPrepTBA.Rproj öffnen. Alle Daten sind lokal und synthetisch.
library(eatPrepTBA)
library(dplyr)
dir.create("outputs", showWarnings = FALSE)

# 1. Testcenter-Export einlesen. Für eigene Daten den Dateipfad ersetzen.
# ---- logs-read ----
logs <- read_logs("data/Logs.csv")
# Nach einem API-Abruf alternativ: logs <- readRDS("data_eigen/logs.rds")

# Ältere Exporte enthalten nur einen Unit-Namen, keinen getrennten Alias.
if (!"unit_alias" %in% names(logs)) logs$unit_alias <- logs$unit_key

count(logs, group_id, login_name, booklet_id)
# ---- /logs-read ----

# So sehen einzelne Logeinträge aus.
# ---- logs-rohdaten-vorschau ----
logs |>
  filter(startsWith(log_entry, "PLAYER") | startsWith(log_entry, "FOCUS")) |>
  select(login_name, unit_key, ts, log_entry) |>
  head(4) |> print(width = 90)
# ---- /logs-rohdaten-vorschau ----

# 2. Welche Ereignisse sind vorhanden?
# ---- logs-inventory ----
inventory <- summarise_log_inventory(logs)
inventory |> select(log_type, n, known_log_type, supported_parser)
# ---- /logs-inventory ----

# Welche Ereignistypen kommen vor?.
# ---- logs-inventar-vorschau ----
inventory |>
  select(log_type, n, known_log_type, supported_parser) |>
  head(5) |> print()
# ---- /logs-inventar-vorschau ----

# 3. Auffälligkeiten prüfen, bevor Zeiten interpretiert werden.
# ---- logs-qc ----
anomalies <- detect_log_anomalies(logs)
qc <- summarise_log_qc(logs, anomalies = anomalies)

anomalies |>
  select(login_name, booklet_id, anomaly_code, severity, evidence)
qc |> select(group_id, login_name, booklet_id, log_qc_flag)
# ---- /logs-qc ----

# Ergebnis der Prüfung je Session.
# ---- logs-qc-vorschau ----
qc |>
  select(login_name, booklet_id, log_qc_flag, n_anomalies) |>
  print()
# ---- /logs-qc-vorschau ----
# Ein QC-Flag ist ein Prüfhinweis, keine automatische Ausschlussregel.
# Im Beispiel startet der Player bei P002 nicht und meldet einen Fehler.

# 4. Beobachtete Bearbeitungs- und Ladezeiten je Session und Unit.
# ---- logs-times ----
unit_times <- estimate_unit_times(logs, include_environment = FALSE)

# Die Funktion liefert Millisekunden; die Ausgabe verwendet Sekunden.
times <- unit_times |>
  transmute(group_id, login_name, login_code, booklet_id, unit_key,
            unit_n_play, unit_time_s = unit_time / 1000,
            unit_loadtime_s = unit_loadtime / 1000,
            n_run_no_load, n_failed_loadings)
times |> select(login_name, unit_key, unit_time_s, unit_loadtime_s)
# ---- /logs-times ----

# Beobachtete Zeiten in Sekunden.
# ---- logs-zeiten-vorschau ----
times |>
  select(login_name, unit_key, unit_time_s, unit_loadtime_s) |>
  print()
# ---- /logs-zeiten-vorschau ----
# unit_time: ab RUNNING bis zum nächsten Unit-Start oder beobachteten Ende.
# Ohne RUNNING entsteht keine Zeitzeile: Fehlende Zeit ist keine Null.
# Fokusverluste sind darin enthalten; dies ist keine reine Arbeitszeit.
# unit_loadtime kommt aus LOADING/RUNNING, nicht aus LOADCOMPLETE$loadTime.

# 5. Fokusverluste auf Session-Ebene zusammenfassen.
# ---- logs-focus ----
focus <- summarise_log_focus(logs)
focus_summary <- focus |>
  transmute(group_id, login_name, login_code, booklet_id,
            n_focus_lost, n_focus_regained,
            focus_lost_s = total_focus_lost_time / 1000,
            max_focus_lost_s = max_focus_lost_time / 1000,
            has_unresolved_focus_loss)

focus_summary |>
  select(login_name, n_focus_lost, focus_lost_s, has_unresolved_focus_loss)
# ---- /logs-focus ----

# Abgeschlossene und offene Fokusverluste.
# ---- logs-fokus-vorschau ----
focus_summary |>
  select(login_name, n_focus_lost, focus_lost_s, has_unresolved_focus_loss) |>
  print()
# ---- /logs-fokus-vorschau ----
# Nur HAS_NOT -> HAS ergibt hier eine abgeschlossene Dauer.
# Ein offener Fokusverlust trägt keine Dauer zur Summe bei.
# Deshalb kann die Summe 0 sein, obwohl ein Fokusverlust protokolliert wurde.
# Fokusverluste allein belegen weder Unaufmerksamkeit noch Täuschung.

# 6. Pro Session QC und Fokus zusammenführen und Ergebnisse speichern.
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

# QC und Fokus in einer Session-Tabelle.
# ---- logs-session-vorschau ----
session_overview |>
  select(login_name, log_qc_flag, n_focus_lost, focus_lost_s) |>
  print()
# ---- /logs-session-vorschau ----

# Für eigene Daten: Exportpfad prüfen und auffällige Sessions einzeln ansehen.
# Unit-Zeiten und Session-Fokus haben unterschiedliche Auswertungsebenen.
# Die Fokusdauer einer Session daher nicht von jeder Unit-Zeit abziehen.
