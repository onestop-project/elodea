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

#' Gets GBIF backbone names based on a list of `nubKey`s
#'
#' @param nub_keys A vector of GBIF backbone taxon keys
#'
#' @return A data frame with `key`, `taxonomicStatus`, `acceptedKey`,
#' `accepted`, `rank` and `kingdom` columns, if available.
#' @noRd
#' @examples
#' nub_keys <- c(1589999, 8411684, 4465638, 1047536, 1047341, 5752155, NA,
#' 5752143, 1047525, 3204008, 2576553, 3109086, 2891783, 3173338)
#' get_backbone_names(nub_keys)
get_backbone_names <- function(nub_keys) {
  nub_keys |>
    purrr::discard(is.na) |>
    purrr::map(~ rgbif::name_usage(key = .x)$data) |>
    purrr::list_rbind() |>
    dplyr::select(dplyr::any_of(c(
      "key", "scientificName", "taxonomicStatus", "acceptedKey", "accepted",
      "rank", "kingdom"
    )))
}

#' Get invasiveness status from species profile
#'
#' Sends a request to the GBIF API to fetch verbatim species data. It extracts
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
