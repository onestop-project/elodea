test_that("get_taxa() returns correct taxa data frame", {
  skip_if_offline()
  datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
  taxa <- get_taxa(datasetKey)

  # The returned output is of type list
  expect_type(taxa, "list")
  # The returned output is a tibble data.frame
  expect_equal(
    class(taxa),
    c("tbl_df", "tbl", "data.frame")
  )
  # Check that the output has the expected columns
  expect_equal(
    c(
      "taxonKey",
      "taxonID",
      "scientificName",
      "acceptedKey",
      "accepted",
      "kingdom",
      "taxonRank"
    ),
    names(taxa)
  )
})
