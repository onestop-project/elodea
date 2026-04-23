# Filter data

Filters taxa and distributions data frames, and returns the filtered
data and notes.

## Usage

``` r
filter_data(taxa, distributions)
```

## Arguments

- taxa:

  Data frame as returned by
  [`get_taxa()`](https://onestop-project.github.io/elodea/reference/get_taxa.md).

- distributions:

  Data frame as returned by
  [`get_distributions()`](https://onestop-project.github.io/elodea/reference/get_distributions.md).

## Value

A list with three data frames:

- `taxa`: Filtered taxa data frame, with different columns than the
  input `taxa` data frame.

- `distributions`: Filtered distributions data frame.

- `notes`: Data frame with notes on taxa that were not included or
  replaced in the filtered data.

## Filter details

Taxa are removed if

- they are not matched with the GBIF backbone (i.e., `taxonomicStatus`
  is `NA`),

- they do not have a matching distribution (i.e., `taxonKey` is not in
  `distributions$taxonKey`),

- they are synonyms of accepted taxa (i.e., `acceptedKey` is not `NA`),

- they do not have a matching distribution with
  `establishmentMeans == introduced`.

`scientificName` is replaced with the scientific name matching the GBIF
backbone.

## Taxa details

The `taxa` data frame in the output list has 5 variables:

- `taxonKey`: GBIF taxon key of `scientificName`. This value is replaced
  with `acceptedKey` if the taxon is a synonym of an accepted taxon.

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
# Andorra
datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
taxa <- get_taxa(datasetKey)
distributions <- get_distributions(datasetKey, taxa)
filter_data(taxa, distributions)
#> $taxa
#> # A tibble: 13 × 5
#>     taxonKey taxonID scientificName                            kingdom taxonRank
#>        <int> <chr>   <chr>                                     <chr>   <chr>    
#>  1 148674352 20012   Trachyopella straminea Roháček & Marshal… Animal… SPECIES  
#>  2 148674355 20009   Monochamus sutor (Linnaeus, 1758)         Animal… SPECIES  
#>  3   1179369 20006   Pentarthrum confine Broun, 1881           Animal… SPECIES  
#>  4 148674360 20008   Leptinotarsa decemlineata (Say, 1824)     Animal… SPECIES  
#>  5 148674361 20004   Callosobruchus chinensis (Linnaeus, 1758) Animal… SPECIES  
#>  6 148674362 20001   Bruchus pisorum Linnaeus, 1758            Animal… SPECIES  
#>  7 148674363 20002   Bruchus rufimanus Boheman, 1833           Animal… SPECIES  
#>  8 148674364 20000   Acanthoscelides obtectus (Say, 1831)      Animal… SPECIES  
#>  9   3204007 20010   Pseudoperonospora cubensis (Berk. & M.A.… Chromi… SPECIES  
#> 10 148674377 20005   Entoleuca mammata (Wahlenb.) J.D.Rogers … Fungi   SPECIES  
#> 11 148674383 20011   Senecio inaequidens DC.                   Plantae SPECIES  
#> 12 148674386 20007   Impatiens balfourii Hook.fil.             Plantae SPECIES  
#> 13 148674389 20003   Buddleja davidii Franch.                  Plantae SPECIES  
#> 
#> $distributions
#> # A tibble: 13 × 8
#>     taxonKey countryCode occurrenceStatus establishmentMeans
#>        <int> <chr>       <chr>            <chr>             
#>  1 148674352 AD          present          introduced        
#>  2 148674355 AD          present          introduced        
#>  3   1179369 AD          present          introduced        
#>  4 148674360 AD          present          introduced        
#>  5 148674361 AD          present          introduced        
#>  6 148674362 AD          present          introduced        
#>  7 148674363 AD          present          introduced        
#>  8 148674364 AD          present          introduced        
#>  9   3204007 AD          present          introduced        
#> 10 148674377 AD          present          introduced        
#> 11 148674383 AD          present          introduced        
#> 12 148674386 AD          present          introduced        
#> 13 148674389 AD          present          introduced        
#> # ℹ 4 more variables: degreeOfEstablishment <chr>, pathway <chr>,
#> #   eventDate <chr>, source <chr>
#> 
#> $notes
#> # A tibble: 6 × 6
#>   taxonID  taxonKey scientificName               action acceptedKey acceptedName
#>   <chr>       <int> <chr>                        <chr>        <int> <chr>       
#> 1 20012   148674352 Trachyopella straminea Roha… scien…     1589999 Trachyopell…
#> 2 20009   148674355 Monochamus sutor (LinnÃ©, 1… scien…     8411684 Monochamus …
#> 3 20006   148674358 Euophryum confine (Broun, 1… merge…     1179369 Pentarthrum…
#> 4 20001   148674362 Bruchus pisorum (Linnaeus, … scien…     5752155 Bruchus pis…
#> 5 20010   148674371 Pseudoperonospora humuli (M… merge…     3204007 Pseudoperon…
#> 6 20007   148674386 Impatiens balfourii Hook.f.  scien…     2891783 Impatiens b…
#> 
```
