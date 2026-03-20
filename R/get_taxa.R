#' Get taxa from checklist
#'
#' Gets taxonomic information of a GBIF dataset. Only source taxa are kept,
#' denormed higher classification taxa are removed. The function
#' `rgbif::name_usage()` is used under the hood.
#' @param datasetKey GBIF dataset key.
#' @returns A `tibble` with taxonomic information of the dataset.
#' @export
#' @section Taxa details:
#' `get_taxa()` returns a `tibble` with 8
#' variables:
#' - `taxonKey`: GBIF taxon key within the checklist
#' - `nubKey`: GBIF backbone taxon key
#' - [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID from the
#' dataset
#' - [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName): Scientific
#' name of the taxon within the checklist
#' - [`acceptedKey`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsageID.): GBIF taxon key of the accepted taxon within the checklist, if applicable
#' - [`accepted`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsage): Scientific name of the accepted taxon within the checklist, if applicable
#' - [`kingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of the taxon
#' - [`taxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank): Taxonomic rank of
#' the taxon
#' @examples
#' # Cyprus
#' taxa_CY <- get_taxa("2f7ea7d1-a73f-46f6-b790-7339126a999f")
#' # Andorra
#' taxa_AD <- get_taxa("016c16c3-d907-4c88-97dd-97ad62c8130e")
#' \dontrun{
#' # Belgium
#' taxa_BE <- get_taxa("6d9e952f-948c-4483-9807-575348147c7e")
#' }
get_taxa <- function(datasetKey) {
  regex <- "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
  if (!grepl(regex, datasetKey)) {
    cli::cli_abort(
      "The provided {.arg datasetKey} is not a valid GBIF dataset key.",
      class = "elodea_error_invalid_datasetkey"
    )
  }
  taxa_raw <- rgbif::name_usage(datasetKey = datasetKey, limit = 99999)$data
  taxa <-
    taxa_raw |>
    # Keep only source taxa, not denormed higher classification taxa
    dplyr::filter(.data$origin == "SOURCE") |>
    mutate_when_missing(acceptedKey = NA_integer_) |>
    mutate_when_missing(accepted = NA_character_) |>
    dplyr::mutate(taxonRank = tolower(rank)) |>
    dplyr::rename(taxonKey = "key") |>
    dplyr::select(
      "taxonKey", "nubKey", "taxonID", "scientificName", "acceptedKey",
      "accepted", "kingdom", "taxonRank"
    ) |>
    dplyr::as_tibble()
  return(taxa)
}
