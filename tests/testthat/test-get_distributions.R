test_that("get_distributions() returns correct distributions data frame", {
  skip_if_offline()
  vcr::local_cassette("distributions_fishes")

  distributions <- get_distributions("98940a79-2bf1-46e6-afd6-ba2e85a26f9f")

  # The returned output is of type list
  expect_type(distributions, "list")
  # The returned output is a tibble data.frame
  expect_equal(class(distributions), c("tbl_df", "tbl", "data.frame"))
  # Check that the output has the expected columns
  expected_columns <- c(
    "taxonKey",
    "countryCode",
    "occurrenceStatus",
    "establishmentMeans",
    "degreeOfEstablishment",
    "pathway",
    "eventDate",
    "source"
  )
  expect_equal(expected_columns, names(distributions))

  # Write output for snapshot
  directory <- withr::local_tempdir(pattern = "andorra")
  path <- file.path(directory, "distributions.csv")
  readr::write_csv(distributions, path, na = "")

  expect_snapshot_file(path)
})

test_that("get_distributions() returns message when distributions are missing", {
  skip_if_offline()
  vcr::local_cassette("distributions_union")

  # Species of Union concern
  datasetKey <- "79d65658-526c-4c78-9d24-1870d67f8439"
  expect_message(
    get_distributions(datasetKey),
    paste("No distributions found for dataset", datasetKey)
  )
})
