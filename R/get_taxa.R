#' Get taxa from checklist
#'
#' Gets taxonomic information of a GBIF checklist. Only source taxa are kept,
#' denormed higher classification taxa are removed. The function
#' `rgbif::name_usage()` is used under the hood.
#' @param datasetKey GBIF dataset key.
#' @return A `tibble` with taxonomic information of the dataset.
#' @export
#' @section Taxa details:
#' `get_taxa()` returns a `tibble` with 8 variables:
#' - `taxonKey`: GBIF taxon key of `scientificName`.
#' - [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID of
#' `scientificName`, as provided in the checklist.
#' - [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName): Original
#' scientific name of the taxon in the checklist.
#' - `taxonomicStatus`: Taxonomic status of the taxon in the GBIF backbone
#' taxonomy. It can be `accepted`, `synonym`, `doubtful` or `NA` if the taxon is
#' not matched with the backbone.
#' - [`acceptedKey`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsageID): GBIF
#' taxon key of the accepted taxon, if the source `scientificName` is a synonym.
#' - [`acceptedName`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsage):
#' Scientific name of the accepted taxon.
#' - [`acceptedKingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of the
#' accepted taxon.
#' - [`acceptedTaxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank): Taxonomic
#' rank of the accepted taxon.
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

  # Call to GBIF API
  taxa_raw <- rgbif::name_usage(datasetKey = datasetKey, limit = 99999)$data

  # Clean and select relevant columns
  taxa <-
    taxa_raw |>
    # Keep only source taxa, not denormed higher classification taxa
    dplyr::filter(.data$origin == "SOURCE") |>
    dplyr::rename(taxonKey = "key") |>
    dplyr::select(
      "taxonKey", "taxonID", "scientificName", "nubKey"
    )

  # Match `nubKey` with GBIF backbone to retrieve `taxonomicStatus`,
  # `acceptedKey`, `accepted`, `rank` and `kingdom`
  nub_keys <- dplyr::pull(taxa, nubKey) |> unique()
  match_backbone <-
    get_backbone_names(nub_keys) |>
    dplyr::mutate(
      accepted = dplyr::coalesce(.data$accepted, .data$scientificName)
    ) |>
    dplyr::select(-"scientificName")
  taxa <- taxa |>
    dplyr::left_join(
      match_backbone,
      by = c("nubKey" = "key")
    )

  # Match `acceptedKey` with GBIF backbone to retrieve `accepted_taxonRank` and
  # `accepted_kingdom`
  acccepted_keys <- dplyr::pull(taxa, acceptedKey) |> unique()
  accepted_data <-
    get_backbone_names(acccepted_keys) |>
    dplyr::select("key", "rank", "kingdom") |>
    dplyr::rename(
      acceptedKey = "key",
      accepted_taxonRank = "rank",
      accepted_kingdom = "kingdom"
    )

  taxa |>
    dplyr::left_join(accepted_data, by = c("acceptedKey")) |>
    dplyr::rename(acceptedName = "accepted") |>
    dplyr::mutate(
      acceptedName = dplyr::coalesce(.data$acceptedName, .data$scientificName),
      acceptedTaxonRank = dplyr::coalesce(.data$accepted_taxonRank, .data$rank),
      acceptedKingdom = dplyr::coalesce(.data$accepted_kingdom, .data$kingdom)
    ) |>
    dplyr::select(
      "taxonKey", "taxonID", "scientificName", "taxonomicStatus", "acceptedKey",
      "acceptedName", "acceptedTaxonRank", "acceptedKingdom"
      ) |>
    dplyr::as_tibble()
}
