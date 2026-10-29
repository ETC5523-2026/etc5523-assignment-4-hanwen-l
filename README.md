# bushfireheat

bushfireheat helps risk analysts who price bushfire exposure in south-eastern
Australia answer one question: **how much more often does extreme heat occur
in the fire season now than in 1950–1979, and does the answer depend on where
the threshold for "extreme" is set?**

The package contains daily fire-season weather for eight towns affected by the
2019/20 Black Summer fires, functions that count hot days and compare periods,
and a Shiny app for exploring the change town by town.

Documentation website: <https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/>

## Installation

```r
# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-hanwen-l")
```

## Launch the app

```r
library(bushfireheat)
run_app()
```

## Use the functions

```r
seasons <- summarise_seasons(fire_daily, threshold = 35)
compare_periods(seasons)
plot_hot_days(seasons)
```

## Data

`fire_daily` holds the daily maximum temperature and rainfall for every day of
every September–February fire season from 1950/51 to 2025/26, and
`fire_towns` lists the towns. The values come from the ERA5 reanalysis
(Hersbach et al. 2023, <https://doi.org/10.24381/cds.adbb2d47>), retrieved
through the [Open-Meteo Historical Weather API](https://open-meteo.com/)
under the [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) licence.
Generated using Copernicus Climate Change Service information. The daily
values were subset to fire-season months; no other changes were made.

[`data-raw/fire_daily.R`](data-raw/fire_daily.R) downloads and prepares the
data. Raw downloads are cached in `data-raw/raw/`, so the script rebuilds the
package data without calling the API again.

## Generative AI declaration

Generative AI declaration: I used Claude (Claude Code, Anthropic) to explain
the assignment requirements, compare candidate data sources and test the
Open-Meteo API, and to draft the initial package structure: the
data-preparation script, the exported functions with their documentation and
tests, a starter Shiny app, this README and the vignette. I checked and
revised all generated code and text.
