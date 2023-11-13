test_that("dashboardExport works", {
  do.call(
    DashboardExport::dashboardExport,
    params
  )

  testthat::expect_length(list.files(params$outputFolder, pattern = '*.csv'), 1)
})
