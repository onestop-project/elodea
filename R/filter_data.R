#' Filter data
#'
#' Filters taxa and distributions data frames, and returns the filtered data and
#' notes.
#'
#' @param taxa Data frame as returned by `get_taxa()`.
#' @param distributions Data frame as returned by `get_distributions()`.
#' @param establishmentMeans Character vector of `establishmentMeans` to filter.
#' Defaults to `c("introduced")`.
#'
#' @returns A list with three data frames:
#' - `taxa`: Filtered taxa data frame.
#' - `distributions`: Filtered distributions data frame.
#' - `notes`: Data frame with notes on taxa that were not included in the
#' filtered data.
#' @export
#' @section Filter details:
#' Taxa are removed if
#' - they are not matched with the GBIF backbone (i.e., `nubKey` is `NA`),
#' - they do not have a matching distribution (i.e., `taxonKey` is not in
#' `distributions$taxonKey`),
#' - they are synonyms of accepted taxa (i.e., `acceptedKey` is not `NA`),
#' - they do not have a matching distribution with a provided
#' `establishmentMeans`.
#' @examples
#' # Andorra
#' datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
#' taxa <- get_taxa(datasetKey)
#' distributions <- get_distributions(datasetKey)
#' filter_data(taxa, distributions, establishmentMeans = c("introduced"))
filter_data <- function(taxa, distributions,
                        establishmentMeans = c("introduced")) {
  check_taxa(taxa)
  #check_distributions(distributions)

  # Join taxa and distributions
  df_full_join <- taxa %>%
    dplyr::full_join(
      distributions,
      by = c("taxonKey"),
      keep = FALSE,
      multiple = "all",
      relationship = "many-to-many"
    ) %>%
    dplyr::mutate(
      action = dplyr::case_when(
        is.na(.data$nubKey) ~ "not_matched_with_backbone",
        !(taxonKey %in% distributions$taxonKey) ~ "no_matching_distribution",
        !is.na(acceptedKey) ~ "merged_with_accepted",
        !.data$establishmentMeans %in% establishmentMeans ~
          paste0(
            "establishmentMeans not one of: ",
            paste(establishmentMeans, collapse = ", ")
          ),
      )
    )
  # Add accepted taxa
  df_full_join <-
    df_full_join %>%
    rbind(get_accepted(df_full_join))

  # Create notes
  notes <-
    df_full_join %>%
    dplyr::filter(!is.na(.data$action)) %>%
    dplyr::select(
      taxonID, taxonKey, scientificName, action, acceptedKey, accepted
    )

  # Filter out taxa without action
  df_filtered <-
    df_full_join %>%
    dplyr::filter(is.na(.data$action))

  # Create distributions
  distributions_filtered <-
    df_filtered %>%
    dplyr::select(
      taxonKey, countryCode, occurrenceStatus, establishmentMeans,
      degreeOfEstablishment, pathway, eventDate, source
    ) %>%
    dplyr::distinct()

  # Create taxa
  taxa_filtered <-
    df_filtered %>%
    dplyr::select(
      taxonKey, nubKey, taxonID, scientificName, acceptedKey, accepted, kingdom,
      taxonRank
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
