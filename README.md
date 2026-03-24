
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
Cyprus](https://www.gbif.org/dataset/2f7ea7d1-a73f-46f6-b790-7339126a999f).

``` r
library(elodea)

datasetKey <- "2f7ea7d1-a73f-46f6-b790-7339126a999f"

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
#> # A tibble: 558 × 8
#>    taxonKey nubKey taxonID scientificName acceptedKey accepted kingdom taxonRank
#>       <int>  <int> <chr>   <chr>                <int> <chr>    <chr>   <chr>    
#>  1   1.49e8 3.20e6 21008   Stypopodium s…          NA <NA>     Chromi… <NA>     
#>  2   1.49e8 5.42e6 20939   Rhizosolenia …          NA <NA>     Chromi… <NA>     
#>  3   1.49e8 4.55e6 21062   Xiphinema bre…          NA <NA>     Animal… <NA>     
#>  4   1.49e8 4.55e6 21063   Xiphinema ind…          NA <NA>     Animal… <NA>     
#>  5   1.49e8 4.55e6 21064   Xiphinema ita…          NA <NA>     Animal… <NA>     
#>  6   1.49e8 4.56e6 20794   Meloidogyne a…          NA <NA>     Animal… <NA>     
#>  7   1.49e8 2.28e6 20795   Meloidogyne h…          NA <NA>     Animal… <NA>     
#>  8   1.49e8 5.19e6 20694   Globodera ros…          NA <NA>     Animal… <NA>     
#>  9   1.49e8 4.56e6 20647   Ditylenchus d…          NA <NA>     Animal… <NA>     
#> 10   1.49e8 8.27e6 20915   Pseudolachlan…          NA <NA>     Chromi… <NA>     
#> # ℹ 548 more rows
#> 
#> $distributions
#> # A tibble: 547 × 9
#>     taxonKey  nubKey countryCode occurrenceStatus establishmentMeans
#>        <int>   <int> <chr>       <chr>            <chr>             
#>  1 148692906 3200580 CY          present          introduced        
#>  2 148692918 5421948 CY          present          introduced        
#>  3 148692922 4554475 CY          present          introduced        
#>  4 148692923 4554493 CY          present          introduced        
#>  5 148692924 4554459 CY          present          introduced        
#>  6 148692930 4556299 CY          present          introduced        
#>  7 148692935 2283982 CY          present          introduced        
#>  8 148692937 5188667 CY          present          introduced        
#>  9 148692941 4555875 CY          present          introduced        
#> 10 148692948 8271018 CY          present          introduced        
#> # ℹ 537 more rows
#> # ℹ 4 more variables: degreeOfEstablishment <chr>, pathway <chr>,
#> #   eventDate <chr>, source <chr>
#> 
#> $notes
#> # A tibble: 198 × 6
#>    taxonID  taxonKey scientificName                  action acceptedKey accepted
#>    <chr>       <int> <chr>                           <chr>        <int> <chr>   
#>  1 20667   148692903 Eriophyes pyri (H.A.Pagenstech… merge…   315786884 Phytopt…
#>  2 20939   148692918 Rhizosolenia calcar-avis M.Sch… scien…          NA <NA>    
#>  3 20917   148692921 Pseudosolenia calcar-avis (Sch… merge…   148692918 Rhizoso…
#>  4 20794   148692930 Meloidogyne arenaria (Neal, 18… scien…          NA <NA>    
#>  5 20881   148692936 Phytophthora citrophthora (R.E… estab…          NA <NA>    
#>  6 20694   148692937 Globodera rostochiensis (Wolle… scien…          NA <NA>    
#>  7 20693   148692938 Globodera pallida (Stone, 1973) estab…          NA <NA>    
#>  8 20942   148692957 Rhopilema nomadica Galil, 1990  scien…          NA <NA>    
#>  9 20572   148692960 Cassiopea andromeda (ForsskÃ¥l… scien…          NA <NA>    
#> 10 20827   148692980 Oenone fulgida (Savigny, 1818)  estab…          NA <NA>    
#> # ℹ 188 more rows
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
