# Setup for using CDMConnector dataset with Achilles results pre-loaded
withr::local_envvar(
  R_USER_CACHE_DIR = tempfile(),
  .local_envir = testthat::teardown_env(),
  EUNOMIA_DATA_FOLDER = Sys.getenv("EUNOMIA_DATA_FOLDER", unset = tempfile())
)

datasetName <- "synpuf-1k"
cdmVersion <- "5.3"

tryCatch(
  if (Sys.getenv("skip_eunomia_download_test") != "TRUE") CDMConnector::downloadEunomiaData(datasetName, cdmVersion, overwrite = TRUE),
  error = function(e) NA
)

server <- CDMConnector::eunomiaDir(datasetName, cdmVersion)

params <- list(
  connectionDetails = DatabaseConnector::createConnectionDetails("duckdb", server = server),
  cdmDatabaseSchema = 'main',
  resultsDatabaseSchema = 'main',
  databaseId = datasetName,
  cdmVersion = cdmVersion,
  outputFolder = testthat::test_path()
)
