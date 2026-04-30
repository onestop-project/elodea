test_that("check_names() returns an error on column missing", {
  checklist <-
    example_checklist |>
    dplyr::rename("scientific.name" = scientific_name)

  expect_error(
    suppressMessages(check_names(checklist)),
    class = "elodea_error_scienfic_name_missing"
  )
})

test_that("check_names() returns the expected columns in the summary and match tables", {
  result <- suppressMessages(check_names(example_checklist))

  col_names <- c(
    names(example_checklist),
    "bb_scientificName",
    "bb_matchType",
    "bb_confidence",
    "bb_rank",
    "bb_status",
    "bb_acceptedUsageKey",
    "bb_acceptedScientificName"
  )

  expect_identical(colnames(result), col_names)
})

test_that("check_names() prints the expected summary via cli", {
  testthat::expect_snapshot({
    result <- check_names(example_checklist)
  })
})

test_that("check_names() returns the expected output", {
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))

  result <- suppressMessages(check_names(example_checklist))
  write.csv(
    result,
    file.path(temp_dir, "check_names.csv"),
    row.names = FALSE
  )

  expect_snapshot_file(
    file.path(temp_dir, "check_names.csv")
  )
})

test_that("check_names() overwrites the 'bb_' columns if present", {
  checklist <- example_checklist |>
    dplyr::mutate(
      bb_scientificName = "test",
      bb_matchType = "test",
      bb_confidence = 0,
      bb_rank = "test",
      bb_status = "test",
      bb_acceptedUsageKey = 0,
      bb_acceptedScientificName = "test"
    )
  result_modified <- suppressMessages(check_names(checklist))
  result_original <- suppressMessages(check_names(example_checklist))

  expect_equal(result_modified, result_original)
  })
