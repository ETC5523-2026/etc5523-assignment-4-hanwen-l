daily <- data.frame(
  town = rep(c("A", "B"), each = 4),
  season = rep(c(2000, 2000, 2001, 2001), 2),
  tmax = c(34, 35, 36, 20, 30, 30, 41, 39),
  rain = c(1, 2, 0, 5, 0, 0, 3, 3)
)

test_that("hot days count days at or above the threshold", {
  out <- summarise_seasons(daily, threshold = 35)
  expect_equal(out$hot_days, c(1, 1, 0, 2))
  expect_equal(out$total_rain, c(3, 5, 0, 6))
})

test_that("towns are filtered and checked", {
  expect_equal(unique(summarise_seasons(daily, towns = "B")$town), "B")
  expect_error(summarise_seasons(daily, towns = "C"), "Unknown town")
  expect_error(summarise_seasons(daily, towns = character(0)), "at least one")
})

test_that("bad input gives informative errors", {
  expect_error(summarise_seasons(daily[-3], 35), "missing column")
  expect_error(summarise_seasons(daily, threshold = "35"), "single number")
})
