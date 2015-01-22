download_dat <- function() {
  file <- "RLSADB_v2.5_(model_fits_included)_access"
  url <- "https://depts.washington.edu/ramlegac/wordpress/databaseVersions"
  downloader::download(paste0(url, "/", file, ".zip"), destfile = "temp.zip")
  unzip("temp.zip");unlink("temp.zip")
  file.rename("RLSADB v2.5 (model fits included).accdb", "ramlegacy.accdb")
}

mdb2sql <- function() {
  if(file.exists("ramlegacy.sqlite3")) unlink("ramlegacy.sqlite3")
  db <- dplyr::src_sqlite("ramlegacy.sqlite3", create = TRUE)
  tb <- system("mdb-tables ramlegacy.accdb", intern = TRUE)
  tb <- strsplit(tb, " ")[[1]]
  junk <- lapply(tb, function(x) {
    message(paste0("Converting table ", x))
    d <- system(paste("mdb-export ramlegacy.accdb", x), intern = TRUE)
    write(d, file = paste0(x, ".csv"))
    d2 <- read.csv(paste0(x, ".csv"), stringsAsFactors = FALSE)
    ignore <- dplyr::copy_to(db, d2, name = x, temporary = FALSE)
  })
  invisible(tb)
}

#' Make a local sqlite3 database with the RAM Legacy Stock Stock Assessment
#' Database
#'
#' Downloads the latest Microsoft Access version (currently version 2.5) of the
#' RAM Legacy Stock Stock Assessment Database from http://ramlegacy.org and
#' converts the database to a local sqlite3 database named
#' \code{ramlegacy.sqlite3}. As a byproduct, \code{.csv} versions of each table
#' are left in the working directory.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' make_ramlegacy()
#' }
make_ramlegacy <- function() {
  if(!file.exists("ramlegacy.accdb")) download_dat()
  mdb2sql()
}