
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
#> # A tibble: 11 × 5
#>     taxonKey taxonID scientificName                            kingdom taxonRank
#>        <int> <chr>   <chr>                                     <chr>   <chr>    
#>  1 196397247 74020   Phasianus colchicus Linnaeus, 1758        Animal… SPECIES  
#>  2 196397252 74016   Leptoglossus occidentalis Heidemann, 1910 Animal… SPECIES  
#>  3 196397254 74019   Corythauma ayyari (Drake, 1933)           Animal… SPECIES  
#>  4 196397256 74017   Phenacoccus peruvianus Granara de Willin… Animal… SPECIES  
#>  5 196397257 74015   Crisicoccus pini (Kuwana, 1902)           Animal… SPECIES  
#>  6   6275970 74013   Dactylispa pallidipennis (Motschulsky, 1… Animal… SPECIES  
#>  7   5019579 74018   Xyleborus compactus Eichhoff, 1875        Animal… SPECIES  
#>  8 196397264 74014   Trachyphloeosoma advena Zimmerman, 1956   Animal… SPECIES  
#>  9 196397267 74010   Aedes albopictus (Skuse, 1894)            Animal… SPECIES  
#> 10 196397273 74012   Caulerpa racemosa (Forssk.) J.Agardh      Plantae SPECIES  
#> 11 196397274 74011   Caulerpa taxifolia (M.Vahl) C.Agardh      Plantae SPECIES  
#> 
#> $distributions
#> # A tibble: 11 × 8
#>     taxonKey countryCode occurrenceStatus establishmentMeans
#>        <int> <chr>       <chr>            <chr>             
#>  1 196397247 MC          present          introduced        
#>  2 196397252 MC          present          introduced        
#>  3 196397254 MC          present          introduced        
#>  4 196397256 MC          present          introduced        
#>  5 196397257 MC          present          introduced        
#>  6   6275970 MC          present          introduced        
#>  7   5019579 MC          present          introduced        
#>  8 196397264 MC          present          introduced        
#>  9 196397267 MC          present          introduced        
#> 10 196397273 MC          present          introduced        
#> 11 196397274 MC          present          introduced        
#> # ℹ 4 more variables: degreeOfEstablishment <chr>, pathway <chr>,
#> #   eventDate <chr>, source <chr>
#> 
#> $notes
#> # A tibble: 3 × 6
#>   taxonID  taxonKey scientificName               action acceptedKey acceptedName
#>   <chr>       <int> <chr>                        <chr>        <int> <chr>       
#> 1 74013   196397261 Acanthoscelides pallidipenn… merge…     6275970 Dactylispa …
#> 2 74018   196397263 Xylosandrus compactus Eichh… merge…     5019579 Xyleborus c…
#> 3 74010   196397267 Aedes albopictus Skuse, 1894 scien…     1651430 Aedes albop…
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
