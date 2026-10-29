# Compare hot days and rainfall between two periods

For each town, compares the average number of hot days and the average
rainfall per fire season in a recent period with a baseline period, and
flags towns where the baseline has too few hot days for the ratio to
mean much.

## Usage

``` r
compare_periods(
  seasons,
  baseline = c(1950, 1979),
  recent = c(1996, 2025),
  min_hot_days = 10
)
```

## Arguments

- seasons:

  Output of
  [`summarise_seasons()`](https://etc5523-2026.github.io/etc5523-assignment-4-hanwen-l/reference/summarise_seasons.md).

- baseline, recent:

  The first and last season of each period, inclusive, as two numbers.

- min_hot_days:

  The fewest hot days the baseline must contain, summed over all its
  seasons, for the ratio to count as reliable. Below this a handful of
  extra hot days can produce a very large ratio.

## Value

A tibble with one row per town and columns:

- town:

  Town name.

- baseline_hot_days, recent_hot_days:

  Mean hot days per season in each period.

- ratio:

  `recent_hot_days / baseline_hot_days`, or `NA` when the baseline has
  no hot days.

- reliable:

  Whether the baseline has at least `min_hot_days` hot days.

- baseline_total:

  Total hot days in the baseline.

- baseline_rain, recent_rain:

  Mean total rainfall per season in each period, in mm.

## Examples

``` r
seasons <- summarise_seasons(fire_daily, threshold = 35)
compare_periods(seasons)
#> # A tibble: 5 × 8
#>   town       baseline_hot_days recent_hot_days ratio reliable baseline_total
#>   <chr>                  <dbl>           <dbl> <dbl> <lgl>             <int>
#> 1 Armidale              0.0667           0.167  2.5  FALSE                 2
#> 2 Bairnsdale            4.2              5.9    1.40 TRUE                126
#> 3 Bega                  1.5              2.07   1.38 TRUE                 45
#> 4 Canberra              1.1              3.27   2.97 TRUE                 33
#> 5 Grafton               3.77             5.4    1.43 TRUE                113
#> # ℹ 2 more variables: baseline_rain <dbl>, recent_rain <dbl>

# A higher threshold leaves too few baseline hot days in some towns
compare_periods(summarise_seasons(fire_daily, threshold = 40))
#> # A tibble: 5 × 8
#>   town       baseline_hot_days recent_hot_days ratio reliable baseline_total
#>   <chr>                  <dbl>           <dbl> <dbl> <lgl>             <int>
#> 1 Armidale               0               0     NA    FALSE                 0
#> 2 Bairnsdale             0.233           0.7    3    FALSE                 7
#> 3 Bega                   0               0.133 NA    FALSE                 0
#> 4 Canberra               0               0     NA    FALSE                 0
#> 5 Grafton                0.1             0.167  1.67 FALSE                 3
#> # ℹ 2 more variables: baseline_rain <dbl>, recent_rain <dbl>
```
