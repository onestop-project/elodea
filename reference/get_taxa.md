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

- `nubKey`: GBIF backbone taxon key

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
  Scientific name of the accepted taxon. `scientificName` is the
  accepted name in the GBIF backbone.

- [`acceptedKingdom`](http://rs.tdwg.org/dwc/terms/kingdom): Kingdom of
  the accepted taxon.

- [`acceptedTaxonRank`](http://rs.tdwg.org/dwc/terms/taxonRank):
  Taxonomic rank of the accepted taxon.

## See also

Other download functions:
[`get_distributions()`](https://onestop-project.github.io/elodea/reference/get_distributions.md)

## Examples

``` r
# Global Register of Introduced and Invasive Species - Sovereign Base Areas
# of Cyprus, Cyprus
get_taxa("497fa25f-6a32-4a2a-8f42-d01d8a0b7c22")
#> # A tibble: 20 × 9
#>     taxonKey  nubKey taxonID scientificName          taxonomicStatus acceptedKey
#>        <int>   <int> <chr>   <chr>                   <chr>                 <int>
#>  1 163732873 2264597 120115  Rhopilema nomadica Gal… ACCEPTED            2264597
#>  2 163732878 2334433 120114  Pterois miles (Bennett… ACCEPTED            2334433
#>  3 163732881 2407271 120112  Torquigener flavimacul… ACCEPTED            2407271
#>  4 163732882 2407271 120117  Torquigener flavimacul… ACCEPTED            2407271
#>  5 163732885 2356802 120108  Sargocentron rubrum (F… ACCEPTED            2356802
#>  6 163732886 2356802 120116  Sargocentron rubrum (F… ACCEPTED            2356802
#>  7 163732889 2350570 120106  Gambusia holbrooki Gir… ACCEPTED            2350570
#>  8 163732892 2390262 120109  Siganus luridus (RÃ¼pp… ACCEPTED            2390262
#>  9 163732893 2390185 120110  Siganus rivulatus Fors… ACCEPTED            2390185
#> 10 163732895 2396749 120107  Parupeneus forsskali (… ACCEPTED            2396749
#> 11 163732898      NA 120113  Fistularia commersonii… NA                       NA
#> 12 163732899      NA 120105  Fistularia commersonii… NA                       NA
#> 13 163732903 2441502 120119  Testudo marginata Scho… ACCEPTED            2441502
#> 14 163732904 2441461 120118  Testudo graeca Linnaeu… ACCEPTED            2441461
#> 15 163732911 3151764 120111  Symphyotrichum squamat… ACCEPTED            3151764
#> 16 163732914 3176197 120103  Eucalyptus camaldulens… DOUBTFUL            3176197
#> 17 163732915 3176772 120104  Eucalyptus gomphocepha… ACCEPTED            3176772
#> 18 163732918 5421144 120102  Dodonaea viscosa Jacq.  ACCEPTED            5421144
#> 19 163732921 2891932 120101  Casuarina cunninghamia… ACCEPTED            2891932
#> 20 163732924 2978552 120100  Acacia saligna (Labill… ACCEPTED            2978552
#> # ℹ 3 more variables: acceptedName <chr>, acceptedTaxonRank <chr>,
#> #   acceptedKingdom <chr>
```
