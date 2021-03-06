download_dat <- function(zip_file, acc_file) {
  url <- "https://depts.washington.edu/ramlegac/wordpress/databaseVersions"
  downloader::download(paste0(url, "/", zip_file), destfile = "temp.zip")
  unzip("temp.zip");unlink("temp.zip")
  file.rename(acc_file, "ramlegacy.accdb")
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
#' Downloads the latest Microsoft Access version (currently version 3.0) of the
#' RAM Legacy Stock Stock Assessment Database from \url{http://ramlegacy.org} and
#' converts the database to a local sqlite3 database named
#' \code{ramlegacy.sqlite3}. As a byproduct, \code{.csv} versions of each table
#' are left in the working directory. Note that you must have the executable
#' \code{mdb-tables} installed and in your path. You can find installation
#' instructions at \url{http://mdbtools.sourceforge.net}. If you're on OS X and
#' using homebrew, you can install it with \code{brew install mdbtools}.
#'
#' @param zip_file Name of the Access .zip file you'd like to download from
#'   \url{http://ramlegacy.org}
#' @param acc_file Name of the Access .accdb file inside the zip file you'd like
#'   to download from \url{http://ramlegacy.org}.
#'
#' @return A sqlite3 database named \code{ramlegacy.sqlite3} and \code{.csv}
#'   files named after each table in the database.
#'
#' @importFrom utils read.csv unzip
#'
#' @export
#'
#' @examples
#' \dontrun{
#' make_ramlegacy()
#' }
make_ramlegacy <- function(zip_file = "RLSADB_v4.3_(assessment_data_only)_access.zip",
  acc_file = "RLSADB_v4.3_(assessment_data_only).accdb") {
  if(!file.exists("ramlegacy.accdb")) download_dat(zip_file, acc_file)
  mdb2sql()
}