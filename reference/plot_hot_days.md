# Plot hot days per fire season

Draws one panel per town, on a shared scale, with a bar for the number
of hot days in each fire season, a 10-season running mean, and one
season highlighted.

## Usage

``` r
plot_hot_days(seasons, highlight = 2019)
```

## Arguments

- seasons:

  Output of
  [`summarise_seasons()`](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/summarise_seasons.md).

- highlight:

  Season to highlight, labelled by the year it starts. The default,
  2019, is the 2019/20 Black Summer.

## Value

A ggplot object.

## Examples

``` r
plot_hot_days(summarise_seasons(fire_daily, threshold = 35))
```
