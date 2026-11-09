#' Get distributions
#'
#' Gets the distributions of a
#' [Checklistbank](https://www.checklistbank.org/) checklist. The function
#' `rcol::clb_distribution()` is used under the hood.
#' @inheritParams get_taxa
#' @param taxa Data frame as returned by `get_taxa()`. Defaults to
#' `get_taxa(datasetKey)`
#' @return A `tibble` with distributions.
#' @family download functions
#' @export
#' @section Distributions details:
#' `get_distributions()` returns a `tibble` with 7 variables:
#' - [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID of
#' `scientificName`, as provided in the checklist.
#' - [`countryCode`](http://rs.tdwg.org/dwc/terms/countryCode):  ISO
#' 3166-1-alpha-2 country code
#' - [`establishmentMeans`](http://rs.tdwg.org/dwc/terms/establishmentMeans):
#' Statement about whether the taxon has been introduced to a given country and
#' eventDate through the direct or indirect activity of modern humans.
#' - [`degreeOfEstablishment`](http://rs.tdwg.org/dwc/terms/degreeOfEstablishment):
#' The degree to which a taxon survives, reproduces, and expands its range at
#' the given country and eventDate.
#' - [`pathway`](http://rs.tdwg.org/dwc/terms/pathway): The process by which a
#' taxon came to be in a given country at a given eventDate.
#' - [`eventDate`](http://rs.tdwg.org/dwc/terms/eventDate): The year during
#' which the taxon is present in a given country.
#' - [`source`](http://purl.org/dc/terms/source): Source reference for each
#' distribution record. Can be proper publication citation, a webpage URL, etc.
#' @examples
#' # Checklist of non-native freshwater fishes in Flanders, Belgium
#' get_distributions(30842)
get_distributions <- function(datasetKey, taxa = get_taxa(datasetKey)) {
  taxon_ids <- dplyr::pull(taxa, "taxonID")

  # Download distributions with progress bar
  progressr::with_progress({
    progress_bar <- progressr::progressor(steps = length(taxon_ids))
    distribution_list <-
      purrr::map(
        taxa$taxonID,
        ~rcol::clb_distribution(id = ., dataset = datasetKey),
        .progress = "distributions"
      )
    names(distribution_list) <- taxa$taxonID

    distributions <- dplyr::bind_rows(distribution_list, .id = "taxonID")
  })

  if (length(distributions) == 0) {
    cli::cli_alert_warning(
      "No distributions found for dataset {datasetKey}."
    )
  } else {

    # Clean distributions
    distributions |>
      mutate_when_missing(country_code = NA_character_) |>
      mutate_when_missing(establishmentMeans = NA_character_) |>
      mutate_when_missing(degreeOfEstablishment = NA_character_) |>
      mutate_when_missing(pathway = NA_character_) |>
      mutate_when_missing(year = NA_character_) |>
      mutate_when_missing(reference_citation = NA_character_) |>
      dplyr::rename(
        countryCode = "country_code",
        eventDate = "year",
        source = "reference_citation"
        ) |>
      dplyr::select(
        "taxonID",
        "countryCode",
        "establishmentMeans",
        "degreeOfEstablishment",
        "pathway",
        "eventDate",
        "source"
      ) |>
      dplyr::mutate(
        dplyr::across(
          c("establishmentMeans", "degreeOfEstablishment"),
          tolower
        ),
        establishmentMeans = dplyr::recode_values(
          .data$establishmentMeans,
          "native" ~ "native",
          "nativeReintroduced" ~ "nativeReintroduced",
          "introduced" ~ "introduced",
          "alien" ~ "introduced",
          "introducedAssistedColonisation" ~ "introducedAssistedColonisation",
          "vagrant" ~ "vagrant",
          "uncertain" ~ "uncertain",
          default = ""
        )
      ) |>
      # Remove unwanted duplicated rows with pathway = NA when there are other
      # rows with the same taxonKey and countryCode but with a non-NA pathway
      dplyr::group_by(dplyr::across(-"pathway")) |>
      dplyr::filter(
        !(dplyr::n() > 1 & is.na(.data$pathway) & any(!is.na(.data$pathway)))
        ) |>
      dplyr::ungroup()
  }
}
