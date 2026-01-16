#' Create columns, but only if they don't exist yet!
#'
#' Using dplyr::mutate(), add a new column, but only if it's missing.
#'
#' @inherit dplyr::mutate
#' @noRd
#' @examples
#' \dontrun{
#' # Doesn't add a column when it already exists
#' mutate_when_missing(cars, speed = "warp 9")
#' # But does add a column when it doesn't exist yet
#' mutate_when_missing(cars, space = "The final frontier")
#' }
mutate_when_missing <- function(.data, ...){
  dots <- substitute(list(...))[-1]
  cols_to_check <- names(sapply(dots, deparse))
  columns_to_add <- cols_to_check[!cols_to_check %in% colnames(.data)]
  if (!rlang::is_empty(columns_to_add)){.data <- dplyr::mutate(.data,...)}
  return(.data)
}

#' Match a list of `nubKey`s to GBIF backbone names
#'
#' @param nubkey_list A vector of GBIF backbone taxon keys
#'
#' @return A data frame with `nubKey` and `scientificName`.
#' @noRd
match_backbone <- function(nubkey_list) {
  nubkey_list |>
    purrr::map_dfr(
      ~ rgbif::name_usage(key = .x)$data
    ) |>
    dplyr::select("key", "scientificName") |>
    dplyr::rename("nubKey" = "key")
}

#' Get invasiveness status from species profile
#'
#' Sends an request to the GBIF API to fetch verbatim species data. It extracts
#' the 'isInvasive' field from the SpeciesProfile extension if present. If the
#' information is not available, it returns NA.
#'
#' @param taxonKey GBIF taxon key.
#' @return A data frame with 2 columns: taxonKey and is_invasive.
#' @noRd
#' @examples
#' \dontrun{
#'   get_is_invasive(2435099)
#'   get_is_invasive("2435099")
#' }
get_is_invasive <- function(taxonKey) {
  url <- paste0("https://api.gbif.org/v1/species/", taxonKey, "/verbatim")
  resp <- httr::GET(url)
  data <- jsonlite::fromJSON(
    httr::content(resp, as = "text", encoding = "UTF-8")
    )
  is_invasive <- data$extensions$`http://rs.gbif.org/terms/1.0/SpeciesProfile`$`http://rs.gbif.org/terms/1.0/isInvasive`
  if (is.null(is_invasive)){is_invasive <- NA}
  df <- data.frame(taxonKey = taxonKey) |>
    dplyr::mutate(
      is_invasive = is_invasive
    )
  return(df)
}
