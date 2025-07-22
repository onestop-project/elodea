#' Get taxa from checklist
#'
#' @param datasetKey GBIF dataset key.
#'
#' @returns Taxa from checklist.
#' @export
#' @examples
#' # Belgium
#' taxa_BE <- get_taxa("6d9e952f-948c-4483-9807-575348147c7e")
#' # Cyprus
#' taxa_CY <- get_taxa("2f7ea7d1-a73f-46f6-b790-7339126a999f")
#' # Andorra
#' taxa_AD <- get_taxa("016c16c3-d907-4c88-97dd-97ad62c8130e")
get_taxa <- function(datasetKey) {
  taxa_raw <- rgbif::name_usage(datasetKey = datasetKey, limit = 99999)$data
  taxa <-
    taxa_raw %>%
    # Keep only source taxa, not denormed higher classification taxa
    dplyr::filter(origin == "SOURCE") %>%
    mutate_when_missing(acceptedKey = NA_integer_) %>%
    mutate_when_missing(accepted = NA_character_) %>%
    dplyr::select(
      "key", "nubKey", "taxonID", "scientificName", "acceptedKey", "accepted",
      "kingdom", "rank"
    ) %>%
    dplyr::rename(
      taxonKey = "key",
      taxonRank = "rank"
      ) %>%
    dplyr::as_tibble()
  return(taxa)
}
