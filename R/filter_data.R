#' Filter data
#'
#' Filters taxa and distributions data frames, and returns the filtered data and
#' notes.
#'
#' @param taxa Data frame as returned by `get_taxa()`.
#' @param distributions Data frame as returned by `get_distributions()`.
#'
#' @returns A list with three data frames:
#' - `taxa`: Filtered taxa data frame.
#' - `distributions`: Filtered distributions data frame, with extra column
#' `nubKey`.
#' - `notes`: Data frame with notes on taxa that were not included or replaced
#' in the filtered data.
#' @export
#' @section Filter details:
#' Taxa are removed if
#' - they are not matched with the GBIF backbone (i.e., `nubKey` is `NA`),
#' - they do not have a matching distribution (i.e., `taxonKey` is not in
#' `distributions$taxonKey`),
#' - they are synonyms of accepted taxa (i.e., `acceptedKey` is not `NA`),
#' - they do not have a matching distribution with
#' `establishmentMeans == introduced`.
#'
#' `scientificName` is replaced with the scientific name matching the GBIF
#' backbone.
#' @examples
#' # Andorra
#' datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
#' taxa <- get_taxa(datasetKey)
#' distributions <- get_distributions(datasetKey, taxa)
#' filter_data(taxa, distributions)
filter_data <- function(taxa, distributions) {
  check_taxa(taxa)
  #check_distributions(distributions)

  # Get unique nubKeys list
  nubkey_list <-
    taxa %>%
    dplyr::filter(!is.na(.data$nubKey)) %>%
    dplyr::pull(.data$nubKey) %>%
    unique() %>%
    as.list()

  backbone_names <- match_backbone(nubkey_list)

  # Join taxa, backbone names and distributions
  df_full_join <- taxa %>%
    dplyr::full_join(
      distributions,
      by = c("taxonKey"),
      keep = FALSE,
      multiple = "all",
      relationship = "many-to-many"
    ) %>%
    dplyr::rename("source_name" = "scientificName") %>%
    dplyr::left_join(backbone_names, by = c("nubKey")) %>%
    dplyr::mutate(
      action = dplyr::case_when(
        is.na(.data$nubKey) ~ "not_matched_with_backbone",
        !(taxonKey %in% distributions$taxonKey) ~ "no_matching_distribution",
        !is.na(acceptedKey) ~ "merged_with_accepted",
        is.na(.data$establishmentMeans) ~ "establishmentMeans_missing",
        .data$establishmentMeans != "introduced" ~ "establishmentMeans_not_introduced",
        .data$source_name != .data$scientificName ~
          "scientificName_replaced_by_backbone_name",
      )
    ) %>%
    dplyr::select(
      "taxonKey", "nubKey", "taxonID", "source_name", "scientificName",
      "acceptedKey", "accepted", "kingdom", "taxonRank", "countryCode",
      "occurrenceStatus", "establishmentMeans", "degreeOfEstablishment",
      "pathway", "eventDate", "source", "action"
    )

  # Add accepted taxa
  accepted <-
    get_accepted(df_full_join) %>%
    dplyr::mutate(
      source_name = NA_character_,
      .before = "scientificName"
    )
  df_full_join <-
    rbind(df_full_join, accepted)

  # Create notes
  notes <-
    df_full_join %>%
    dplyr::filter(!is.na(.data$action)) %>%
    dplyr::select(-"scientificName") %>%
    dplyr::rename("scientificName" = "source_name") %>%
    dplyr::select(
      "taxonID", "taxonKey", "scientificName", "action", "acceptedKey",
      "accepted"
    )

  # Filter out taxa without action
  df_filtered <-
    df_full_join %>%
    dplyr::filter(is.na(.data$action) | .data$action == "scientificName_replaced_by_backbone_name")

  # Create distributions
  distributions_filtered <-
    df_filtered %>%
    dplyr::select(
      "taxonKey", "nubKey", "countryCode", "occurrenceStatus",
      "establishmentMeans", "degreeOfEstablishment", "pathway", "eventDate",
      "source"
    ) %>%
    dplyr::distinct()

  # Create taxa
  taxa_filtered <-
    df_filtered %>%
    dplyr::select(
      "taxonKey", "nubKey", "taxonID", "scientificName", "acceptedKey",
      "accepted", "kingdom", "taxonRank"
    ) %>%
    dplyr::distinct()

  # Return list with data frames
  return <- list(
    taxa = dplyr::as_tibble(taxa_filtered),
    distributions = dplyr::as_tibble(distributions_filtered),
    notes = dplyr::as_tibble(notes)
  )
  return(return)
}
