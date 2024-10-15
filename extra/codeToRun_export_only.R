#' We assume DashboardExport has been run before and only the export script is executed.
#' If Achilles results are missing, these are first generated. 

# devtools::install_github("darwin-eu/DashboardExport")
library(DashboardExport)
library(Achilles)

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

# Run Achilles to generate the missing results
missingAnalyses <- Achilles::listMissingAnalyses(connectionDetails, resultsDatabaseSchema)
View(missingAnalyses[c('ANALYSIS_ID', 'ANALYSIS_NAME')])
analysisIdsToRun <- missingAnalyses$ANALYSIS_ID # or supply custom list of ids: c(900, 706, 710, 715, 716, 717, 806, 810, 815, 822, 1806, 1810, 1814, 1815, 1822)
Achilles::achilles(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  analysisIds = analysisIdsToRun,
  createTable = FALSE,
  updateGivenAnalysesOnly = TRUE
)

# Create a new export
DashboardExport::exportResults(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFolder = outputFolder,
  databaseId = databaseId
)
