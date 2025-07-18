test_that("get_taxa() returns correct taxa data frame", {
  skip_if_offline()
  taxa_andorra <- get_taxa("016c16c3-d907-4c88-97dd-97ad62c8130e")
  taxa_belgium <- get_taxa("6d9e952f-948c-4483-9807-575348147c7e")

  # The returned output is of type list
  expect_type(taxa_andorra, "list")
  expect_type(taxa_belgium, "list")
  # The returned output is a tibble data.frame
  expect_equal(class(taxa_andorra), c("tbl_df", "tbl", "data.frame"))
  expect_equal(class(taxa_belgium), c("tbl_df", "tbl", "data.frame"))
  # Check that the output has the expected columns
  expected_columns <- c(
    "taxonKey",
    "nubKey",
    "taxonID",
    "scientificName",
    "acceptedKey",
    "accepted",
    "kingdom",
    "taxonRank"
  )
  expect_equal(expected_columns, names(taxa_andorra))
  expect_equal(expected_columns, names(taxa_belgium))
})
