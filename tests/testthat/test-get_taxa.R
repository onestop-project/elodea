test_that("get_taxa() returns correct taxa data frame", {
  skip_if_offline()
  vcr::local_cassette("taxa_andorra")

  taxa_andorra <- get_taxa(29121)

  # The returned output is of type list
  expect_type(taxa_andorra, "list")
  # The returned output is a tibble data.frame
  expect_equal(class(taxa_andorra), c("tbl_df", "tbl", "data.frame"))
  # Check that the output has the expected columns
  expected_columns <- c(
    "usage_id",
    "taxonID",
    "scientificName",
    "taxonomicStatus",
    "acceptedKey",
    "acceptedName",
    "acceptedTaxonRank"

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

  datasetKey <- 29121
  taxa_raw <- rcol::clb_usage_search(dataset = datasetKey, limit = Inf)$data
  taxa <- get_taxa(datasetKey)

  expect_true("denormed classification" %in% taxa_raw$origin)
  expect_false(any(c("kingdom", "phylum") %in% taxa$acceptedTaxonRank))
})
