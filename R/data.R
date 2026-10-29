#' Daily fire-season weather for towns in south-eastern Australia
#'
#' Daily maximum temperature and rainfall for every day of every fire season,
#' September to February, from 1950/51 to 2025/26, for each town in
#' [fire_towns]. The values come from the ERA5 reanalysis.
#'
#' @format A tibble with one row per town and day and 5 columns:
#' \describe{
#'   \item{town}{Town name; see [fire_towns].}
#'   \item{season}{Fire season, labelled by the year it starts: 2019 is the
#'     2019/20 season, from September 2019 to February 2020.}
#'   \item{date}{Date, in Australian Eastern time.}
#'   \item{tmax}{Daily maximum air temperature 2 m above the ground, in °C.}
#'   \item{rain}{Daily total precipitation, in mm.}
#' }
#'
#' @details ERA5 values are averages over a grid cell about 25 km across, not
#'   readings from a weather station in the town, so they smooth out local
#'   extremes. Open-Meteo picks a land grid cell of similar elevation to each
#'   town and adjusts temperature to the town's elevation. See
#'   `data-raw/fire_daily.R` in the package source for how the data were
#'   downloaded and prepared.
#'
#' @source ERA5 reanalysis (Hersbach et al. 2023, \doi{10.24381/cds.adbb2d47}),
#'   retrieved through the Open-Meteo Historical Weather API (Zippenfenig 2023,
#'   \doi{10.5281/zenodo.7970649}) under the CC BY 4.0 licence. Generated using
#'   Copernicus Climate Change Service information. Daily values were subset to
#'   fire-season months; no other changes were made.
"fire_daily"

#' Towns covered by bushfireheat
#'
#' The towns in [fire_daily], all affected by the 2019/20 Black Summer fires,
#' with the ERA5 grid cell each one's data come from.
#'
#' @format A tibble with one row per town and 7 columns:
#' \describe{
#'   \item{town}{Town name.}
#'   \item{state}{State or territory.}
#'   \item{lat, lon}{Latitude and longitude of the town, in decimal degrees.}
#'   \item{grid_lat, grid_lon}{Centre of the ERA5 grid cell used for the town.}
#'   \item{elevation}{Elevation of the town in metres, from a 90 m elevation
#'     model. Temperatures in [fire_daily] are adjusted to this height.}
#' }
#'
#' @source As for [fire_daily].
"fire_towns"
