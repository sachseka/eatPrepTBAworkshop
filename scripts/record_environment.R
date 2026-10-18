# Fuer Autor:innen: dokumentierten Paketstand in renv.lock festhalten.
packages <- c('eatPrepTBA','eatAutoCode','eatWidget','dplyr','tidyr','readr',
              'tibble','purrr','jsonlite','knitr','rmarkdown','renv',
              'writexl')
renv::snapshot(project='.', packages=packages, lockfile='renv.lock',
               prompt=FALSE, force=TRUE)
# Lokal aus dem Checkout installiert; die oeffentliche Quelle explizit festhalten.
lock <- renv::lockfile_read('renv.lock')
record <- lock$Packages$eatPrepTBA
record$Source <- 'GitHub'
record$RemoteType <- 'github'
record$RemoteHost <- 'api.github.com'
record$RemoteUsername <- 'iqb-research'
record$RemoteRepo <- 'eatPrepTBA'
record$RemoteRef <- '5e1a0ac1fe736bcafd6338231bf57df1172c9d56'
record$RemoteSha <- record$RemoteRef
lock$Packages$eatPrepTBA <- record
renv::lockfile_write(lock, 'renv.lock')
