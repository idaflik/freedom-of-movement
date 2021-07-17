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

greenland <- geo %>% filter(id == "GRL" | id == "DNK")%>%
  summarize(id = "DNK", name = "Denmark", geometry = st_union(geometry))

geo_fixed <- geo %>%
  filter(id != "GRL"  & id != "DNK" & id != "ATA")%>%
  bind_rows(greenland)

name_id <- geo_fixed %>%
  st_set_geometry(NULL)

exportJSON <- toJSON(name_id)
write(exportJSON, "test.json")

data <- read_csv("https://raw.githubusercontent.com/ilyankou/passport-index-dataset/master/legacy/2019-12-17/passport-index-tidy-iso3.csv")%>%
  spread(key = Passport, value = Code)%>%
  mutate(across("AFG":"ZWE", ~replace_na(., 9)))

full <- left_join(geo_fixed, data, by = c("id"="Destination"))

geojson_write(full, geometry = "geometry",  file = "passportindex.geojson")
