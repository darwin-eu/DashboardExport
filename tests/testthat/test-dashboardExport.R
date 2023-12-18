test_that("dashboardExport works", {
  DashboardExport::dashboardExport(
    connectionDetails = params$connectionDetails,
    cdmDatabaseSchema = params$cdmDatabaseSchema,
    resultsDatabaseSchema = params$resultsDatabaseSchema,
    databaseId = params$databaseId,
    outputFolder = params$outputFolder
  )

  testthat::expect_length(list.files(params$outputFolder, pattern = '*.csv'), 1)
})
