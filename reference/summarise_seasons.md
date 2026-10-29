# Count hot days in each fire season

Summarises daily weather into one row per town and fire season: how many
days reached `threshold`, and how much rain fell. A fire season runs
from September to February and is labelled by the year it starts.

## Usage

``` r
summarise_seasons(data, threshold = 35, towns = NULL)
```

## Arguments

- data:

  Daily weather with columns `town`, `season`, `tmax` and `rain`, such
  as
  [fire_daily](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/fire_daily.md).

- threshold:

  Temperature in °C. A day counts as hot when its maximum temperature is
  at or above this value.

- towns:

  Towns to keep. `NULL`, the default, keeps every town in `data`.

## Value

A tibble with one row per town and season and columns `town`, `season`,
`hot_days` and `total_rain` (in mm).

## See also

[`compare_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/compare_periods.md)
to compare two periods,
[`plot_hot_days()`](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/plot_hot_days.md)
to plot the result.

## Examples

``` r
summarise_seasons(fire_daily, threshold = 35, towns = "Canberra")
#> # A tibble: 76 × 4
#>    town     season hot_days total_rain
#>    <chr>     <int>    <int>      <dbl>
#>  1 Canberra   1950        0       320.
#>  2 Canberra   1951        6       221.
#>  3 Canberra   1952        0       244.
#>  4 Canberra   1953        2       285.
#>  5 Canberra   1954        1       260.
#>  6 Canberra   1955        0       291.
#>  7 Canberra   1956        0       150.
#>  8 Canberra   1957        3       245.
#>  9 Canberra   1958        0       382.
#> 10 Canberra   1959        2       396.
#> # ℹ 66 more rows
```
