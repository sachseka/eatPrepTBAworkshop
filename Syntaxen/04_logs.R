# 1. Pakete und Logdaten

library(eatPrepTBA)
library(dplyr)
dir.create("Daten/Ergebnisse", showWarnings = FALSE)

logs <- read_logs("Daten/Logs.csv")
# Alternativ nach API-Abruf: logs <- readRDS("Daten/EigeneDaten/logs.rds")

# Ältere Exporte haben keinen getrennten Unit-Alias.
if (!"unit_alias" %in% names(logs)) logs$unit_alias <- logs$unit_key

count(logs, group_id, login_name, booklet_id) # P001: 9, P002: 6 Ereignisse

# Einzelne Ereignisse ansehen:
logs |>
  filter(startsWith(log_entry, "PLAYER") | startsWith(log_entry, "FOCUS")) |>
  select(login_name, unit_key, ts, log_entry) |>
  head(4) |> print(width = 90)

# 2. Ereignistypen zählen

inventory <- summarise_log_inventory(logs)

inventory |>
  select(log_type, n, known_log_type, supported_parser) |>
  head(5) |> print()

# 3. Auffälligkeiten prüfen

anomalies <- detect_log_anomalies(logs)
qc <- summarise_log_qc(logs, anomalies = anomalies)

anomalies |>
  select(login_name, booklet_id, anomaly_code, severity, evidence)

qc |>
  select(login_name, booklet_id, log_qc_flag, n_anomalies) |>
  print() # P001: ok; P002: critical
# Bei P002 startet der Player nicht. QC-Flags vor einem Ausschluss prüfen.

# 4. Bearbeitungs- und Ladezeiten je Unit

unit_times <- estimate_unit_times(logs, include_environment = FALSE)

# Millisekunden in Sekunden umrechnen:
times <- unit_times |>
  transmute(group_id, login_name, login_code, booklet_id, unit_key,
            unit_n_play, unit_time_s = unit_time / 1000,
            unit_loadtime_s = unit_loadtime / 1000,
            n_run_no_load, n_failed_loadings)

times |>
  select(login_name, unit_key, unit_time_s, unit_loadtime_s) |>
  print() # P001: 11,65 s Bearbeitung, 0,35 s Laden; P002: keine Zeitzeile
# unit_time: ab RUNNING bis zum nächsten Laden oder beobachteten Ende.
# Enthält auch Fokusverluste; ohne RUNNING fehlt die Zeitzeile.
# unit_loadtime: Zeit zwischen LOADING und RUNNING.

# 5. Fokusverluste je Session

focus <- summarise_log_focus(logs)
focus_summary <- focus |>
  transmute(group_id, login_name, login_code, booklet_id,
            n_focus_lost, n_focus_regained,
            focus_lost_s = total_focus_lost_time / 1000,
            max_focus_lost_s = max_focus_lost_time / 1000,
            has_unresolved_focus_loss)

focus_summary |>
  select(login_name, n_focus_lost, focus_lost_s, has_unresolved_focus_loss) |>
  print() # P001: 2,5 s; P002: offener Fokusverlust
# Nur abgeschlossene Intervalle (HAS_NOT -> HAS) zählen zur Dauer.
# Daher steht bei P002 trotz Fokusverlust eine Summe von 0 Sekunden.
# Ein Fokusverlust allein belegt keine Unaufmerksamkeit oder Täuschung.

# 6. Ergebnisse zusammenführen und speichern

session_keys <- c("group_id", "login_name", "login_code", "booklet_id")
session_overview <- qc |>
  select(all_of(session_keys), log_qc_flag) |>
  left_join(focus_summary, by = session_keys)

# sep=; gibt Excel das Trennzeichen beim Öffnen vor.
csv <- file("Daten/Ergebnisse/log_inventory.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(inventory, csv, row.names = FALSE)
close(csv)

csv <- file("Daten/Ergebnisse/log_anomalies.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(anomalies, csv, row.names = FALSE)
close(csv)

csv <- file("Daten/Ergebnisse/log_unit_times.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(times, csv, row.names = FALSE)
close(csv)

csv <- file("Daten/Ergebnisse/log_sessions.csv", "wt", encoding = "UTF-16LE")
writeLines("sep=;", csv)
write.csv2(session_overview, csv, row.names = FALSE)
close(csv)

saveRDS(list(inventory = inventory, anomalies = anomalies, qc = qc,
             unit_times = unit_times, focus = focus), "Daten/Ergebnisse/log_qc.rds")

session_overview |>
  select(login_name, log_qc_flag, n_focus_lost, focus_lost_s) |>
  print()

# Fokusdauer gilt pro Session: nicht von jeder einzelnen Unit-Zeit abziehen.
