# Prepare `fire_towns` and `fire_daily` from the ERA5 reanalysis.
#
# Daily weather comes from the Open-Meteo Historical Weather API
# (https://open-meteo.com/en/docs/historical-weather-api), which serves ERA5
# under CC BY 4.0. The script requests `models = "era5"` explicitly: the API's
# default blends ERA5 with ERA5-Land and ECMWF IFS, and switching source
# part-way through the record shifts the level of the series. By default the
# API also picks a land grid cell of similar elevation to each town and adjusts
# temperature to the town's own elevation (from a 90 m elevation model), which
# is recorded as `elevation`.
#
# Each town's record is downloaded once and cached in data-raw/raw/, so
# re-running the script rebuilds the data without calling the API again. The
# free tier caps weighted calls at 600 a minute, 5,000 an hour and 10,000 a day,
# and one town's 1950-2026 record costs about 2,000, so a download from scratch
# takes more than one run: re-run the script after the limit resets and only the
# missing towns are fetched.
#
# Needs dplyr, httr2, purrr and readr, which are not package dependencies.

library(dplyr)
library(httr2)
library(purrr)
library(readr)

first_season <- 1950L
last_season <- 2025L
cache_dir <- "data-raw/raw"

# Towns affected by the 2019/20 Black Summer fires, from northern NSW to
# East Gippsland.
towns <- tribble(
  ~town,        ~state, ~lat,   ~lon,
  "Armidale",   "NSW",  -30.51, 151.67,
  "Bairnsdale", "VIC",  -37.82, 147.63,
  "Bega",       "NSW",  -36.67, 149.84,
  "Canberra",   "ACT",  -35.28, 149.13,
  "Grafton",    "NSW",  -29.69, 152.93,
  "Katoomba",   "NSW",  -33.71, 150.31,
  "Orbost",     "VIC",  -37.70, 148.46,
  "Tumut",      "NSW",  -35.30, 148.22
)

cache_path <- function(town) {
  file.path(cache_dir, paste0("era5_", tolower(town), ".csv.gz"))
}

download_town <- function(town, lat, lon) {
  last_day <- as.Date(paste0(last_season + 1L, "-03-01")) - 1
  resp <- request("https://archive-api.open-meteo.com/v1/archive") |>
    req_url_query(
      latitude = lat,
      longitude = lon,
      start_date = paste0(first_season, "-09-01"),
      end_date = format(last_day),
      daily = "temperature_2m_max,precipitation_sum",
      models = "era5",
      timezone = "Australia/Sydney"
    ) |>
    req_error(body = \(resp) resp_body_json(resp)$reason) |>
    req_perform() |>
    resp_body_json(simplifyVector = TRUE)

  tibble(
    town = town,
    grid_lat = resp$latitude,
    grid_lon = resp$longitude,
    elevation = resp$elevation,
    date = as.Date(resp$daily$time),
    tmax = resp$daily$temperature_2m_max,
    rain = resp$daily$precipitation_sum
  )
}

# Download --------------------------------------------------------------------

dir.create(cache_dir, showWarnings = FALSE)
to_download <- filter(towns, !file.exists(cache_path(town)))

for (i in seq_len(nrow(to_download))) {
  # The free tier also caps weighted calls per minute, and one town uses it up.
  if (i > 1) Sys.sleep(61)
  name <- to_download$town[i]
  message("Downloading ", name)
  result <- tryCatch(
    download_town(name, to_download$lat[i], to_download$lon[i]),
    error = \(e) e
  )
  if (inherits(result, "error")) {
    message("Stopped at ", name, ": ", conditionMessage(result))
    break
  }
  write_csv(result, cache_path(name))
}

cached <- filter(towns, file.exists(cache_path(town)))
if (nrow(cached) < nrow(towns)) {
  warning(
    "Only ", nrow(cached), " of ", nrow(towns), " towns are cached (missing: ",
    paste(setdiff(towns$town, cached$town), collapse = ", "),
    "). Re-run this script after the API limit resets.",
    call. = FALSE
  )
}

era5 <- cache_path(cached$town) |>
  map(\(path) read_csv(path, col_types = cols(town = "c", date = "D", .default = "d"))) |>
  list_rbind()

# Prepare ---------------------------------------------------------------------

grid_cells <- distinct(era5, town, grid_lat, grid_lon, elevation)
fire_towns <- inner_join(cached, grid_cells, by = "town")

# A fire season runs from September to February and is labelled by the year it
# starts, so January 2020 belongs to the 2019 (2019/20) season.
fire_daily <- era5 |>
  mutate(
    month = as.integer(format(date, "%m")),
    year = as.integer(format(date, "%Y")),
    season = if_else(month >= 9, year, year - 1L)
  ) |>
  filter(month >= 9 | month <= 2, between(season, first_season, last_season)) |>
  select(town, season, date, tmax, rain) |>
  arrange(town, date)

# Every season should be complete: 181 days, or 182 when February has 29.
season_lengths <- count(fire_daily, town, season)
stopifnot(
  !anyNA(fire_daily),
  all(season_lengths$n %in% c(181, 182)),
  nrow(season_lengths) == nrow(cached) * (last_season - first_season + 1)
)

usethis::use_data(fire_daily, fire_towns, overwrite = TRUE, compress = "xz")
