test_that("filter_data() returns the expected files", {
  skip_if_offline()
  datasetKey_andorra <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
  taxa <- get_taxa(datasetKey_andorra)
  distributions <- get_distributions(datasetKey_andorra)
  result <- filter_data(
    taxa, distributions, establishmentMeans = c("introduced")
    )

  # The returned output is of type list
  expect_type(result, "list")
  # The returned output is a list with 3 data frames
  expect_length(result, 3)
  expect_equal(class(result$taxa), c("tbl_df", "tbl", "data.frame"))
  expect_equal(class(result$distribution), c("tbl_df", "tbl", "data.frame"))
  expect_equal(class(result$notes), c("tbl_df", "tbl", "data.frame"))
  # Check that taxa has the expected columns
  taxa_expected_columns <- c(
    "taxonKey",
    "nubKey",
    "taxonID",
    "scientificName",
    "acceptedKey",
    "accepted",
    "kingdom",
    "taxonRank"
  )
  expect_equal(taxa_expected_columns, names(taxa))
  # Check that distributions has the expected columns
  distributions_expected_columns <- c(
    "taxonKey",
    "countryCode",
    "occurrenceStatus",
    "establishmentMeans",
    "degreeOfEstablishment",
    "pathway",
    "eventDate",
    "source"
  )
  expect_equal(distributions_expected_columns, names(distributions))
  # Check that notes has the expected columns
  notes_expected_columns <- c(
    "taxonID",
    "taxonKey",
    "scientificName",
    "action",
    "acceptedKey",
    "accepted"
  )
  expect_equal(notes_expected_columns, names(result$notes))
})
