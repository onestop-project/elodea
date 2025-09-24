test_that("check_taxa() returns an invisible taxa object when valid", {
  skip_if_offline()
  datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
  taxa <- get_taxa(datasetKey)
  expect_invisible(check_taxa(taxa))
})

test_that("check_taxa() returns error on invalid taxa class", {
  expect_error(
    check_taxa("not a dataframe"),
    class = "elodea_error_taxa_invalid_class"
  )
  expect_error(
    check_taxa(list("a", "c")),
    class = "elodea_error_taxa_invalid_class"
  )
})

test_that("check_taxa() returns error on missing columns", {
  skip_if_offline()
  datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
  taxa <- get_taxa(datasetKey) |>
    dplyr::rename(
      key = "taxonKey",
      rank = "taxonRank"
      )
  expect_error(
    check_taxa(taxa),
    class = "elodea_error_taxa_missing_columns"
  )
})
