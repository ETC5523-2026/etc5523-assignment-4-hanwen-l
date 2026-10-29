seasons <- data.frame(
  town = rep(c("A", "B"), each = 4),
  season = rep(2000:2003, 2),
  hot_days = c(2, 4, 6, 6, 0, 0, 1, 3),
  total_rain = c(100, 200, 150, 150, 50, 50, 50, 50)
)

test_that("periods are averaged and compared", {
  out <- compare_periods(seasons, c(2000, 2001), c(2002, 2003), min_hot_days = 5)
  expect_equal(out$baseline_hot_days, c(3, 0))
  expect_equal(out$recent_hot_days, c(6, 2))
  expect_equal(out$ratio, c(2, NA))
  expect_equal(out$reliable, c(TRUE, FALSE))
  expect_equal(out$baseline_rain, c(150, 50))
})

test_that("periods are checked", {
  expect_error(compare_periods(seasons, c(2001, 2000), c(2002, 2003)), "two numbers")
  expect_error(compare_periods(seasons, c(1990, 2001), c(2002, 2003)), "within")
})
