#' Filter data
#'
#' Filters taxa and distributions data frames, and returns the filtered data and
#' notes.
#'
#' @param taxa Data frame as returned by [get_taxa()].
#' @param distributions Data frame as returned by [get_distributions()].
#' @param establishment_means EstablishmentMeans to filter on. Only taxa
#' with matching distributions with `establishmentMeans` in this vector will be
#' retained. Default is "introduced".
#'
#' @return A list with three data frames:
#' - `taxa`: Filtered taxa data frame, with different columns than the input
#' `taxa` data frame.
#' - `distributions`: Filtered distributions data frame.
#' - `notes`: Data frame with notes on taxa that were not included or replaced
#' in the filtered data.
#' @family filter functions
#' @export
#' @section Filter on `establishmentMeans`:
#' Defaults to `NULL`, which means no filter on establishmentMeans. Possible
#' values are "native", "introduced", "nativeReintroduced",
#' "introducedAssistedColonisation", "vagrant", "uncertain" and "nativeEndemic".
#'
#' @section Filter details:
#' Taxa are removed if
#' - they are not matched with the GBIF backbone (i.e., `nubKey` is `NA`),
#' - they do not have a matching distribution (i.e., `taxonKey` is not in
#' `distributions$taxonKey`),
#' - they do not have a matching distribution with `establishmentMeans` in
#' `establishment_means`.
#'
#' Synonyms are replaced by the accepted taxa they are synonyms of (i.e.,
#' `taxonomicStatus` is either "synonym", "ambiguous synonym",
#' "heterotypic synonym", "homotypic synonym", "misapplied" or
#' "proparte synonym).
#'
#' `scientificName` is replaced with the scientific name matching the GBIF
#' backbone.
#' @section Taxa details:
#' The `taxa` data frame in the output list has 6 variables:
#' - `taxonKey`: GBIF taxon key of `scientificName`. This value is replaced with
#' `acceptedKey` if the taxon is a synonym of an accepted taxon.
#' - `nubKey`: GBIF backbone taxon key.
#' - [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID of
#' `scientificName`, as provided in the checklist.
#' - [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName): Scientific
#' name of the taxon. This value is replaced with `acceptedName` for all records.
#' - [`kingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of the taxon.
#' - [`taxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank): Taxonomic rank of
#' the taxon.
#' @examples
#' \dontrun{
#' # Updated checklist of the ants in Belgium
#' datasetKey <- "32afaa9d-a27f-4885-b30c-ce08c34e1efb"
#' taxa <- get_taxa(datasetKey)
#' distributions <- get_distributions(datasetKey, taxa)
#' filter_data(taxa, distributions, establishment_means = "introduced" )
#' }
filter_data <- function(taxa, distributions, establishment_means = NULL) {

  check_taxa(taxa)
  #check_distributions(distributions)

  establishmentMeans_values <- c(
    "native", "introduced", "nativeReintroduced",
    "introducedAssistedColonisation", "vagrant", "uncertain", "nativeEndemic"
  )

  if (!is.null(establishment_means)) {
    if (!all(establishment_means %in% establishmentMeans_values)) {
      cli::cli_abort(
        c(
          "x" = "Invalid {.arg establishment_means} value.",
          "i" = "{.arg establishment_means} must be NULL or a vector of the
         following: {establishmentMeans_values}."
        ),
        class = "elodea_error_invalid_establishmentMeans"
      )
    }
  }

  synonyms <- c(
    "AMBIGUOUS_SYNONYM", "HETEROTYPIC_SYNONYM", "HOMOTYPIC_SYNONYM",
    "MISAPPLIED", "PROPARTE_SYNONYM", "SYNONYM"
    )

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
        is.na(.data$nubKey) ~ "not_matched_with_backbone",
        !(.data$taxonKey %in% distributions$taxonKey) ~
          "no_matching_distribution",
        .data$taxonomicStatus %in% synonyms ~ "merged_with_accepted",
        !(.data$establishmentMeans %in% establishment_means) &
          !is.null(establishment_means) ~
          "filtered_on_establishmentMeans",
        .data$scientificName != .data$acceptedName ~
          "scientificName_replaced_by_backbone_name"
      )
    ) |>
    dplyr::rename(
      kingdom = "acceptedKingdom",
      taxonRank = "acceptedTaxonRank"
    ) |>
    dplyr::select(
      "taxonKey", "nubKey", "taxonID", "scientificName", "taxonomicStatus",
      "acceptedKey", "acceptedName", "kingdom", "taxonRank",
      "countryCode", "occurrenceStatus", "establishmentMeans",
      "degreeOfEstablishment", "pathway", "eventDate", "source", "action"
    )

  # Create notes
  notes <-
    df_full_join |>
    dplyr::filter(!is.na(.data$action)) |>
    dplyr::mutate(
      acceptedName = dplyr::if_else(
        .data$action == "not_matched_with_backbone", NA_character_, .data$acceptedName
      )
    ) |>
    dplyr::select(
      "taxonID", "taxonKey", "scientificName", "action", "acceptedKey",
      "acceptedName"
    )

  # Filter out taxa without action
  df_filtered <-
    df_full_join |>
    dplyr::filter(
      is.na(.data$action) | .data$action %in% c(
        "scientificName_replaced_by_backbone_name", "merged_with_accepted"
        )
      ) |>
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
      "taxonKey", "nubKey", "countryCode", "occurrenceStatus", "establishmentMeans",
      "degreeOfEstablishment", "pathway", "eventDate", "source"
    ) |>
    dplyr::distinct()

  # Create taxa
  taxa_filtered <-
    df_filtered |>
    dplyr::select(
      "taxonKey", "nubKey", "taxonID", "scientificName", "kingdom", "taxonRank"
    ) |>
    dplyr::distinct()

  # Return list with data frames
  list(
    taxa = dplyr::as_tibble(taxa_filtered),
    distributions = dplyr::as_tibble(distributions_filtered),
    notes = dplyr::as_tibble(notes)
  )
}
