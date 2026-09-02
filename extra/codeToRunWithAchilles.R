#' This script provides an example of how to run the CdmOnboarding package.
#' It retrieves connection details from environment variables defeined your .Renviron file:
#' Note that these follow DBI driver settings and might differ per DBMS. For postgres:
#'    DBMS = "postgresql"
#'    DB_HOST = "localhost_or_other_host"
#'    DB_PORT = 5432
#'    DB_NAME = "your_database_name"
#'    DB_USER = "your_user"
#'    DB_PASSWORD = "your_secret_password"
#'    CDM_SCHEMA = "your_cdm_schema"
#'    RESULTS_SCHEMA = "your_achilles_results_schema"
#'
#' Examples for other DBMS: https://darwin-eu.github.io/CDMConnector/articles/a04_DBI_connection_examples.html

if (!requireNamespace("DashboardExport", quietly = TRUE)) {
  library(remotes)
  remotes::install_github("darwin-eu/DashboardExport")
}
library(DashboardExport)

connectionDetails <- DatabaseConnector::createDbiConnectionDetails(
  dbms = Sys.getenv("DBMS"),
  drv = RPostgres::Postgres(),
  host = Sys.getenv("DB_HOST"),
  port = Sys.getenv("DB_PORT"),
  dbname = Sys.getenv("DB_NAME"),
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD")
)

cdmDatabaseSchema <- Sys.getenv("CDM_SCHEMA")
resultsDatabaseSchema <- Sys.getenv("RESULTS_SCHEMA")
outputFolder <- "output"
databaseId <- Sys.getenv("DATABASE_ID")

# Achilles is required. Use the following to run only the minimally required Achilles analyses:
Achilles::achilles(
    connectionDetails = connectionDetails, 
    cdmDatabaseSchema = cdmDatabaseSchema,
    resultsDatabaseSchema = resultsDatabaseSchema, 
    outputFolder = "achilles_output",
    analysisIds = DashboardExport::getRequiredAnalysisIds()
)

DashboardExport::dashboardExport(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFolder = outputFolder,
  databaseId = databaseId
)
