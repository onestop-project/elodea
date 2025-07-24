#' Filters data
#'
#' @param taxa Data frame as returned by `get_taxa()`.
#' @param distributions
#'
#' @returns A list with three data frames:
#' - `taxa`: Filtered taxa data frame.
#' - `distributions`: Filtered distributions data frame.
#' - `notes`: Data frame with notes on taxa that were not included in the
#' filtered data.
#' @export
#'
#' @examples
#' # Andorra
#' datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
#' taxa <- get_taxa(datasetKey)
#' distributions <- get_distributions(datasetKey)
#' filter_data(taxa, distributions, establishementMeans = c("introduced"))
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

  df_filtered <-
    df_full_join %>%
    dplyr::filter(is.na(.data$action))

  # Notes
  notes <-
    df_full_join %>%
    dplyr::filter(!is.na(.data$action)) %>%
    dplyr::select(
      taxonID, taxonKey, scientificName, action, acceptedKey, accepted
      )

  # Distributions
  distributions_filtered <-
    df_filtered %>%
    dplyr::select(
      taxonKey, countryCode, occurrenceStatus, establishmentMeans,
      degreeOfEstablishment, pathway, eventDate, source
    ) %>%
    dplyr::distinct()

  # Taxa
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
