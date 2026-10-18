# Prüft die Demo gegen die unabhängig festgelegten Antworten und Tutorialregeln.
source("R/02_daten_verstehen.R", encoding = "UTF-8")

stopifnot(nrow(pc_units) == 1L, nrow(pc_responses) == 4L)
stopifnot(nrow(raw_values) == 12L, nrow(pc_coded) == 16L)
stopifnot(identical(unique(raw_values$variable_id), c("01a", "01b", "01c")))
stopifnot(all(pc_coded$code_status == "CODING_COMPLETE"))

# Vorgabe aus dem Tutorial: drei richtig = 2, zwei richtig = 1, sonst = 0.
pc_expected <- tibble::tibble(login_name = paste0("D", 1:4),
  code_id = c(1L, 2L, 0L, 0L), code_score = c(2, 1, 0, 0))
pc_actual <- pc_items |>
  arrange(login_name) |>
  select(login_name, code_id, code_score)
stopifnot(isTRUE(all.equal(pc_actual, pc_expected, check.attributes = FALSE)))
stopifnot(all(pc_items$item_id == "RECHNEN_01"))
stopifnot(all(pc_items$variable_id == "01"))

# Der importierte Codefall enthält dieselben bewusst gespeicherten Werte.
pc_imported <- stored_codes |>
  arrange(login_name) |>
  select(login_name, code_id, code_score)
stopifnot(isTRUE(all.equal(pc_imported, pc_expected,
                           check.attributes = FALSE)))
stopifnot(!"code_type" %in% names(stored_codes))
stopifnot(!"code_score" %in% names(raw_values))

cat("Partial-Credit-Demo und Import vorhandener Codes erfolgreich geprüft.\n")
