# Get taxa from checklist

Gets taxonomic information of a GBIF dataset. Only source taxa are kept,
denormed higher classification taxa are removed. The function
[`rgbif::name_usage()`](https://docs.ropensci.org/rgbif/reference/name_usage.html)
is used under the hood.

## Usage

``` r
get_taxa(datasetKey)
```

## Arguments

- datasetKey:

  GBIF dataset key.

## Value

A `tibble` with taxonomic information of the dataset.

## Taxa details

`get_taxa()` returns a `tibble` with 8 variables:

- `taxonKey`: GBIF taxon key within the checklist

- `nubKey`: GBIF backbone taxon key

- [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID from the
  dataset

- [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName):
  Scientific name of the taxon within the checklist

- [`acceptedKey`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsageID):
  GBIF taxon key of the accepted taxon within the checklist, if
  applicable

- [`accepted`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsage):
  Scientific name of the accepted taxon within the checklist, if
  applicable

- [`kingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of the
  taxon

- [`taxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank): Taxonomic rank
  of the taxon

## Examples

``` r
# Cyprus
taxa_CY <- get_taxa("2f7ea7d1-a73f-46f6-b790-7339126a999f")
# Andorra
taxa_AD <- get_taxa("016c16c3-d907-4c88-97dd-97ad62c8130e")
if (FALSE) { # \dontrun{
# Belgium
taxa_BE <- get_taxa("6d9e952f-948c-4483-9807-575348147c7e")
} # }
```
