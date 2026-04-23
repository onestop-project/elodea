# Changelog

## elodea (development version)

- [`get_taxa()`](https://onestop-project.github.io/elodea/reference/get_taxa.md)
  now returns the taxonomic status from the GBIF backbone taxonomy
  (`taxonomicStatus`), and not the status from the source checklist
  ([\#19](https://github.com/onestop-project/elodea/issues/19)). It does
  not return the column `nubKey` anymore, and the columns `accepted`,
  `kingdom`, and `taxonRank` have been replaced by `acceptedName`,
  `acceptedKingdom` and `acceptedTaxonRank`.
- [`filter_data()`](https://onestop-project.github.io/elodea/reference/filter_data.md)
  now returns fewer columns
  ([\#19](https://github.com/onestop-project/elodea/issues/19)).

## elodea 0.1.0

- New function
  [`get_taxa()`](https://onestop-project.github.io/elodea/reference/get_taxa.md)
  gets the taxa from a GBIF checklist
  ([\#4](https://github.com/onestop-project/elodea/issues/4)).
- New function
  [`get_distributions()`](https://onestop-project.github.io/elodea/reference/get_distributions.md)
  gets the distributions from a GBIF checklist
  ([\#4](https://github.com/onestop-project/elodea/issues/4)).
- New function
  [`filter_data()`](https://onestop-project.github.io/elodea/reference/filter_data.md)
  filters taxa and distributions, and returns notes describing which
  taxa were removed and why
  ([\#4](https://github.com/onestop-project/elodea/issues/4)).
