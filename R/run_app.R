#' Launch the fire-season heat explorer
#'
#' Opens the package's Shiny app, where you choose towns and a hot-day
#' threshold and compare how often fire-season heat occurs now with the
#' 1950-1979 baseline.
#'
#' @param ... Passed on to [shiny::runApp()], for example
#'   `launch.browser = TRUE`.
#'
#' @return Called for its side effect of running the app.
#' @export
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function(...) {
  app_dir <- system.file("app", package = "bushfireheat")
  if (app_dir == "") {
    stop("Could not find the app. Try re-installing bushfireheat.",
         call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal", ...)
}
