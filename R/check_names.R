#' Checks the scientific names of a checklist
#'
#' Checks the scientific names of a tabular checklist against the GBIF backbone
#' taxonomy. It uses `rgbif::name_backbone_checklist()` under the hood. The
#' function returns a list with two `tibble`s: `summary` and `full_table`.
#' The `summary` table contains taxa that are not an exact match or not
#' accepted, while `full_table` contains the full results of the name matching
#' process.
#'
#'
#' **Column name** | **Description**
#' -- | --
#' rawScientificName | The original scientific name as provided in the raw data file
#' scientificName | The matching scientific name from the GBIF backbone
#' matchType | The type of match (e.g. "EXACT", "FUZZY", "HIGHERRANK", "NOMATCH")
#' confidence | The confidence score of the match
#' rank | The taxonomic rank of scientificName
#' status | The taxonomic status of scientificName (e.g. "ACCEPTED", "SYNONYM", "DOUBTFUL")
#' acceptedUsageKey | The GBIF backbone taxonKey/usageKey/nubkey of the accepted name (if scientificName is a synonym)
#' acceptedScientificName | The accepted name (if scientificName is a synonym)
#'
#' @param checklist A `data.frame`.
#' @return a list of `tibble`s: `summary` and `full_table`. The `summary` table
#' contains taxa that are not an exact match or not accepted, while `full_table`
#' contains the full results of the name matching process.
#' @export
#' @examples
#' check_names(checklist)
check_names <- function(checklist) {
  if (!"scientific_name" %in% names(checklist)) {
    cli::cli_abort(
      c(
        "{.arg checklist} must have a column named {.arg scientific_name}.",
        "x" = "{.arg scientific_name} is missing."
      ),
      class = "elodea_error_scienfic_name_missing"
    )
  }

  # Match with backbone
  match <-
    checklist |>
    dplyr::mutate(
      scientificName = "scientific_name",
      rank = "taxon_rank"
    ) |>
    rgbif::name_backbone_checklist() |>
    dplyr::rename(rawScientificName = "verbatim_scientific_name") |>
    dplyr::select(
      "rawScientificName", "scientificName", "matchType", "confidence", "rank",
      "status", "acceptedUsageKey","acceptedScientificName"
    )

  # Create summary and statistics
  summary <- dplyr::filter(
    match, .data$matchType != "EXACT" | .data$status != "ACCEPTED"
    )

  synonyms <- dplyr::filter(match, .data$status == "SYNONYM")
  no_match <- dplyr::filter(match, .data$matchType != "EXACT")

  cli::cli_h2("Summary")
  cli::cli_ul(c(
    "{.value {nrow(n_synonyms)}} synonyms",
    "{.value {nrow(no_match)}} taxa with no exact match"
  ))
  cli::cli_h3("Synonyms - rawScientificName: acceptedScientificName")
  cli::cli_dl(dplyr::pull(synonyms, .data$acceptedScientificName, .data$rawScientificName))
  cli::cli_h3("No match - rawScientificName: best match")
  cli::cli_dl(dplyr::pull(no_match, .data$scientificName, .data$rawScientificName))

  return <- list(
    summary = dplyr::as_tibble(summary),
    full_table = dplyr::as_tibble(match)
    )

  return(return)
}
