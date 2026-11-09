test_that("filter_data() returns error on invalid `establishmentMeans`", {
  skip_if_offline()
  vcr::local_cassette("filter_fishes")

  datasetKey_fishes <- 30842
  taxa <- get_taxa(datasetKey_fishes)
  distributions <- get_distributions(datasetKey_fishes, taxa)

  expect_error(
    filter_data(
      taxa, distributions, establishment_means = "native introduced"
      ),
     class = "elodea_error_invalid_establishmentMeans"
  )

  expect_error(
    filter_data(
      taxa, distributions, c("introduced", "native introduced")
    ),
    class = "elodea_error_invalid_establishmentMeans"
  )

  expect_error(
    filter_data(
      taxa, distributions, establishment_means = NA_character_
    ),
    class = "elodea_error_invalid_establishmentMeans"
  )
})

test_that("filter_data() filters on establishmentMeans", {
  skip_if_offline()
  vcr::local_cassette("filter_fishes")

  datasetKey_fishes <- 30842
  taxa <- get_taxa(datasetKey_fishes)
  distributions <- get_distributions(datasetKey_fishes, taxa)

  expect_no_error(filter_data(taxa, distributions))
  expect_no_error(
    filter_data(
      taxa, distributions, establishment_means = c("introduced", "native")
      )
  )
  expect_no_error(
    filter_data(taxa, distributions, establishment_means = "native")
  )
})

test_that("filter_data() returns the expected files for an existing checklist", {
  skip_if_offline()
  vcr::local_cassette("filter_fishes")

  datasetKey_fishes <- 30842
  taxa <- get_taxa(datasetKey_fishes)
  distributions <- get_distributions(datasetKey_fishes, taxa)
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
    "taxonID",
    "taxonKey",
    "scientificName",
    "taxonRank"
  )
  expect_equal(names(output$taxa), taxa_expected_columns)

  # Check that distributions has the expected columns
  distributions_expected_columns <- c(
    "taxonID",
    "taxonKey",
    "countryCode",
    "establishmentMeans",
    "degreeOfEstablishment",
    "pathway",
    "eventDate",
    "source"
  )
  expect_equal(names(output$distributions), distributions_expected_columns)

  # Check that notes has the expected columns
  notes_expected_columns <- c(
    "taxonID",
    "usage_id",
    "scientificName",
    "action",
    "acceptedKey",
    "acceptedName"
  )
  expect_equal(names(output$notes), notes_expected_columns)

  # Write output for snapshot
  directory <- withr::local_tempdir(pattern = "fishes")
  taxa_path <- file.path(directory, "taxa.csv")
  distributions_path <- file.path(directory, "distributions.csv")
  notes_path <- file.path(directory, "notes.csv")
  readr::write_csv(output$taxa, taxa_path, na = "")
  readr::write_csv(output$distributions, distributions_path, na = "")
  readr::write_csv(output$notes, notes_path, na = "")

  # Test snapshots
  expect_snapshot_file(taxa_path)
  expect_snapshot_file(distributions_path)
  expect_snapshot_file(notes_path)
})

test_that("filter_data() filters on establishmentMeans", {
  skip_if_offline()
  vcr::local_cassette("filter_ants")

  datasetKey <- 287027
  taxa <- get_taxa(datasetKey)
  distributions <- get_distributions(datasetKey, taxa)
  output_native <- filter_data(
    taxa, distributions, establishment_means = c("native")
  )
  output_introduced <- filter_data(
    taxa, distributions, establishment_means = c("introduced")
  )
  output_native_and_introduced <- filter_data(
    taxa, distributions, establishment_means = c("native", "introduced")
  )
  output_null <- filter_data(
    taxa, distributions, establishment_means = NULL
  )

  expect_equal(unique(output_native$distributions$establishmentMeans), "native")
  expect_equal(
    unique(output_introduced$distributions$establishmentMeans),
    "introduced"
    )
  expect_equal(
    unique(output_native_and_introduced$distributions$establishmentMeans),
    c("native", "introduced")
    )
  expect_equal(
    unique(output_null$distributions$establishmentMeans),
    c("native", "introduced")
  )
})
