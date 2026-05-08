# Get distributions

Gets the distributions of a GBIF dataset. The function
[`rgbif::name_usage()`](https://docs.ropensci.org/rgbif/reference/name_usage.html)
is used under the hood.

## Usage

``` r
get_distributions(datasetKey, taxa = get_taxa(datasetKey))
```

## Arguments

- datasetKey:

  GBIF dataset key.

- taxa:

  Data frame as returned by
  [`get_taxa()`](https://onestop-project.github.io/elodea/reference/get_taxa.md).
  Defaults to `get_taxa(datasetKey)`

## Value

A `tibble` with distributions.

## Distributions details

`get_distributions()` returns a `tibble` with 8 variables:

- `taxonKey`: GBIF taxon key

- [`countryCode`](http://rs.tdwg.org/dwc/terms/countryCode): ISO
  3166-1-alpha-2 country code

- [`occurrenceStatus`](http://rs.tdwg.org/dwc/terms/occurrenceStatus): A
  statement about the presence or absence of a taxon at a country. When
  `occurrenceStatus` is missing, it is set to `present`.

- [`establishmentMeans`](http://rs.tdwg.org/dwc/terms/establishmentMeans):
  Statement about whether the taxon has been introduced to a given
  country and eventDate through the direct or indirect activity of
  modern humans.

- [`degreeOfEstablishment`](http://rs.tdwg.org/dwc/terms/degreeOfEstablishment):
  The degree to which a taxon survives, reproduces, and expands its
  range at the given country and eventDate.

- [`pathway`](http://rs.tdwg.org/dwc/terms/pathway): The process by
  which a taxon came to be in a given country at a given eventDate.

- [`eventDate`](http://rs.tdwg.org/dwc/terms/eventDate): The date-time
  or interval during which the `occurrenceStatus` is applicable for the
  taxon in a given country.

- [`source`](http://purl.org/dc/terms/source): A related resource from
  which the described resource is derived.

## See also

Other download functions:
[`get_taxa()`](https://onestop-project.github.io/elodea/reference/get_taxa.md)

## Examples

``` r
# Checklist of non-native freshwater fishes in Flanders, Belgium
get_distributions("98940a79-2bf1-46e6-afd6-ba2e85a26f9f")
#> verbatim ■■■■■■■■■■■■■■■■■■■■              62% |  ETA:  2s
#> # A tibble: 52 × 8
#>     taxonKey countryCode occurrenceStatus establishmentMeans
#>        <int> <chr>       <chr>            <chr>             
#>  1 141117231 BE          present          introduced        
#>  2 141117232 BE          present          introduced        
#>  3 141117233 BE          present          introduced        
#>  4 141117233 BE          present          introduced        
#>  5 141117234 BE          present          introduced        
#>  6 141117234 BE          present          introduced        
#>  7 141117235 BE          present          introduced        
#>  8 141117236 BE          present          introduced        
#>  9 141117236 BE          present          introduced        
#> 10 141117237 BE          present          introduced        
#> # ℹ 42 more rows
#> # ℹ 4 more variables: degreeOfEstablishment <chr>, pathway <chr>,
#> #   eventDate <chr>, source <chr>
```
