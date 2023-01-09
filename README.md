# DatabaseDashboardExport
Export descriptive statistics from Achilles for the DARWIN-EU Database Dashboard.

## How to execute
1. Install [Achilles](https://github.com/OHDSI/Achilles) and DatabaseDashboardExport.
2. Run Achilles. See [this guide](https://ohdsi.github.io/Achilles/articles/RunningAchilles.html) for detailed instructions
3. Run DatabaseDashboardExport, providing the schema where the Achilles results are located.

One csv file will be written to the given output folder. This file can be uploaded to the DARWIN-EU Database Dashboard.

### Sample code
```R
#install.packages("remotes")
#remotes::install_github('ohdsi/Achilles')
#remotes::install_github('darwin-eu/DatabaseDashboardExport')
library(Achilles)
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

Achilles::achilles(
    connectionDetails = connectionDetails, 
    cdmDatabaseSchema = cdmDatabaseSchema, 
    resultsDatabaseSchema = resultsDatabaseSchema, 
    outputFolder = "achilles_output"
)

DatabaseDashboardExport:::databaseDashboardExport(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    resultsDatabaseSchema = resultsDatabaseSchema,
    outputFolder = "output"
)
```

## Minimal export for Database Dashboard
The export method has an optional argument `exportMinimal`, which defaults to TRUE.
If there are issues with exporting all Achilles analyses, with this toggle you can only export the results that are needed for the Database Dashboard.
For an overview of these required analyses, see [required_analysis_ids.csv](inst/csv/required_analysis_ids.csv).

## Technical description
This package runs one sql script that unions the records from the `achilles_results` and `achilles_results_dist` tables.
In addition, it adds one new analysis 5000 which contains a subset of columns from the `cdm_source` table 
(cdm_source_name, source_release_date, cdm_release_date, cdm_version, vocabulary_version).
The result from this query is written to one csv file. This combines the columns from both achilles tables.