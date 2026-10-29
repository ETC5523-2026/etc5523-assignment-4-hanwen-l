#' Count hot days in each fire season
#'
#' Summarises daily weather into one row per town and fire season: how many
#' days reached `threshold`, and how much rain fell. A fire season runs from
#' September to February and is labelled by the year it starts.
#'
#' @param data Daily weather with columns `town`, `season`, `tmax` and `rain`,
#'   such as [fire_daily].
#' @param threshold Temperature in °C. A day counts as hot when its maximum
#'   temperature is at or above this value.
#' @param towns Towns to keep. `NULL`, the default, keeps every town in `data`.
#'
#' @return A tibble with one row per town and season and columns `town`,
#'   `season`, `hot_days` and `total_rain` (in mm).
#' @seealso [compare_periods()] to compare two periods, [plot_hot_days()] to
#'   plot the result.
#' @export
#' @examples
#' summarise_seasons(fire_daily, threshold = 35, towns = "Canberra")
summarise_seasons <- function(data, threshold = 35, towns = NULL) {
  missing_cols <- setdiff(c("town", "season", "tmax", "rain"), names(data))
  if (length(missing_cols) > 0) {
    stop("`data` is missing column(s): ", paste(missing_cols, collapse = ", "),
         call. = FALSE)
  }
  if (!is.numeric(threshold) || length(threshold) != 1 || is.na(threshold)) {
    stop("`threshold` must be a single number.", call. = FALSE)
  }
  if (!is.null(towns)) {
    if (length(towns) == 0) {
      stop("`towns` must name at least one town.", call. = FALSE)
    }
    unknown <- setdiff(towns, data$town)
    if (length(unknown) > 0) {
      stop("Unknown town(s): ", paste(unknown, collapse = ", "), call. = FALSE)
    }
    data <- dplyr::filter(data, .data$town %in% towns)
  }

  dplyr::summarise(
    data,
    hot_days = sum(.data$tmax >= threshold),
    total_rain = sum(.data$rain),
    .by = c("town", "season")
  )
}
