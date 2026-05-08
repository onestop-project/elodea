# Filter data

Filters taxa and distributions data frames, and returns the filtered
data and notes.

## Usage

``` r
filter_data(taxa, distributions, establishment_means = NULL)
```

## Arguments

- taxa:

  Data frame as returned by
  [`get_taxa()`](https://onestop-project.github.io/elodea/reference/get_taxa.md).

- distributions:

  Data frame as returned by
  [`get_distributions()`](https://onestop-project.github.io/elodea/reference/get_distributions.md).

- establishment_means:

  EstablishmentMeans to filter on. Only taxa with matching distributions
  with `establishmentMeans` in this vector will be retained. Default is
  "introduced".

## Value

A list with three data frames:

- `taxa`: Filtered taxa data frame, with different columns than the
  input `taxa` data frame.

- `distributions`: Filtered distributions data frame.

- `notes`: Data frame with notes on taxa that were not included or
  replaced in the filtered data.

## Filter on `establishmentMeans`

Defaults to `NULL`, which means no filter on establishmentMeans.
Possible values are "native", "introduced", "nativeReintroduced",
"introducedAssistedColonisation", "vagrant", "uncertain" and
"nativeEndemic".

## Filter details

Taxa are removed if

- they are not matched with the GBIF backbone (i.e., `nubKey` is `NA`),

- they do not have a matching distribution (i.e., `taxonKey` is not in
  `distributions$taxonKey`),

- they do not have a matching distribution with `establishmentMeans` in
  `establishment_means`.

Synonyms are replaced by the accepted taxa they are synonyms of (i.e.,
`taxonomicStatus` is either "synonym", "ambiguous synonym", "heterotypic
synonym", "homotypic synonym", "misapplied" or "proparte synonym).

`scientificName` is replaced with the scientific name matching the GBIF
backbone.

## Taxa details

The `taxa` data frame in the output list has 6 variables:

- `taxonKey`: GBIF taxon key of `scientificName`. This value is replaced
  with `acceptedKey` if the taxon is a synonym of an accepted taxon.

- `nubKey`: GBIF backbone taxon key.

- [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID of
  `scientificName`, as provided in the checklist.

- [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName):
  Scientific name of the taxon. This value is replaced with
  `acceptedName` for all records.

- [`kingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of the
  taxon.

- [`taxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank): Taxonomic rank
  of the taxon.

## Examples

``` r
if (FALSE) { # \dontrun{
# Updated checklist of the ants in Belgium
datasetKey <- "32afaa9d-a27f-4885-b30c-ce08c34e1efb"
taxa <- get_taxa(datasetKey)
distributions <- get_distributions(datasetKey, taxa)
filter_data(taxa, distributions, establishment_means = "introduced" )
} # }
```
