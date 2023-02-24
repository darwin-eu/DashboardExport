# DashboardExport
Export descriptive statistics from a subset of Achilles results for the DARWIN-EU Database Dashboard.
All counts are rounded up to nearest hundred and counts below the `smallCellCount` are not exported.
For an overview of the exported Achilles analyses, see [required_analysis_ids.csv](inst/csv/required_analysis_ids.csv).

## How to execute
1. Install [Achilles](https://github.com/OHDSI/Achilles) and DashboardExport.
2. Run Achilles. See [this guide](https://ohdsi.github.io/Achilles/articles/RunningAchilles.html) for detailed instructions
3. Run DashboardExport, providing the schema where the Achilles results are located.

One csv file will be written to the given output folder. This file can be uploaded to the DARWIN-EU Database Dashboard.

### Sample code
```R
#install.packages("remotes")
#remotes::install_github('ohdsi/Achilles')
#remotes::install_github('darwin-eu/DashboardExport')
library(Achilles)
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

Achilles::achilles(
    connectionDetails = connectionDetails, 
    cdmDatabaseSchema = cdmDatabaseSchema, 
    resultsDatabaseSchema = resultsDatabaseSchema, 
    outputFolder = "achilles_output"
)

DashboardExport:::dashboardExport(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    resultsDatabaseSchema = resultsDatabaseSchema,
    outputFolder = "output",
    smallCellCount = 5
)
```

## Technical description
This package runs one sql script that unions the records from the `achilles_results` and `achilles_results_dist` tables.
In addition, it adds one new analysis 5000 which contains a subset of columns from the `cdm_source` table 
(cdm_source_name, source_release_date, cdm_release_date, cdm_version, vocabulary_version).
The result from this query is written to one csv file. This combines the columns from both achilles tables.