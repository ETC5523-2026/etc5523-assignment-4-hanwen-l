#' Plot hot days per fire season
#'
#' Draws one panel per town, on a shared scale, with a bar for the number of
#' hot days in each fire season, a 10-season running mean, and one season
#' highlighted.
#'
#' @param seasons Output of [summarise_seasons()].
#' @param highlight Season to highlight, labelled by the year it starts. The
#'   default, 2019, is the 2019/20 Black Summer.
#'
#' @return A ggplot object.
#' @export
#' @examples
#' plot_hot_days(summarise_seasons(fire_daily, threshold = 35))
plot_hot_days <- function(seasons, highlight = 2019) {
  seasons <- seasons |>
    dplyr::arrange(.data$town, .data$season) |>
    dplyr::mutate(
      running_mean = as.numeric(
        stats::filter(.data$hot_days, rep(1 / 10, 10), sides = 1)
      ),
      .by = "town"
    )

  ggplot2::ggplot(seasons, ggplot2::aes(.data$season, .data$hot_days)) +
    ggplot2::geom_col(fill = "#2a78d6", width = 0.8) +
    ggplot2::geom_col(
      data = seasons[seasons$season == highlight, ],
      fill = "#eb6834",
      width = 0.8
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = .data$running_mean),
      colour = "#0b0b0b",
      linewidth = 0.7,
      na.rm = TRUE
    ) +
    ggplot2::facet_wrap(ggplot2::vars(.data$town)) +
    ggplot2::labs(
      x = "Fire season (year it starts)",
      y = "Hot days",
      caption = paste0(
        "Orange bar: ", highlight, "/", substr(highlight + 1, 3, 4),
        " season. Black line: mean of the last 10 seasons."
      )
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      plot.caption = ggplot2::element_text(colour = "#52514e")
    )
}
