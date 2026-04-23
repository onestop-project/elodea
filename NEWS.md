# elodea (development version)
* `get_taxa()` now returns the taxonomic status from the GBIF backbone taxonomy (`taxonomicStatus`), and not the status from the source checklist (#19). It does not return the column `nubKey` anymore, and the columns `accepted`, `kingdom`, and `taxonRank` have been replaced by `acceptedName`, `acceptedKingdom` and `acceptedTaxonRank`.
* `filter_data()` now returns fewer columns (#19).

* New example_checklist CSV file with 10 taxa, including some with misspelled names and some with names that are not in the GBIF backbone taxonomy (#4).
* New function `check_names()` checks the names of taxa in a checklist.csv against the GBIF backbone taxonomy (#).

# elodea 0.1.0

* New function `get_taxa()` gets the taxa from a GBIF checklist (#4).
* New function `get_distributions()` gets the distributions from a GBIF checklist (#4).
* New function `filter_data()` filters taxa and distributions, and returns notes describing which taxa were removed and why (#4).
