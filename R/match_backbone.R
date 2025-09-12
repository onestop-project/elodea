match_backbone <- function(nubkey_list) {
  nubkey_list %>%
    purrr::map_dfr(
      ~ rgbif::name_usage(key = .x)$data
    ) %>%
    dplyr::select("key", "scientificName") %>%
    dplyr::rename("nubKey" = "key")
}
