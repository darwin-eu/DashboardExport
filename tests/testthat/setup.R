library(Eunomia)
params <- list(
    connectionDetails = Eunomia::getEunomiaConnectionDetails(),
    cdmDatabaseSchema = 'main',
    resultsDatabaseSchema = 'main',
    databaseId = 'Eunomia',
    outputFolder = file.path(tempdir(), "output")
)

# Load Achilles results
achilles_rds_file <- file.path(testthat::test_path(), 'eunomia_achilles_results.rds')
if (file.exists(achilles_rds_file)) {
  print('Loading Achilles results from file')
  achilles_data <- readRDS(achilles_rds_file)
  connection <- DatabaseConnector::connect(params$connectionDetails)
  for (tableName in names(achilles_data)) {
    print(sprintf('Inserting %s', tableName))
    DatabaseConnector::insertTable(
      conn = connection,
      tableName = tableName,
      data = achilles_data[[tableName]],
      createTable = TRUE
    )
  }
  DatabaseConnector::disconnect(connection)
} else {
  # Run Achilles and store results
  Achilles::achilles(
    connectionDetails = params$connectionDetails,
    cdmDatabaseSchema = params$cdmDatabaseSchema,
    resultsDatabaseSchema = params$resultsDatabaseSchema,
    outputFolder = file.path(testthat::test_path(), 'achilles-logs'),
    analysisIds = DashboardExport::getRequiredAnalysisIds()
  )
  connection <- DatabaseConnector::connect(params$connectionDetails)

  # Export data from a table in your database to a data frame
  achilles_data <- list(
    achilles_analysis = DatabaseConnector::querySql(
      connection,
      "SELECT * FROM achilles_analysis"
    ),
    achilles_results = DatabaseConnector::querySql(
      connection,
      "SELECT * FROM achilles_results"
    ),
    achilles_results_dist = DatabaseConnector::querySql(
      connection,
      "SELECT * FROM achilles_results_dist",
    )
  )
  DatabaseConnector::disconnect(connection)
  saveRDS(achilles_data, achilles_rds_file)
  #TODO: clean up of achilles data rds for run on Github Actions
}

