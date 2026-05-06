# elodea (development version)
* `get_taxa()` now returns the taxonomic status from the GBIF backbone taxonomy (`taxonomicStatus`), and not the status from the source checklist (#19). The columns `accepted`, `kingdom`, and `taxonRank` have been replaced by `acceptedName`, `acceptedKingdom` and `acceptedTaxonRank`.
* `filter_data()` now returns fewer columns (#19).
* `filter_data()` has a new argument `establishment_means` that allows custom filtering taxa based on establishmentMeans (e.g. native, introduced), instead of built-in filtering on "introduced" taxa (#24).
* `get_distributions()` now returns the verbatim distributions (#30).

# elodea 0.1.0

* New function `get_taxa()` gets the taxa from a GBIF checklist (#4).
* New function `get_distributions()` gets the distributions from a GBIF checklist (#4).
* New function `filter_data()` filters taxa and distributions, and returns notes describing which taxa were removed and why (#4).
