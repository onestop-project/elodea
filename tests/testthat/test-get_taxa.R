test_that("get_taxa() warns on invalid datasetKey", {
  skip_if_offline()
  expect_error(
    get_taxa("016c16c3-d907-4c88-97dd-97ad62c8130"),
    class = "elodea_error_invalid_datasetkey"
  )
})

test_that("get_taxa() returns correct taxa data frame", {
  skip_if_offline()
  vcr::local_cassette("taxa_andorra")

  taxa_andorra <- get_taxa("016c16c3-d907-4c88-97dd-97ad62c8130e")

  # The returned output is of type list
  expect_type(taxa_andorra, "list")
  # The returned output is a tibble data.frame
  expect_equal(class(taxa_andorra), c("tbl_df", "tbl", "data.frame"))
  # Check that the output has the expected columns
  expected_columns <- c(
    "taxonKey",
    "taxonID",
    "scientificName",
    "taxonomicStatus",
    "acceptedKey",
    "acceptedName",
    "acceptedTaxonRank",
    "acceptedKingdom"

  )
  expect_equal(expected_columns, names(taxa_andorra))

  # Write output for snapshot
  directory <- withr::local_tempdir(pattern = "andorra")
  path <- file.path(directory, "taxa.csv")
  readr::write_csv(taxa_andorra, path, na = "")

  expect_snapshot_file(path)
})

test_that("get_taxa() filters on origin", {
  skip_if_offline()
  vcr::local_cassette("name_usage_andorra")

  datasetKey <- "e082b10e-476f-43c1-aa61-f8d92f33029a" # Belgium
  taxa_raw <- rgbif::name_usage(datasetKey = datasetKey, limit = 99999)$data
  taxa <- get_taxa(datasetKey)

  expect_true("DENORMED_CLASSIFICATION" %in% taxa_raw$origin)
  expect_false(any(c("kingdom", "phylum") %in% taxa$acceptedTaxonRank))
  expect_true(identical(unique(taxa$acceptedTaxonRank), "SPECIES"))
})
