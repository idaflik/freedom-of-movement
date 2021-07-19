library(needs)

needs(tidyverse,
      ggplot2,
      readxl,
      sf,
      geojsonio,
      glue,
      # rmapshaper,
      jsonlite
)

geo <- geojson_read("https://raw.githubusercontent.com/johan/world.geo.json/master/countries.geo.json",
                             what = "sp") %>%
  st_as_sf()

data <- read_csv("https://raw.githubusercontent.com/ilyankou/passport-index-dataset/master/legacy/2019-12-17/passport-index-tidy-iso3.csv")%>%
  spread(key = Passport, value = Code)%>%
  mutate(across("AFG":"ZWE", ~replace_na(., 9)))

full <- left_join(geo, data, by = c("id"="Destination"))%>%
  filter(!is.na(AFG))

geojson_write(full, geometry = "geometry",  file = "passportindex.geojson")

name_id <- full %>%
  st_set_geometry(NULL) %>%
  select(id, name)%>%
  mutate(name = case_when(id == "PSE" ~ "Palestine West Bank",
                          id == "TZA" ~ "Tanzania",
                          TRUE ~ name
                          ))%>%
  arrange(name)

exportJSON <- str_c("var dropdown_options = ", str_replace_all(as.character(toJSON(name_id)), c('"id":'=' id: ',
                                                               '"name":'=' name: ')))
write(exportJSON, "countrynames.js")
