test_that("filter_data() returns the expected files for an existing dataset", {
  skip_if_offline()
  vcr::local_cassette("filter_finland")

  datasetKey_finland <- "b79c5ba3-d447-4a73-bcbf-557f3241eeb2"
  taxa <- get_taxa(datasetKey_finland)
  distributions <- get_distributions(datasetKey_finland, taxa)
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
    "taxonID",
    "scientificName",
    "kingdom",
    "taxonRank"
  )
  expect_equal(names(output$taxa), taxa_expected_columns)

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
  expect_equal(names(output$distributions), distributions_expected_columns)

  # Check that notes has the expected columns
  notes_expected_columns <- c(
    "taxonID",
    "taxonKey",
    "scientificName",
    "action",
    "acceptedKey",
    "acceptedName"
  )
  expect_equal(names(output$notes), notes_expected_columns)
})

test_that("filter_data() returns the expected output for a dummy dataset", {
  taxa <-
    # 1. All good, nubkey = 1047536
    data.frame(
      taxonKey = 148674360,
      taxonID = "all_good",
      scientificName = "Leptinotarsa decemlineata (Say, 1824)",
      taxonomicStatus = "ACCEPTED",
      acceptedKey = 1047536,
      acceptedName = "Leptinotarsa decemlineata (Say, 1824)",
      acceptedKingdom = "Animalia",
      acceptedTaxonRank= "species"
    ) |>
    # 2. `scientificName` need to be replaced with correct backbone name
    # nubkey = 8411684
    dplyr::add_row(
      taxonKey = 148674355,
      taxonID = "scientificname_different_from_backbone",
      scientificName = "Monochamus sutor (LinnÃ©, 1758)",
      taxonomicStatus = "ACCEPTED",
      acceptedKey = 8411684,
      acceptedName = "Monochamus sutor (Linnaeus, 1758)",
      acceptedKingdom = "Animalia",
      acceptedTaxonRank= "species"
    ) |>
    # 3. `key`s and `scientificName` need to be replaced with accepted values
    # nubkey = 3204008
    dplyr::add_row(
      taxonKey = 148674371,
      taxonID = "synonym",
      scientificName = "Pseudoperonospora humuli (Miyabe & Takah.) G.W.Wilson",
      taxonomicStatus = "SYNONYM",
      acceptedKey = 3204007,
      acceptedName = "Pseudoperonospora cubensis (Berk. & M.A.Curtis) Rostovzev",
      acceptedKingdom = "Chromista",
      acceptedTaxonRank= "species"
    ) |>
    # 4. Record needs to be removed because `nubKey` is missing
    # nubkey = NA
    dplyr::add_row(
      taxonKey = 148746536,
      taxonID = "nubkey_missing",
      scientificName = "Pinus strobus",
      taxonomicStatus = NA_character_,
      acceptedKey = NA_real_,
      acceptedName = NA_character_,
      acceptedKingdom = "Plantae",
      acceptedTaxonRank= "species"
    ) |>
    # 5. Record needs to be removed because there is no matching distribution,
    # nubkey = 5265718
    dplyr::add_row(
      taxonKey = 148746476,
      taxonID = "establishmentMeans_not_introduced",
      scientificName = "Synchytrium endobioticum (Schilb.) Percival",
      taxonomicStatus = "ACCEPTED",
      acceptedKey = 5265718,
      acceptedName = "Synchytrium endobioticum (Schilb.) Percival",
      acceptedKingdom = "Fungi",
      acceptedTaxonRank= "species"
    ) |>
    # 6. Record needs to be removed because there is no matching distribution
    # nubkey = 2284723
    dplyr::add_row(
      taxonKey = 148746414,
      taxonID = "distribution_missing",
      scientificName = "Urnatella gracilis Leidy, 1851",
      taxonomicStatus = "ACCEPTED",
      acceptedKey = 2284723,
      acceptedName = "Urnatella gracilis Leidy, 1851",
      acceptedKingdom = "Animalia",
      acceptedTaxonRank= "species"
    )

  distributions <-
    # 1. All good
    data.frame(
      taxonKey = 148674360,
      countryCode = "AD",
      occurrenceStatus = "present",
      establishmentMeans = "introduced",
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    ) |>
    # 2. All good
    dplyr::add_row(
      taxonKey = 148674355,
      countryCode = "AD",
      occurrenceStatus = "present",
      establishmentMeans = "introduced",
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    ) |>
    # 3. `taxonKey` need to be replaced by `acceptedKey`
    dplyr::add_row(
      taxonKey = 148674371,
      countryCode = "AD",
      occurrenceStatus = "present",
      establishmentMeans = "introduced",
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    ) |>
    # 4. Record needs to be removed because `nubKey` is missing
    dplyr::add_row(
      taxonKey = 148746536,
      countryCode = "AT",
      occurrenceStatus = "present",
      establishmentMeans = "introduced",
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    ) |>
    # 5. Record needs to be removed because `establishmentMeans` is not
    # `introduced`
    dplyr::add_row(
      taxonKey = 148746476,
      countryCode = "AT",
      occurrenceStatus = "present",
      establishmentMeans = NA_character_,
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    )

  expected_taxa <-
    # 1. All good
    data.frame(
      taxonKey = 148674360,
      taxonID = "all_good",
      scientificName = "Leptinotarsa decemlineata (Say, 1824)",
      kingdom = "Animalia",
      taxonRank = "species"
    ) |>
    # 2. `scientificName` is replaced with correct backbone name
    dplyr::add_row(
      taxonKey = 148674355,
      taxonID = "scientificname_different_from_backbone",
      scientificName = "Monochamus sutor (Linnaeus, 1758)",
      kingdom = "Animalia",
      taxonRank = "species"
    ) |>
    # 3. `key`s and `scientificName` are replaced with accepted values
    dplyr::add_row(
      taxonKey = 3204007,
      taxonID = "synonym",
      scientificName =
        "Pseudoperonospora cubensis (Berk. & M.A.Curtis) Rostovzev",
      kingdom = "Chromista",
      taxonRank = "species"
    ) |>
    dplyr::as_tibble()

  expected_distributions <-
    # 1. All good
    data.frame(
      taxonKey = 148674360,
      countryCode = "AD",
      occurrenceStatus = "present",
      establishmentMeans = "introduced",
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    ) |>
    # 2. All good
    dplyr::add_row(
      taxonKey = 148674355,
      countryCode = "AD",
      occurrenceStatus = "present",
      establishmentMeans = "introduced",
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    ) |>
    # 3. `taxonKey` is replaced by `acceptedKey`
    dplyr::add_row(
      taxonKey = 3204007,
      countryCode = "AD",
      occurrenceStatus = "present",
      establishmentMeans = "introduced",
      degreeOfEstablishment = NA_character_,
      pathway = NA_character_,
      eventDate = NA_character_,
      source = NA_character_
    ) |>
    dplyr::as_tibble()

  expected_notes <-
    data.frame(
      taxonID = "scientificname_different_from_backbone",
      taxonKey = 148674355,
      scientificName = "Monochamus sutor (LinnÃ©, 1758)",
      action = "scientificName_replaced_by_backbone_name",
      acceptedKey = 8411684,
      acceptedName = "Monochamus sutor (Linnaeus, 1758)"
    ) |>
    dplyr::add_row(
      taxonID = "synonym",
      taxonKey = 148674371,
      scientificName = "Pseudoperonospora humuli (Miyabe & Takah.) G.W.Wilson",
      action = "merged_with_accepted",
      acceptedKey = 3204007,
      acceptedName = "Pseudoperonospora cubensis (Berk. & M.A.Curtis) Rostovzev"
    ) |>
    dplyr::add_row(
      taxonID = "nubkey_missing",
      taxonKey = 148746536,
      scientificName = "Pinus strobus",
      action = "not_matched_with_backbone",
      acceptedKey = NA_real_,
      acceptedName = NA_character_
    ) |>
    dplyr::add_row(
      taxonID = "establishmentMeans_not_introduced",
      taxonKey = 148746476,
      scientificName = "Synchytrium endobioticum (Schilb.) Percival",
      action = "establishmentMeans_missing",
      acceptedKey = 5265718,
      acceptedName = "Synchytrium endobioticum (Schilb.) Percival"
    ) |>
    dplyr::add_row(
      taxonID = "distribution_missing",
      taxonKey = 148746414,
      scientificName = "Urnatella gracilis Leidy, 1851",
      action = "no_matching_distribution",
      acceptedKey = 2284723,
      acceptedName = "Urnatella gracilis Leidy, 1851"
    ) |>
    dplyr::as_tibble()

  output <- filter_data(taxa, distributions)
  expect_equal(output$taxa, expected_taxa)
  expect_equal(output$distributions, expected_distributions)
  expect_equal(output$notes, expected_notes)
})
