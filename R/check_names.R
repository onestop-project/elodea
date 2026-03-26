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
      scientificName = scientific_name,
      rank = taxon_rank
    ) |>
    rgbif::name_backbone_checklist() |>
    dplyr::rename(rawScientificName = verbatim_scientific_name) |>
    dplyr::select(
      rawScientificName, scientificName, matchType, confidence, rank, status, acceptedUsageKey,
      acceptedScientificName
    )

  # Create summary and statistics
  summary <- dplyr::filter(match, matchType != "EXACT" | status != "ACCEPTED")

  synonyms <- dplyr::filter(match, status == "SYNONYM")
  no_match <- dplyr::filter(match, matchType != "EXACT")

  cli::cli_h2("Summary")
  cli::cli_ul(c(
    "{.value {nrow(n_synonyms)}} synonyms",
    "{.value {nrow(no_match)}} taxa with no exact match"
  ))
  cli::cli_h3("Synonyms - rawScientificName: acceptedScientificName")
  cli::cli_dl(dplyr::pull(synonyms, .data$acceptedScientificName, .data$rawScientificName))
  cli::cli_h3("No match - rawScientificName: best match")
  cli::cli_dl(dplyr::pull(no_match, .data$scientificName, .data$rawScientificName, ))

  return <- list(
    summary = dplyr::as_tibble(summary),
    full_table = dplyr::as_tibble(match)
    )

  return(return)
}
