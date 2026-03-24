#' Get accepted taxa
#'
#' Gets backbone information of the accepted taxa of SYNONYMS, that are missing
#' from the dataset.
#'
#' The parameters are set as follows:
#' - `taxonKey`: `data$acceptedKey`
#' - `nubKey`: from GBIF backbone
#' - `taxonID`: NA
#' - `scientificName`: from GBIF backbone
#' - `acceptedKey`: NA
#' - `accepted`: NA
#' - `kingdom`: from GBIF backbone
#' - `taxonRank`: `data$taxonRank`
#' - `countryCode`: `data$countryCode`
#' - `occurrenceStatus`: `data$occurrenceStatus`
#' - `establishmentMeans`: `data$establishmentMeans`
#' - `degreeOfEstablishment`: `data$degreeOfEstablishment`
#' - `pathway`: `data$pathway`
#' - `eventDate`: `data$eventDate`
#' - `source`: `data$source`
#' - `action`: NA
#'
#' @param data A `data.frame` containing taxonomic records. Must include
#' columns: `acceptedKey`, `nubKey`, `taxonID`, `scientificName`, `kingdom`,
#' `taxonRank`, `countryCode`, `occurrenceStatus`, `establishmentMeans`,
#' `degreeOfEstablishment`, `pathway`, `eventDate`, `source`, and `action`.
#' @return A `data.frame` containing backbone taxonomy of accepted taxa merged
#' with the relevant columns from the original data.
#' @noRd
#' @examples
#' data <- data.frame(
#'   taxonKey = c(148674358, 148674363, 148674371),
#'   nubKey = c(4465638, 5752143, 3204008),
#'   taxonID = c("20006", "20002", "20010"),
#'   scientificName = c(
#'     "Euophryum confine (Broun, 1880)",
#'     "Bruchus rufimanus Boheman, 1833",
#'     "Pseudoperonospora humuli (Miyabe & Takah.) G.W.Wilson"
#'   ),
#'   acceptedKey = c(315787873, NA, 315787881),
#'   accepted = c(
#'     "Pentarthrum confine Broun, 1881",
#'     NA,
#'     "Pseudoperonospora cubensis (Berk. & M.A.Curtis) Rostovzev"
#'   ),
#'   kingdom = c("Animalia", "Animalia", "Chromista"),
#'   taxonRank = c("SPECIES", "SPECIES", "SPECIES"),
#'   countryCode = c("AD", "AD", "AD"),
#'   occurrenceStatus = c("present", "present", "present"),
#'   establishmentMeans = c("introduced", "introduced", "introduced"),
#'   degreeOfEstablishment = c(NA_character_, NA_character_, NA_character_),
#'   pathway = c(NA_character_, NA_character_, NA_character_),
#'   eventDate = c(NA_character_, NA_character_, NA_character_),
#'   source = c(NA_character_, NA_character_, NA_character_),
#'   action = c("merged_with_accepted", NA, "merged_with_accepted")
#' )
#' get_accepted(data)
get_accepted <- function(data) {
  # Get GBIF backbone taxonomy information for synonyms
  acceptedKeys <-
    data |>
    dplyr::filter(!is.na(.data$acceptedKey)) |>
    dplyr::select("acceptedKey") |>
    dplyr::distinct() |>
    dplyr::pull()

  if (!is.null(acceptedKeys) && length(acceptedKeys) > 0) {
    accepted_bb <-
      setdiff(acceptedKeys, data$nubKey) |> # Accepted keys missing
      purrr::map(
        ~ rgbif::name_usage(key = .x)$data
      ) |>
      purrr::list_rbind() |>
      dplyr::rename(
        taxonKey = "key"
      )
    # Join backbone information of accepted taxa with original data
    accepted_taxa <- data |>
      dplyr::filter(!is.na(.data$acceptedKey)) |>
      dplyr::select(
        "acceptedKey", "taxonRank", "countryCode", "occurrenceStatus",
        "establishmentMeans", "degreeOfEstablishment", "pathway", "eventDate",
        "source"
      ) |>
      dplyr::left_join(
        accepted_bb,
        by = c("acceptedKey" = "taxonKey")
      ) |>
      dplyr::rename(taxonKey = "acceptedKey") |>
      dplyr::mutate(
        taxonID = NA_character_,
        acceptedKey = NA,
        accepted = NA_character_,
        action = NA_character_
      ) |>
      dplyr::select(
        "taxonKey", "nubKey", "taxonID", "scientificName", "acceptedKey",
        "accepted", "kingdom", "taxonRank", "countryCode", "occurrenceStatus",
        "establishmentMeans", "degreeOfEstablishment", "pathway", "eventDate",
        "source", "action"
      )
  } else {
    # If there are no accepted keys, return an empty data frame
    col_names <- c(
      "taxonID", "scientificName", "acceptedKey", "accepted", "kingdom",
      "taxonRank", "countryCode", "occurrenceStatus", "establishmentMeans",
      "degreeOfEstablishment", "pathway", "eventDate", "source", "action"
    )
    accepted_taxa <- data.frame(matrix(ncol = length(col_names), nrow = 0))
    colnames(accepted_taxa) <- col_names
  }

  return(accepted_taxa)
}
