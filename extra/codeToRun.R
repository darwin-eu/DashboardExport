library(DatabaseDashboardExport)

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

DatabaseDashboardExport:::databaseDashboardExport(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    resultsDatabaseSchema = resultsDatabaseSchema,
    outputFolder = "output",
    exportMinimal = TRUE
)
