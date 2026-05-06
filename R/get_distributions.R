#' Get distributions
#'
#' Gets the distributions of a GBIF dataset. The function `rgbif::name_usage()`
#' is used under the hood.
#' @inheritParams get_taxa
#' @param taxa Data frame as returned by `get_taxa()`. Defaults to
#' `get_taxa(datasetKey)`
#' @return A `tibble` with distributions.
#' @family download functions
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
#' - [`degreeOfEstablishment`](http://rs.tdwg.org/dwc/terms/degreeOfEstablishment):
#' The degree to which a taxon survives, reproduces, and expands its range at
#' the given country and eventDate.
#' - [`pathway`](http://rs.tdwg.org/dwc/terms/pathway): The process by which a
#' taxon came to be in a given country at a given eventDate.
#' - [`eventDate`](http://rs.tdwg.org/dwc/terms/eventDate): The date-time or
#' interval during which the `occurrenceStatus` is applicable for the taxon in a
#' given country.
#' - [`source`](http://purl.org/dc/terms/source): A related resource from which
#' the described resource is derived.
#' @examples
#' # Checklist of non-native freshwater fishes in Flanders, Belgium
#' get_distributions("98940a79-2bf1-46e6-afd6-ba2e85a26f9f")
get_distributions <- function(datasetKey, taxa = get_taxa(datasetKey)) {
  taxon_keys <- dplyr::pull(taxa, "taxonKey")

  # Download distributions with progress bar
  progressr::with_progress({
    progress_bar <- progressr::progressor(steps = length(taxon_keys))
    verbatim_info <-
      purrr::map(
        taxa$taxonKey,
        ~rgbif::name_usage(key = ., data = "verbatim"),
        .progress = "verbatim"
      )
    names(verbatim_info) <- taxa$taxonKey

    distribution_extension_path <- "http://rs.gbif.org/terms/1.0/Distribution"

    distributions <- purrr::imap(
      verbatim_info,
      function(x, i) {
        if (!distribution_extension_path %in% names(x$data$extensions)) {
          return(NULL)
        }
        x$data$extensions[[distribution_extension_path]] |>
          # Make a data.frame for each taxon
          purrr::map(function(x) {
            dplyr::as_tibble(x) |>
              # Rename all columns by taking the characters after the very last
              # backslash
              dplyr::rename_with(~ sub(".*\\/", "", .x))
          }) |>
          purrr::list_rbind() |>
          # Add taxon key as a new column `taxonKey`
          dplyr::mutate(taxonKey = as.integer(i))
      }
    ) |>
      purrr::list_rbind()
  })
  if (length(distributions) == 0) {
    cli::cli_alert_warning(
      "No distributions found for dataset {datasetKey}."
    )
  } else {
    # Download species profiles with progress bar
    progressr::with_progress({
      progress_bar <- progressr::progressor(steps = length(taxon_keys))
      invasiveness <-
        purrr::map(
          taxon_keys,
          function(x) {
            progress_bar()
            get_is_invasive(x)
          }
        ) |>
        purrr::list_rbind()
    })

    # Clean distributions
    if ("status" %in% names(distributions)) {
      distributions <-
        distributions |>
        dplyr::rename(occurrenceStatus = "status")
    }
    if ("country" %in% names(distributions)) {
      distributions <-
        distributions |>
        dplyr::rename(countryCode = "country")
    }

    distributions |>
      dplyr::left_join(invasiveness, by = "taxonKey") |>
      mutate_when_missing(occurrenceStatus = "present") |>
      mutate_when_missing(establishmentMeans = NA_character_) |>
      mutate_when_missing(degreeOfEstablishment = .data$is_invasive) |>
      mutate_when_missing(pathway = NA_character_) |>
      mutate_when_missing(eventDate = NA_character_) |>
      mutate_when_missing(source = NA_character_) |>
      dplyr::select(
        "taxonKey",
        "countryCode",
        "occurrenceStatus",
        "establishmentMeans",
        "degreeOfEstablishment",
        "pathway",
        "eventDate",
        "source"
      ) |>
      dplyr::mutate(
        countryCode = toupper(.data$countryCode),
        dplyr::across(
          c(
            "occurrenceStatus", "establishmentMeans", "degreeOfEstablishment",
            "pathway"
          ),
          tolower
        )
      ) |>
      # Remove unwanted duplicated rows with pathway = NA when there are other
      # rows with the same taxonKey and countryCode but with a non-NA pathway
      dplyr::group_by(dplyr::across(-.data$pathway)) |>
      dplyr::filter(
        !(dplyr::n() > 1 & is.na(.data$pathway) & any(!is.na(.data$pathway)))
        ) |>
      dplyr::ungroup() |>
      dplyr::as_tibble()
  }
}
