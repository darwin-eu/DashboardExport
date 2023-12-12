library(Eunomia)
params <- list(
    connectionDetails = Eunomia::getEunomiaConnectionDetails(),
    cdmDatabaseSchema = 'main',
    resultsDatabaseSchema = 'main',
    databaseId = 'Eunomia',
    outputFolder = testthat::test_path('test_output')
)

hasAchillesResults <- DashboardExport:::.checkAchillesTablesExist(
  connectionDetails = params$connectionDetails,
  resultsDatabaseSchema = params$resultsDatabaseSchema
)

if (!hasAchillesResults) {
  # Run Achilles for a minimal analysis subset
  library(Achilles)
  Achilles::achilles(
    connectionDetails = params$connectionDetails,
    cdmDatabaseSchema = params$cdmDatabaseSchema,
    resultsDatabaseSchema = params$resultsDatabaseSchema,
    outputFolder = file.path(params$outputFolder, 'achilles-logs'),
    analysisIds = c(0, 1, 2, 3, 101, 102, 103, 105, 108, 110, 111, 113, 117, 400, 401, 403, 405, 420, 700, 701, 703, 705, 720),
    verboseMode = FALSE
  )
}
