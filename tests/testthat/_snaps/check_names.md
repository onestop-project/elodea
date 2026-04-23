# check_names() prints the expected summary via cli

    Code
      result <- check_names(example_checklist)
    Message
      
      -- Summary --
      
      * 3 synonyms
      * 4 taxa with no exact match
      
      -- Synonyms - rawScientificName: acceptedScientificName 
      Amaranthus macrocarpus Benth. var. pallidus Benth.: Amaranthus macrocarpus
      subsp. pallidus (Benth.) N.Bayón
      Amaranthus macrocarpus Benth. var. pallidus Benth.: Amaranthus macrocarpus
      subsp. pallidus (Benth.) N.Bayón
      Ovis gmelinii subsp. musimon (Pallas, 1811): Ovis aries musimon (Pallas, 1811)
      
      -- No match - rawScientificName: best match 
      Cotoneaster x 'Hybridus pendulus': Plantae
      AseroÙ rubra: Fungi
      Hemidactylus (Oken, 1817): Hemidactylus Oken, 1817
      Lepisma saccharina: Lepisma saccharinum Linnaeus, 1758

