#' Checks taxa
#'
#' @param taxa Data frame as returned by `get_taxa()`.
#' @returns `taxa` invisibly or an error.
#' @export
check_taxa <- function(taxa) {
  # Check if taxa is a data frame
  if (!is.data.frame(taxa)) {
    cli::cli_abort(
      "{.arg taxa} must be a data frame.",
      class = "elodea_error_taxa_invalid_class"
    )
  }

  # Check required columns
  required_columns <- c(
    "taxonKey", "nubKey", "taxonID", "scientificName", "acceptedKey",
    "accepted", "kingdom", "taxonRank"
    )
  missing_columns <- setdiff(required_columns, names(taxa))

  if (length(missing_columns) > 0) {
      cli::cli_abort(
        c(
          "{.arg taxa} is missing 1 or more required columns.",
          "x" = "The following columns are missing: {.val {missing_columns}}."
        ),
        class = "elodea_error_taxa_missing_columns"
      )
  }

  invisible(taxa)
}
