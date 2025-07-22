#' Gets distributions
#'
#' @inheritParams get_taxa
#'
#' @returns A data frame with the following columns:
#' - taxonKey
#' - taxonID
#' - countryCode
#' - occurrenceStatus
#' - establishmentMeans
#' - degreeOfEstablishment
#' - pathway
#' - eventDate
#' - source
#' @export
#'
#' @examples
#' # Belgium
#' distributions_BE <- get_distributions("6d9e952f-948c-4483-9807-575348147c7e")
#' # Cyprus
#' distributions_CY <- get_distributions("2f7ea7d1-a73f-46f6-b790-7339126a999f")
#' # Andorra
#' distributions_AD <- get_distributions("016c16c3-d907-4c88-97dd-97ad62c8130e")
get_distributions <- function(datasetKey) {
  taxa <- get_taxa(datasetKey)
  taxon_keys <- dplyr::pull(taxa, "taxonKey")

  # Download distributions with progress bar
  progressr::with_progress({
    progress_bar <- progressr::progressor(steps = length(taxon_keys))
    distributions <-
      furrr::future_map_dfr(
        taxon_keys,
        function(x) {
          progress_bar()
          rgbif::name_usage(
            key = x,
            data = "distribution"
          )$data
        },
        .options = furrr::furrr_options(seed = TRUE)
      )
  })

  # Clean distributions
  if ("status" %in% names(distributions)) {
    distributions <-
      distributions %>%
      dplyr::rename(occurrenceStatus = "status")
  }
  if ("country" %in% names(distributions)) {
    distributions <-
      distributions %>%
      dplyr::rename(countryCode = "country")
  }
  distributions <-
    distributions %>%
    mutate_when_missing(occurrenceStatus = "present") %>%
    mutate_when_missing(establishmentMeans = NA_character_) %>%
    mutate_when_missing(degreeOfEstablishment = NA_character_) %>%
    mutate_when_missing(pathway = NA_character_) %>%
    mutate_when_missing(eventDate = NA_character_) %>%
    mutate_when_missing(source = NA_character_) %>%
    dplyr::select(
      "taxonKey",
      "countryCode",
      "occurrenceStatus",
      "establishmentMeans",
      "degreeOfEstablishment",
      "pathway",
      "eventDate",
      "source"
    ) %>%
    dplyr::mutate(
      countryCode = toupper("countryCode"),
      dplyr::across(
        c(
          "occurrenceStatus", "establishmentMeans", "degreeOfEstablishment",
          "pathway"
        ),
        tolower
      )
    )

  return(distributions)
}
