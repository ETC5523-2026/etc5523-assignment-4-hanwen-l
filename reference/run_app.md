# Launch the fire-season heat explorer

Opens the package's Shiny app, where you choose towns and a hot-day
threshold and compare how often fire-season heat occurs now with the
1950-1979 baseline.

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Passed on to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), for
  example `launch.browser = TRUE`.

## Value

Called for its side effect of running the app.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
