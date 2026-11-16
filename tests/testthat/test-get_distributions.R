test_that("get_distributions() returns correct distributions data frame", {
  skip_if_offline()
  vcr::local_cassette("distributions-ants")

  distributions <- get_distributions(287027)

  # The returned output is of type list
  expect_type(distributions, "list")
  # The returned output is a tibble data.frame
  expect_equal(class(distributions), c("tbl_df", "tbl", "data.frame"))
  # Check that the output has the expected columns
  expected_columns <- c(
    "taxonID",
    "countryCode",
    "establishmentMeans",
    "degreeOfEstablishment",
    "pathway",
    "eventDate",
    "source"
  )
  expect_equal(expected_columns, names(distributions))

  # Write output for snapshot
  directory <- withr::local_tempdir(pattern = "ants")
  path <- file.path(directory, "distributions.csv")
  readr::write_csv(distributions, path, na = "")

  expect_snapshot_file(path)
})

test_that("get_distributions() returns message when distributions are missing", {
  skip_if_offline()
  vcr::local_cassette("distributions_union")

  # Species of Union concern
  datasetKey <- 58406
  expect_message(
    get_distributions(datasetKey),
    paste("No distributions found for dataset", datasetKey)
  )
})
