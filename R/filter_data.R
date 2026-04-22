#' Filter data
#'
#' Filters taxa and distributions data frames, and returns the filtered data and
#' notes.
#'
#' @param taxa Data frame as returned by `get_taxa()`.
#' @param distributions Data frame as returned by `get_distributions()`.
#'
#' @return A list with three data frames:
#' - `taxa`: Filtered taxa data frame, with different columns than the input
#' `taxa` data frame.
#' - `distributions`: Filtered distributions data frame.
#' - `notes`: Data frame with notes on taxa that were not included or replaced
#' in the filtered data.
#' @export
#' @section Filter details:
#' Taxa are removed if
#' - they are not matched with the GBIF backbone (i.e., `taxonomicStatus` is
#' `NA`),
#' - they do not have a matching distribution (i.e., `taxonKey` is not in
#' `distributions$taxonKey`),
#' - they are synonyms of accepted taxa (i.e., `acceptedKey` is not `NA`),
#' - they do not have a matching distribution with
#' `establishmentMeans == introduced`.
#'
#' `scientificName` is replaced with the scientific name matching the GBIF
#' backbone.
#' @section Taxa details:
#' The `taxa` data frame in the output list has 5 variables:
#' - `taxonKey`: GBIF taxon key of `scientificName`. This value is replaced with
#' `acceptedKey` if the taxon is a synonym of an accepted taxon.
#' - [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID of
#' `scientificName`, as provided in the checklist.
#' - [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName): Scientific
#' name of the taxon. This value is replaced with `acceptedName` for all records.
#' - [`kingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of the taxon.
#' - [`taxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank): Taxonomic rank of
#' the taxon.
#' @examples
#' # Andorra
#' datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
#' taxa <- get_taxa(datasetKey)
#' distributions <- get_distributions(datasetKey, taxa)
#' filter_data(taxa, distributions)
filter_data <- function(taxa, distributions) {
  check_taxa(taxa)
  #check_distributions(distributions)

  # Join taxa and distributions
  df_full_join <- taxa |>
    dplyr::full_join(
      distributions,
      by = c("taxonKey"),
      keep = FALSE,
      multiple = "all",
      relationship = "many-to-many"
    ) |>
    dplyr::mutate(
      action = dplyr::case_when(
        is.na(.data$taxonomicStatus) ~ "not_matched_with_backbone",
        !(.data$taxonKey %in% distributions$taxonKey) ~ "no_matching_distribution",
        .data$taxonomicStatus != "ACCEPTED" ~ "merged_with_accepted",
        is.na(.data$establishmentMeans) ~ "establishmentMeans_missing",
        .data$establishmentMeans != "introduced" ~ "establishmentMeans_not_introduced",
        .data$scientificName != .data$acceptedName ~
          "scientificName_replaced_by_backbone_name"
      )
    ) |>
    dplyr::rename(
      kingdom = "acceptedKingdom",
      taxonRank = "acceptedTaxonRank"
    ) |>
    dplyr::select(
      "taxonKey", "taxonID", "scientificName", "taxonomicStatus",
      "acceptedKey", "acceptedName", "kingdom", "taxonRank",
      "countryCode", "occurrenceStatus", "establishmentMeans",
      "degreeOfEstablishment", "pathway", "eventDate", "source", "action"
    )

  # Create notes
  notes <-
    df_full_join |>
    dplyr::filter(!is.na(.data$action)) |>
    dplyr::select(
      "taxonID", "taxonKey", "scientificName", "action", "acceptedKey",
      "acceptedName"
    )

  # Filter out taxa without action
  df_filtered <-
    df_full_join |>
    dplyr::filter(is.na(.data$action) | .data$action %in% c("scientificName_replaced_by_backbone_name", "merged_with_accepted")) |>
    dplyr::mutate(
      taxonKey = dplyr::if_else(
        .data$taxonomicStatus != "ACCEPTED", .data$acceptedKey, .data$taxonKey
        ),
      scientificName = .data$acceptedName
    )

  # Create distributions
  distributions_filtered <-
    df_filtered |>
    dplyr::select(
      "taxonKey", "countryCode", "occurrenceStatus", "establishmentMeans",
      "degreeOfEstablishment", "pathway", "eventDate", "source"
    ) |>
    dplyr::distinct()

  # Create taxa
  taxa_filtered <-
    df_filtered |>
    dplyr::select(
      "taxonKey", "taxonID", "scientificName", "kingdom", "taxonRank"
    ) |>
    dplyr::distinct()

  # Return list with data frames
  list(
    taxa = dplyr::as_tibble(taxa_filtered),
    distributions = dplyr::as_tibble(distributions_filtered),
    notes = dplyr::as_tibble(notes)
  )
}
