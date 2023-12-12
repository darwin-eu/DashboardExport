test_that("dashboardExport works", {
  DashboardExport::dashboardExport(
    connectionDetails = params$connectionDetails,
    cdmDatabaseSchema = params$cdmDatabaseSchema,
    resultsDatabaseSchema = params$resultsDatabaseSchema,
    databaseId = params$databaseId,
    outputFolder = testthat::test_path('de_output')
  )

  testthat::expect_length(list.files(testthat::test_path('de_output'), pattern = '*.csv'), 1)
})
