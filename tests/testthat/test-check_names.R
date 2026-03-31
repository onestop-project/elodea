test_that("check_names() returns an error on column missing", {
  checklist <-
    example_checklist |>
    dplyr::rename("scientific.name" = scientific_name)

  expect_error(
    suppressMessages(check_names(checklist)),
    class = "elodea_error_scienfic_name_missing"
  )
})

test_that("check_names() returns a list of data frames", {
  result <- suppressMessages(check_names(example_checklist))

  expect_identical(names(result), c("summary", "full_table"))
  expect_s3_class(result$summary, "tbl")
  expect_s3_class(result$full_table, "tbl")
})

test_that("check_names() returns the expected columns in the summary and match tables", {
  result <- suppressMessages(check_names(example_checklist))

  col_names <- c(
    "rawScientificName",
    "scientificName",
    "matchType",
    "confidence",
    "rank",
    "status",
    "acceptedUsageKey",
    "acceptedScientificName"
  )

  expect_identical(colnames(result$summary), col_names)
  expect_identical(colnames(result$full_table), col_names)
})

test_that("check_names() prints the expected summary via cli", {
  testthat::expect_snapshot({
    result <- check_names(example_checklist)
  })
})

test_that("check_names() returns the expected summary and full_table", {
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))

  result <- suppressMessages(check_names(example_checklist))

  write.csv(
    result$summary,
    file.path(temp_dir, "check_names-summary.csv"),
    row.names = FALSE
    )

  write.csv(
    result$full_table,
    file.path(temp_dir, "check_names-full_table.csv"),
    row.names = FALSE
  )

  expect_snapshot_file(
    file.path(temp_dir, "check_names-summary.csv")
  )
  expect_snapshot_file(
    file.path(temp_dir, "check_names-full_table.csv")
  )
})
