# DashboardExport
Export descriptive statistics from a subset of Achilles results for the DARWIN-EU Database Dashboard.
All counts are rounded up to nearest hundred and counts below the `smallCellCount` are not exported.
For an overview of the exported Achilles analyses, see [required_analysis_ids.csv](inst/csv/required_analysis_ids.csv).

Publicly available repo available on (DARWIN-EU/DashboardExport)[https://github.com/darwin-eu/DashboardExport]

## How to execute
1. Install [Achilles](https://github.com/OHDSI/Achilles) and DashboardExport.
2. Run Achilles. See [this guide](https://ohdsi.github.io/Achilles/articles/RunningAchilles.html) for detailed instructions
3. Run DashboardExport, providing the schema where the Achilles results are located.

One csv file will be written to the given output folder. This file can be uploaded to the DARWIN-EU Database Dashboard.

### Sample code
```R
if (!require(remotes)) {install.packages('remotes')}
if (!require(Achilles)) {
    remotes::install_github('OHDSI/Achilles')
}
if (!require(DashboardExport)) {
    remotes::install_github('DARWIN-EU/DashboardExport')
}

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
databaseId <- Sys.getenv("DATABASE_ID")

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
    outputFolder = "output",
    databaseId = databaseId,
    smallCellCount = 5
)
```

## Technical description
This package runs one sql script that unions the records from the `achilles_results` and `achilles_results_dist` tables.
In addition, it adds one new analysis 5000 which contains a subset of columns from the `cdm_source` table 
(cdm_source_name, source_release_date, cdm_release_date, cdm_version, vocabulary_version).
The result from this query is written to one csv file. This combines the columns from both achilles tables.

### Output structure

The output of `DashboardExport` has the following columns:

Column | Data type | Description
--- | --- | ---
analysis_id* | int | The Achilles analysis id
stratum_1 | varchar | Analysis stratified by given column
stratum_2 | varchar | Analysis stratified by given column
stratum_3 | varchar | Analysis stratified by given column
stratum_4 | varchar | Analysis stratified by given column
stratum_5 | varchar | Analysis stratified by given column
count_value* | int | The main count output
min_value | float | Minimum, for `dist`ributed analyses
max_value | float | Maximum, for `dist`ributed analyses
avg_value | float | Average, for `dist`ributed analyses
stdev_value | float | Standard deviation, for `dist`ributed analyses
median_value | float | Median, for `dist`ributed analyses
p10_value | float | 10% percentile, for `dist`ributed analyses
p25_value | float | 25% percentile, for `dist`ributed analyses
p75_value | float | 75% percentile, for `dist`ributed analyses
p90_value | float | 90% percentile, for `dist`ributed analyses

*required fields

The meaning of the `stratum` columns differs per analysis_id. Some analyses are not stratified. The stratums can be found in [required_analysis_ids.csv](inst/csv/required_analysis_ids.csv). 

The count is always given (if not below the provided smallCellCount), and is rounded up to the nearest hundred. The other numeric statistics are only given for analyses from the `achilles_results_dist` table.
