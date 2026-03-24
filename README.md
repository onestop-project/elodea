
<!-- README.md is generated from README.Rmd. Please edit that file -->

# elodea

<!-- badges: start -->

[![R-CMD-check](https://github.com/onestop-project/elodea/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/onestop-project/elodea/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/onestop-project/elodea/graph/badge.svg)](https://app.codecov.io/gh/onestop-project/elodea)
[![test-coverage](https://github.com/onestop-project/elodea/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/onestop-project/elodea/actions/workflows/test-coverage.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status:
Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- badges: end -->

The goal of elodea is to clean and standardise published GBIF
checklists. With elodea you can prepare checklists on alien species to
create a unified checklist.

To get started, see:

- [Function
  reference](https://onestop-project.github.io/elodea/reference/index.html):
  overview of all functions.

## Installation

You can install the development version of elodea from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("onestop-project/elodea")
```

## Usage

With elodea you can **get** the taxonomic and distribution information
of a published GBIF checklist.

Here we get the source taxa and distributions of the [Global Register of
Introduced and Invasive Species -
Monaco](https://www.gbif.org/dataset/fbba79dc-ca5b-47ab-9a88-9bdf15a1d11f).

``` r
library(elodea)

datasetKey <- "fbba79dc-ca5b-47ab-9a88-9bdf15a1d11f"

taxa <- get_taxa(datasetKey)
distributions <- get_distributions(datasetKey, taxa)
```

Then you can **filter**/standardise both taxa and distributions with
`filter_data()`, which will return a list with three data frames:
`taxa`, `distributions` and `notes`. The first two data frames are the
filtered taxa and distributions, while the `notes` data frame contains
information on the filtering process. Check
[`filter_data()`](https://onestop-project.github.io/elodea/reference/filter_data.html)
for the filter details.

``` r
filter_data(taxa, distributions)
#> $taxa
#> # A tibble: 11 × 8
#>    taxonKey nubKey taxonID scientificName acceptedKey accepted kingdom taxonRank
#>       <int>  <int> <chr>   <chr>                <int> <chr>    <chr>   <chr>    
#>  1   1.96e8 9.75e6 74020   Phasianus col…          NA <NA>     Animal… species  
#>  2   1.96e8 5.16e6 74016   Leptoglossus …          NA <NA>     Animal… species  
#>  3   1.96e8 8.00e6 74019   Corythauma ay…          NA <NA>     Animal… species  
#>  4   1.96e8 9.30e6 74017   Phenacoccus p…          NA <NA>     Animal… species  
#>  5   1.96e8 2.09e6 74015   Crisicoccus p…          NA <NA>     Animal… species  
#>  6   1.96e8 8.64e6 74018   Xylosandrus c…          NA <NA>     Animal… species  
#>  7   1.96e8 4.29e6 74014   Trachyphloeos…          NA <NA>     Animal… species  
#>  8   1.96e8 1.65e6 74010   Aedes albopic…          NA <NA>     Animal… species  
#>  9   1.96e8 2.64e6 74012   Caulerpa race…          NA <NA>     Plantae species  
#> 10   1.96e8 2.64e6 74011   Caulerpa taxi…          NA <NA>     Plantae species  
#> 11   3.16e8 6.28e6 <NA>    Dactylispa pa…          NA <NA>     Animal… species  
#> 
#> $distributions
#> # A tibble: 11 × 9
#>     taxonKey  nubKey countryCode occurrenceStatus establishmentMeans
#>        <int>   <int> <chr>       <chr>            <chr>             
#>  1 196397247 9752149 MC          present          introduced        
#>  2 196397252 5156102 MC          present          introduced        
#>  3 196397254 8001222 MC          present          introduced        
#>  4 196397256 9302212 MC          present          introduced        
#>  5 196397257 2094171 MC          present          introduced        
#>  6 196397263 8636797 MC          present          introduced        
#>  7 196397264 4292054 MC          present          introduced        
#>  8 196397267 1651430 MC          present          introduced        
#>  9 196397273 2643093 MC          present          introduced        
#> 10 196397274 2643172 MC          present          introduced        
#> 11 315739672 6275970 MC          present          introduced        
#> # ℹ 4 more variables: degreeOfEstablishment <chr>, pathway <chr>,
#> #   eventDate <chr>, source <chr>
#> 
#> $notes
#> # A tibble: 3 × 6
#>   taxonID  taxonKey scientificName                   action acceptedKey accepted
#>   <chr>       <int> <chr>                            <chr>        <int> <chr>   
#> 1 74013   196397261 Acanthoscelides pallidipennis (… merge…   315739672 Dactyli…
#> 2 74018   196397263 Xylosandrus compactus Eichhoff,… scien…          NA <NA>    
#> 3 74010   196397267 Aedes albopictus Skuse, 1894     scien…          NA <NA>
```

The notes can help improve the source checklist. The standardised taxa
and distribution data can be used to build unified checklists by
combining multiple checklists into a single checklist.

## Meta

- We welcome
  [contributions](https://onestop-project.github.io/elodea/CONTRIBUTING.html)
  including bug reports.
- License: MIT
- Get [citation
  information](https://onestop-project.github.io/elodea/authors.html#citation)
  for elodea in R doing `citation("elodea")`.
- Please note that this project is released with a [Contributor Code of
  Conduct](https://onestop-project.github.io/elodea/CODE_OF_CONDUCT.html).
  By participating in this project you agree to abide by its terms.
