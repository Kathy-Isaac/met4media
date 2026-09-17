commercial_media <- readRDS("data-raw/commercial_media.rds")
metabolite_categories <- readRDS("data-raw/metabolite_categories.rds")

usethis::use_data(commercial_media, metabolite_categories, overwrite = TRUE)
