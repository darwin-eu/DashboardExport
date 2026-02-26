if (!requireNamespace("DashboardExport", quietly = TRUE)) {
  library(remotes)
  remotes::install_github("darwin-eu/DashboardExport")
}
library(DashboardExport)

dbms <- Sys.getenv("DBMS")
user <- Sys.getenv("DB_USER")
password <- Sys.getenv("DB_PASSWORD")
server <- Sys.getenv("DB_SERVER")
port <- Sys.getenv("DB_PORT")
pathToDriver <- Sys.getenv("PATH_TO_DRIVER")

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = dbms,
  server = server,
  port = port,
  user = user,
  password = password,
  pathToDriver = pathToDriver
)

cdmDatabaseSchema <- Sys.getenv("CDM_SCHEMA")
resultsDatabaseSchema <- Sys.getenv("RESULTS_SCHEMA")
outputFolder <- "output"
databaseId <- Sys.getenv("DATABASE_ID")


Achilles::achilles(
    connectionDetails = connectionDetails, 
    cdmDatabaseSchema = cdmDatabaseSchema,
    resultsDatabaseSchema = resultsDatabaseSchema, 
    outputFolder = "achilles_output",
    # For running only the minimally required Achilles analyses:
    analysisIds = DashboardExport::getRequiredAnalysisIds()
)

DashboardExport::dashboardExport(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFolder = outputFolder,
  databaseId = databaseId
)
