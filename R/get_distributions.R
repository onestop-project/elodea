#' Get distributions
#'
#' Gets the distributions of a GBIF dataset. The function `rgbif::name_usage()`
#' is used under the hood.
#' @inheritParams get_taxa
#' @param taxa Data frame as returned by `get_taxa()`. Defaults to
#' `get_taxa(datasetKey)`
#' @returns A `tibble` with distributions.
#' @export
#' @section Distributions details:
#' `get_distributions()` returns a `tibble` with 8 variables:
#' - `taxonKey`: GBIF taxon key
#' - [`countryCode`](http://rs.tdwg.org/dwc/terms/countryCode):  ISO
#' 3166-1-alpha-2 country code
#' - [`occurrenceStatus`](http://rs.tdwg.org/dwc/terms/occurrenceStatus): A
#' statement about the presence or absence of a taxon at a country. When
#' `occurrenceStatus` is missing, it is set to `present`.
#' - [`establishmentMeans`](http://rs.tdwg.org/dwc/terms/establishmentMeans):
#' Statement about whether the taxon has been introduced to a given country and
#' eventDate through the direct or indirect activity of modern humans.
#' - [`pathway`](http://rs.tdwg.org/dwc/terms/pathway): The process by which a
#' taxon came to be in a given country at a given eventDate.
#' - [`eventDate`](http://rs.tdwg.org/dwc/terms/eventDate): The date-time or
#' interval during which the `occurrenceStatus` is applicable for the taxon in a
#' given country.
#' - [`source`](http://purl.org/dc/terms/source): A related resource from which
#' the described resource is derived.
#' @examples
#' # Cyprus
#' distributions_CY <- get_distributions("2f7ea7d1-a73f-46f6-b790-7339126a999f")
#' # Andorra
#' distributions_AD <- get_distributions("016c16c3-d907-4c88-97dd-97ad62c8130e")
#' \dontrun{
#' # Belgium
#' distributions_BE <- get_distributions("6d9e952f-948c-4483-9807-575348147c7e")
#' }
get_distributions <- function(datasetKey, taxa = get_taxa(datasetKey)) {
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
      countryCode = toupper(.data$countryCode),
      dplyr::across(
        c(
          "occurrenceStatus", "establishmentMeans", "degreeOfEstablishment",
          "pathway"
        ),
        tolower
      )
    ) %>%
    dplyr::as_tibble()

  return(distributions)
}
