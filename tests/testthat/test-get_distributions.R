test_that("get_distributions() returns correct distributions data frame", {
  skip_if_offline()
  vcr::local_cassette("distributions_andorra")

  distr_andorra <- get_distributions("016c16c3-d907-4c88-97dd-97ad62c8130e")

  # The returned output is of type list
  expect_type(distr_andorra, "list")
  # The returned output is a tibble data.frame
  expect_equal(class(distr_andorra), c("tbl_df", "tbl", "data.frame"))
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
  expect_equal(expected_columns, names(distr_andorra))

  # Write output for snapshot
  directory <- withr::local_tempdir(pattern = "andorra")
  path <- file.path(directory, "distributions.csv")
  readr::write_csv(distr_andorra, path, na = "")

  expect_snapshot_file(path)
})
