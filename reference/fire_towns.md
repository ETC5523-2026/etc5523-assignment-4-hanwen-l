# Towns covered by bushfireheat

The towns in
[fire_daily](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/fire_daily.md),
all affected by the 2019/20 Black Summer fires, with the ERA5 grid cell
each one's data come from.

## Usage

``` r
fire_towns
```

## Format

A tibble with one row per town and 7 columns:

- town:

  Town name.

- state:

  State or territory.

- lat, lon:

  Latitude and longitude of the town, in decimal degrees.

- grid_lat, grid_lon:

  Centre of the ERA5 grid cell used for the town.

- elevation:

  Elevation of the town in metres, from a 90 m elevation model.
  Temperatures in
  [fire_daily](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/fire_daily.md)
  are adjusted to this height.

## Source

As for
[fire_daily](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/fire_daily.md).
