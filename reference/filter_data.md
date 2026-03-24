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

- `taxa`: Filtered taxa data frame.

- `distributions`: Filtered distributions data frame, with extra column
  `nubKey`.

- `notes`: Data frame with notes on taxa that were not included or
  replaced in the filtered data.

## Filter details

Taxa are removed if

- they are not matched with the GBIF backbone (i.e., `nubKey` is `NA`),

- they do not have a matching distribution (i.e., `taxonKey` is not in
  `distributions$taxonKey`),

- they are synonyms of accepted taxa (i.e., `acceptedKey` is not `NA`),

- they do not have a matching distribution with
  `establishmentMeans == introduced`.

`scientificName` is replaced with the scientific name matching the GBIF
backbone.

## Examples

``` r
# Andorra
datasetKey <- "016c16c3-d907-4c88-97dd-97ad62c8130e"
taxa <- get_taxa(datasetKey)
distributions <- get_distributions(datasetKey, taxa)
filter_data(taxa, distributions)
#> $taxa
#> # A tibble: 13 × 8
#>    taxonKey nubKey taxonID scientificName acceptedKey accepted kingdom taxonRank
#>       <int>  <int> <chr>   <chr>                <int> <chr>    <chr>   <chr>    
#>  1   1.49e8 1.59e6 20012   Trachyopella …          NA NA       Animal… species  
#>  2   1.49e8 8.41e6 20009   Monochamus su…          NA NA       Animal… species  
#>  3   1.49e8 1.05e6 20008   Leptinotarsa …          NA NA       Animal… species  
#>  4   1.49e8 1.05e6 20004   Callosobruchu…          NA NA       Animal… species  
#>  5   1.49e8 5.75e6 20001   Bruchus pisor…          NA NA       Animal… species  
#>  6   1.49e8 5.75e6 20002   Bruchus rufim…          NA NA       Animal… species  
#>  7   1.49e8 1.05e6 20000   Acanthoscelid…          NA NA       Animal… species  
#>  8   1.49e8 2.58e6 20005   Entoleuca mam…          NA NA       Fungi   species  
#>  9   1.49e8 3.11e6 20011   Senecio inaeq…          NA NA       Plantae species  
#> 10   1.49e8 2.89e6 20007   Impatiens bal…          NA NA       Plantae species  
#> 11   1.49e8 3.17e6 20003   Buddleja davi…          NA NA       Plantae species  
#> 12   3.16e8 1.18e6 NA      Pentarthrum c…          NA NA       Animal… species  
#> 13   3.16e8 3.20e6 NA      Pseudoperonos…          NA NA       Chromi… species  
#> 
#> $distributions
#> # A tibble: 13 × 9
#>     taxonKey  nubKey countryCode occurrenceStatus establishmentMeans
#>        <int>   <int> <chr>       <chr>            <chr>             
#>  1 148674352 1589999 AD          present          introduced        
#>  2 148674355 8411684 AD          present          introduced        
#>  3 148674360 1047536 AD          present          introduced        
#>  4 148674361 1047341 AD          present          introduced        
#>  5 148674362 5752155 AD          present          introduced        
#>  6 148674363 5752143 AD          present          introduced        
#>  7 148674364 1047525 AD          present          introduced        
#>  8 148674377 2576553 AD          present          introduced        
#>  9 148674383 3109086 AD          present          introduced        
#> 10 148674386 2891783 AD          present          introduced        
#> 11 148674389 3173338 AD          present          introduced        
#> 12 315787873 1179369 AD          present          introduced        
#> 13 315787881 3204007 AD          present          introduced        
#> # ℹ 4 more variables: degreeOfEstablishment <chr>, pathway <chr>,
#> #   eventDate <chr>, source <chr>
#> 
#> $notes
#> # A tibble: 6 × 6
#>   taxonID  taxonKey scientificName                   action acceptedKey accepted
#>   <chr>       <int> <chr>                            <chr>        <int> <chr>   
#> 1 20012   148674352 Trachyopella straminea Rohacek … scien…          NA NA      
#> 2 20009   148674355 Monochamus sutor (LinnÃ©, 1758)  scien…          NA NA      
#> 3 20006   148674358 Euophryum confine (Broun, 1880)  merge…   315787873 Pentart…
#> 4 20001   148674362 Bruchus pisorum (Linnaeus, 1758) scien…          NA NA      
#> 5 20010   148674371 Pseudoperonospora humuli (Miyab… merge…   315787881 Pseudop…
#> 6 20007   148674386 Impatiens balfourii Hook.f.      scien…          NA NA      
#> 
```
