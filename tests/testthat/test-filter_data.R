test_that("filter_data() returns the expected files for an existing dataset", {
  skip_if_offline()
  datasetKey_andorra <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
  taxa <- get_taxa(datasetKey_andorra)
  distributions <- get_distributions(datasetKey_andorra, taxa)
  output <- filter_data(taxa, distributions)

  # The returned output is of type list
  expect_type(output, "list")

  # The returned output is a list with 3 data frames
  expect_length(output, 3)
  expect_equal(class(output$taxa), c("tbl_df", "tbl", "data.frame"))
  expect_equal(class(output$distribution), c("tbl_df", "tbl", "data.frame"))
  expect_equal(class(output$notes), c("tbl_df", "tbl", "data.frame"))

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
  expect_equal(names(taxa), taxa_expected_columns)

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
  expect_equal(names(distributions), distributions_expected_columns)

  # Check that notes has the expected columns
  notes_expected_columns <- c(
    "taxonID",
    "taxonKey",
    "scientificName",
    "action",
    "acceptedKey",
    "accepted"
  )
  expect_equal(names(output$notes), notes_expected_columns)
})
