# Get taxa from checklist

Gets taxonomic information of a GBIF checklist and matching GBIF
backbone taxonomy. Only source taxa are kept, denormed higher
classification taxa are removed. The function
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

`get_taxa()` returns a `tibble` with 8 columns:

- `taxonKey`: GBIF taxon key of `scientificName`.

- [`taxonID`](http://rs.tdwg.org/dwc/terms/taxonID): Taxon ID of
  `scientificName`, as provided in the checklist.

- [`scientificName`](http://rs.tdwg.org/dwc/terms/scientificName):
  Original scientific name of the taxon in the checklist.

- `taxonomicStatus`: Taxonomic status of the taxon in the GBIF backbone
  taxonomy. It can be `accepted`, `synonym`, `doubtful` or `NA` if the
  taxon is not matched with the backbone.

- [`acceptedKey`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsageID):
  GBIF taxon key of the accepted taxon, if the source `scientificName`
  is a synonym.

- [`acceptedName`](https://dwc.tdwg.org/list/#dwc_acceptedNameUsage):
  Scientific name of the accepted taxon.

- [`acceptedKingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of
  the accepted taxon.

- [`acceptedTaxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank):
  Taxonomic rank of the accepted taxon.

## Examples

``` r
# Global Register of Introduced and Invasive Species - Cyprus
get_taxa("2f7ea7d1-a73f-46f6-b790-7339126a999f")
#> # A tibble: 632 × 8
#>     taxonKey taxonID scientificName     taxonomicStatus acceptedKey acceptedName
#>        <int> <chr>   <chr>              <chr>                 <int> <chr>       
#>  1 148692903 20667   Eriophyes pyri (H… ACCEPTED            5774728 Eriophyes p…
#>  2 148692906 21008   Stypopodium schim… ACCEPTED            3200580 Stypopodium…
#>  3 148692918 20939   Rhizosolenia calc… ACCEPTED            5421948 Rhizosoleni…
#>  4 148692921 20917   Pseudosolenia cal… ACCEPTED            3194102 Pseudosolen…
#>  5 148692922 21062   Xiphinema brevico… ACCEPTED            4554475 Xiphinema b…
#>  6 148692923 21063   Xiphinema index T… ACCEPTED            4554493 Xiphinema i…
#>  7 148692924 21064   Xiphinema italiae… ACCEPTED            4554459 Xiphinema i…
#>  8 148692930 20794   Meloidogyne arena… ACCEPTED            4556299 Meloidogyne…
#>  9 148692935 20795   Meloidogyne hapla… ACCEPTED            2283982 Meloidogyne…
#> 10 148692936 20881   Phytophthora citr… ACCEPTED            3203668 Phytophthor…
#> # ℹ 622 more rows
#> # ℹ 2 more variables: acceptedTaxonRank <chr>, acceptedKingdom <chr>
```
