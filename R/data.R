#' Example checklist
#'
#' A small example checklist of alien species. The source checklist is maintained
#' in an online Google sheet, and published to the web as a CSV file.
#'
#' `example_checklist` is a CSV file with 12 records, including some taxa with
#' misspelled names and some with names that are not in the GBIF backbone
#' taxonomy, to showcase the functionality of `elodea`.
#'
#' @source Online [Google sheet](https://docs.google.com/spreadsheets/d/1Z2fsQJ3mUPLowlqAd5W5gzBeDVv80HTwhqscKZ7tYPg/edit?usp=sharing).
#' @family sample data
#' @examples
#' \dontrun{
#' # The data was created with the code below
#' csv_url <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vSGAN9RSFLKQhiFAffQOcJpmzveoNE_J7cbVurwOYiFFgTBhjlztRK9UgNSBw36FKVfPVSp4EXXS5CQ/pub?gid=716763849&single=true&output=csv"
#' example_checklist <- read.csv(csv_url)
#' usethis::use_data(example_checklist, overwrite = TRUE)
#' }
"example_checklist"


