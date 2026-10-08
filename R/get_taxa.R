#' Get taxa from checklist
#'
#' Gets taxonomic information of a
#' [Checklistbank](https://www.checklistbank.org/) checklist and matches the
#' [Catalogue of Life](https://www.catalogueoflife.org/) (COL)  taxonomy. Only
#' source taxa are kept, denormed higher classification taxa are removed.
#'
#' @param datasetKey Checklistbank dataset key. It can be deducted from the
#' URL of a checklist, e.g. `https://www.checklistbank.org/dataset/22856`
#' @return A `tibble` with taxonomic information of the dataset.
#' @family download functions
#' @export
#' @section Taxa details:
#' `get_taxa()` returns a `tibble` with 7 columns:
#' - `usage_id`: COL taxon key
#' - [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID of
#' `scientificName`, as provided in the checklist.
#' - [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName): Original
#' scientific name of the taxon in the checklist.
#' - `taxonomicStatus`: Taxonomic status of the taxon in COL. It can be
#' `accepted`, `synonym`, `doubtful` or `NA` if the taxon is not matched with
#' COL.
#' - [`acceptedKey`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsageID): COL
#' taxon key of the accepted taxon, if the source `scientificName` is a synonym.
#' - [`acceptedName`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsage):
#' Scientific name of the accepted taxon.
#' `scientificName` is the accepted name in the GBIF backbone.
#' - [`acceptedTaxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank): Taxonomic
#' rank of the accepted taxon.
#' @examples
#' # Global Register of Introduced and Invasive Species - Sovereign Base Areas
#' # of Cyprus, Cyprus
#' get_taxa(22856)
get_taxa <- function(datasetKey) {
  regex <- "^[0-9]+$"
  if (!grepl(regex, datasetKey)) {
    cli::cli_abort(
      "The provided {.arg datasetKey} is not a valid ChecklistBank dataset key.",
      class = "elodea_error_invalid_datasetkey"
    )
  }

  # Call to Checklistbank API
  taxa_raw <- rcol::clb_usage_search(dataset = datasetKey, limit = Inf)$data

  # Clean and select relevant columns
  taxa <-
    taxa_raw |>
    # Keep only source taxa, not denormed higher classification taxa
    dplyr::filter(.data$origin == "source") |>
    dplyr::rename(
      taxonID = "id",
      verbatim_name = "label"
      ) |>
    dplyr::select("taxonID", "verbatim_name")

  # Match `verbatim_name` with COL to retrieve `taxonomicStatus`,
  # `acceptedKey`, `accepted` and `rank`
  labels <- dplyr::pull(taxa, "verbatim_name") |>
    unique() |>
    purrr::discard(is.na)
  match_backbone <-
    rcol::col_match_checklist(labels) |>
    mutate_when_missing("acceptedKey" = NA_character_) |>
    mutate_when_missing("accepted" = NA_character_) |>
    dplyr::rename(
      scientificName = "label",
      taxonomicStatus = "status",
      taxonRank = "rank",
    ) |>
    dplyr::mutate(
      acceptedKey = dplyr::coalesce(.data$acceptedKey, .data$usage_id),
      accepted = dplyr::coalesce(.data$accepted, .data$scientificName)
    ) |>
    dplyr::select(dplyr::any_of(c(
      "verbatim_name", "usage_id", "taxonomicStatus", "taxonRank",
      "acceptedKey", "accepted"
    )))
  taxa <- taxa |>
    dplyr::left_join(
      match_backbone,
      by = dplyr::join_by("verbatim_name")
    )

  # Match `acceptedKey` with COL to retrieve `accepted_taxonRank`
  accepted_keys <- dplyr::pull(taxa, "acceptedKey") |> unique()
  accepted_data <-
    accepted_keys |>
    purrr::map(~ rcol::col_usage(id = .x)) |>
    purrr::list_rbind() |>
    dplyr::select("id", "rank") |>
    dplyr::rename(
      acceptedKey = "id",
      accepted_taxonRank = "rank"
    )

  taxa |>
    dplyr::left_join(accepted_data, by = c("acceptedKey")) |>
    dplyr::rename(
      acceptedName = "accepted",
      "scientificName" = "verbatim_name"
      ) |>
    dplyr::mutate(
      acceptedTaxonRank = dplyr::coalesce(.data$accepted_taxonRank, .data$taxonRank)
    ) |>
    dplyr::select(
      "usage_id", "taxonID", "scientificName", "taxonomicStatus",
      "acceptedKey", "acceptedName", "acceptedTaxonRank"
      ) |>
    dplyr::arrange(.data$taxonID) |>
    dplyr::as_tibble()
}
