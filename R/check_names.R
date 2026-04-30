#' Checks the scientific names of a checklist
#'
#' Checks the scientific names of a checklist against the GBIF backbone
#' taxonomy.
#'
#' Matches the scientific names of a tabular checklist against the GBIF backbone
#' taxonomy. It uses `rgbif::name_backbone_checklist()` under the hood.
#' The function uses the following columns from the input checklist to perform
#' the matching process:
#' - `scientific_name`
#' - `taxon_rank`
#' - `kingdom`
#' - `phylum`
#' - `class`
#' - `order`
#' - `family`
#' - `genus`
#' Only `scientific_name` is required, while the other columns are optional.
#'
#' The function returns an extended checklist data frame, including all original
#' columns and adding (or replacing) the following columns:
#'
#' **Column name** | **Description**
#' -- | --
#' bb_scientificName | The matching scientific name from the GBIF backbone
#' bb_matchType | The type of match (e.g. "EXACT", "FUZZY", "HIGHERRANK", "NOMATCH")
#' bb_confidence | The confidence score of the match
#' bb_rank | The taxonomic rank of scientificName
#' bb_status | The taxonomic status of scientificName (e.g. "ACCEPTED", "SYNONYM", "DOUBTFUL")
#' bb_acceptedUsageKey | The GBIF backbone taxonKey/usageKey/nubkey of the accepted name (if scientificName is a synonym)
#' bb_acceptedScientificName | The accepted name (if scientificName is a synonym)
#'
#' "bb" stands for "backbone".
#'
#' @param checklist A `data.frame`.
#' @return The extended checklist data frame with the additional columns from
#' the GBIF backbone matching process.
#' @export
#' @examples
#' check_names(example_checklist)
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
      scientificName = .data$scientific_name,
      rank = .data$taxon_rank
    ) |>
    rgbif::name_backbone_checklist() |>
    dplyr::rename_with(~ paste0("bb_", .x)) |>
    dplyr::select(
      "bb_scientificName", "bb_matchType", "bb_confidence", "bb_rank",
      "bb_status", "bb_acceptedUsageKey", "bb_acceptedScientificName"
    )

  checklist <-
    checklist |>
    # Remove old "bb_"-columns
    dplyr::select(-dplyr::starts_with("bb_")) |>
    cbind(match) |>
    dplyr::as_tibble()

  # Create summary and statistics
  summary <- dplyr::filter(
    checklist, .data$bb_matchType != "EXACT" | .data$bb_status != "ACCEPTED"
    )

  synonyms <- dplyr::filter(checklist, .data$bb_status == "SYNONYM")
  no_match <- dplyr::filter(checklist, .data$bb_matchType != "EXACT")

  cli::cli_h2("Summary")
  cli::cli_ul(c(
    "{.value {nrow(synonyms)}} synonyms",
    "{.value {nrow(no_match)}} taxa with no exact match"
  ))

  return(checklist)
}
