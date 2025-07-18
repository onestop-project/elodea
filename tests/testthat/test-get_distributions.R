test_that("get_distributions() returns correct distributions data frame", {
  skip_if_offline()
  distr_andorra <- get_distributions("016c16c3-d907-4c88-97dd-97ad62c8130e")
  distr_belgium <- get_distributions("6d9e952f-948c-4483-9807-575348147c7e")

  # The returned output is of type list
  expect_type(distr_andorra, "list")
  expect_type(distr_belgium, "list")
  # The returned output is a tibble data.frame
  expect_equal(class(distr_andorra), c("tbl_df", "tbl", "data.frame"))
  expect_equal(class(distr_belgium), c("tbl_df", "tbl", "data.frame"))
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
  expect_equal(expected_columns, names(distr_belgium))
})
