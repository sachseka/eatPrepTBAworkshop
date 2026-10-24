# Fuer Autor:innen: dokumentierten Paketstand in renv.lock festhalten.
packages <- c('eatPrepTBA','eatAutoCode','eatWidget','dplyr','tidyr','readr',
              'tibble','purrr','jsonlite','knitr','rmarkdown','renv',
              'writexl')
renv::snapshot(project='.', packages=packages, lockfile='renv.lock',
               prompt=FALSE, force=TRUE)
# Den tatsächlich installierten GitHub-Stand beider Pakete festhalten.
lock <- renv::lockfile_read('renv.lock')
for (package in c('eatPrepTBA', 'eatAutoCode')) {
  installed <- utils::packageDescription(package)
  stopifnot(!is.null(installed$RemoteSha), nzchar(installed$RemoteSha))
  record <- lock$Packages[[package]]
  record$RemoteRef <- installed$RemoteSha
  record$RemoteSha <- installed$RemoteSha
  lock$Packages[[package]] <- record
}
renv::lockfile_write(lock, 'renv.lock')
