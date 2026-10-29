#' Compare hot days and rainfall between two periods
#'
#' For each town, compares the average number of hot days and the average
#' rainfall per fire season in a recent period with a baseline period, and
#' flags towns where the baseline has too few hot days for the ratio to mean
#' much.
#'
#' @param seasons Output of [summarise_seasons()].
#' @param baseline,recent The first and last season of each period, inclusive,
#'   as two numbers.
#' @param min_hot_days The fewest hot days the baseline must contain, summed
#'   over all its seasons, for the ratio to count as reliable. Below this a
#'   handful of extra hot days can produce a very large ratio.
#'
#' @return A tibble with one row per town and columns:
#' \describe{
#'   \item{town}{Town name.}
#'   \item{baseline_hot_days, recent_hot_days}{Mean hot days per season in
#'     each period.}
#'   \item{ratio}{`recent_hot_days / baseline_hot_days`, or `NA` when the
#'     baseline has no hot days.}
#'   \item{reliable}{Whether the baseline has at least `min_hot_days` hot
#'     days.}
#'   \item{baseline_total}{Total hot days in the baseline.}
#'   \item{baseline_rain, recent_rain}{Mean total rainfall per season in each
#'     period, in mm.}
#' }
#' @export
#' @examples
#' seasons <- summarise_seasons(fire_daily, threshold = 35)
#' compare_periods(seasons)
#'
#' # A higher threshold leaves too few baseline hot days in some towns
#' compare_periods(summarise_seasons(fire_daily, threshold = 40))
compare_periods <- function(seasons, baseline = c(1950, 1979),
                            recent = c(1996, 2025), min_hot_days = 10) {
  check_period(baseline, seasons$season, "baseline")
  check_period(recent, seasons$season, "recent")

  in_period <- function(season, period) {
    season >= period[1] & season <= period[2]
  }

  seasons |>
    dplyr::summarise(
      baseline_hot_days = mean(.data$hot_days[in_period(.data$season, baseline)]),
      recent_hot_days = mean(.data$hot_days[in_period(.data$season, recent)]),
      baseline_total = sum(.data$hot_days[in_period(.data$season, baseline)]),
      baseline_rain = mean(.data$total_rain[in_period(.data$season, baseline)]),
      recent_rain = mean(.data$total_rain[in_period(.data$season, recent)]),
      .by = "town"
    ) |>
    dplyr::mutate(
      ratio = dplyr::if_else(
        .data$baseline_hot_days > 0,
        .data$recent_hot_days / .data$baseline_hot_days,
        NA_real_
      ),
      reliable = .data$baseline_total >= min_hot_days,
      .after = "recent_hot_days"
    )
}

check_period <- function(period, seasons, arg) {
  if (!is.numeric(period) || length(period) != 2 || anyNA(period) ||
      period[1] > period[2]) {
    stop("`", arg, "` must be two numbers: the first and last season.",
         call. = FALSE)
  }
  if (period[1] < min(seasons) || period[2] > max(seasons)) {
    stop("`", arg, "` must lie within the seasons in the data (",
         min(seasons), " to ", max(seasons), ").", call. = FALSE)
  }
}
