# @file DashboardExport
#
# Copyright 2023 Darwin EU Coordination Center
#
# This file is part of the DashboardExport package
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Darwin EU Coordination Center
# @author Maxim Moinat


#' dashboardExport
#'
#' @description
#' \code{dashboardExport} exports a set of descriptive statistics summary from the CDM,
#' to be uploaded in the Database Dashboard.
#'
#' @details
#' \code{dashboardExport} exports the results from Achilles, stored in the achilles_results
#' and achilles_results_dist tables, to a single csv file.
#' This csv file can be uploaded to the Database Dashboard entry in the DARWIN-EU(R) Portal.
#' There are two measures to prevent sharing of too detailed information:
#' 1. all counts are rounded up to the nearest hundred.
#' 2. a small cell count is applied and counts smaller than this record are omitted (default=5)
#' This is a light-weight version of the EHDEN CatalogueExport, where the Achilles analyses were rerun.
#'
#' @param connectionDetails        An R object of type \code{connectionDetails} created using the function
#'                                 \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	   Fully qualified name of database schema that contains OMOP CDM schema.
#'                                 On SQL Server, this should specifiy both the database and the schema,
#'                                 so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema	   Fully qualified name of database schema that we can write results to.
#'                                 On SQL Server, this should specifiy both the database and the schema,
#'                                 so for example, on SQL Server, 'cdm_results.dbo'.
#' @param achillesDatabaseSchema   (OPTIONAL) Fully qualified name of database schema where the Achilles results
#'                                 tables can be found (achilles_results, achilles_results_dist).
#'                                 On SQL Server, this should specifiy both the database and the schema,
#'                                 so for example, on SQL Server, 'cdm_results.dbo'.
#' @param vocabDatabaseSchema	   (OPTIONAL) String name of database schema that contains OMOP Vocabulary.
#'                                 On SQL Server, this should specifiy both the database and the schema,
#'                                 so for example 'results.dbo'.
#'                                 Default = \code{cdmDatabaseSchema}.
#' @param smallCellCount           To avoid patient identifiability, cells with small counts
#'                                 (<= smallCellCount) are deleted. Set to NULL if you don't want any deletions.
#'                                 Default = 5.
#' @param outputFolder             Path to store logs and SQL files
#' @param databaseId               Name of the source, used in the filename exported
#' @param verboseMode              Boolean to determine if the console will show all execution steps. Default = TRUE
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms="sql server", server="some_server")
#' # Run Achilles
#' results <- dashboardExport(
#'      connectionDetails = connectionDetails,
#'      cdmDatabaseSchema = "cdm",
#'      resultsDatabaseSchema = "results",
#'      outputFolder = "output",
#'      databaseId = "MyName"
#' )
#' }
#' @export
dashboardExport <- function(
    connectionDetails,
    cdmDatabaseSchema,
    resultsDatabaseSchema,
    achillesDatabaseSchema = resultsDatabaseSchema,
    vocabDatabaseSchema = cdmDatabaseSchema,
    smallCellCount = 5,
    outputFolder = "output",
    databaseId = NULL,
    verboseMode = TRUE
) {
    # Setup logging
    ParallelLogger::clearLoggers()

    ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log_dashboardExport.txt"))
    ParallelLogger::addDefaultErrorReportLogger(file.path(outputFolder, "errorReportR.txt"))
    on.exit(ParallelLogger::unregisterLogger("DEFAULT_FILE_LOGGER", silent = TRUE))
    on.exit(ParallelLogger::unregisterLogger("DEFAULT_ERRORREPORT_LOGGER", silent = TRUE), add = TRUE)

    if (verboseMode) {
        ParallelLogger::registerLogger(
            ParallelLogger::createLogger(
                name = "DEFAULT_CONSOLE_LOGGER",
                threshold = "INFO",
                appenders = list(ParallelLogger::createConsoleAppender(layout = ParallelLogger::layoutTimestamp))
            )
        )
        on.exit(ParallelLogger::unregisterLogger("DEFAULT_CONSOLE_LOGGER"), add = TRUE)
    }

    ParallelLogger::logInfo(sprintf("Checking that Achilles results are available in schema '%s'", achillesDatabaseSchema))
    if (!.checkAchillesTablesExist(connectionDetails, achillesDatabaseSchema)) {
        ParallelLogger::logError("The output from the Achilles analyses is required.")
        ParallelLogger::logInfo(sprintf(
            "Please run Achilles first and make sure the resulting Achilles tables are in the given results schema ('%s').", # nolint
            achillesDatabaseSchema)
        )
        return(NULL)
    }

    # Check whether results for required Achilles analyses is available.
    # At least require person, obs. period, condition and drug exposure. Other domains can be empty.
    expectedAnalysisIds <- c(0, 1, 2, 3, 101, 102, 103, 105, 108, 110, 111, 112, 113, 117, 400, 401, 403, 405, 420, 700, 701, 703, 705, 720)
    analysisIdsAvailable <- .getAvailableAchillesAnalysisIds(connectionDetails, achillesDatabaseSchema)
    missingAnalysisIds <- setdiff(expectedAnalysisIds, analysisIdsAvailable)
    if (length(missingAnalysisIds) > 0) {
        ParallelLogger::logError(
            sprintf("Missing Achilles analysis ids in result tables: %s.",
            paste(missingAnalysisIds, collapse = ", "))
        )
        ParallelLogger::logInfo("Please rerun Achilles including above analyses.")
        return(NULL)
    }

    # Display Achilles metadata
    achillesMetadata <- .getAchillesMetadata(connectionDetails, achillesDatabaseSchema)
    ParallelLogger::logInfo(sprintf(
        "Achilles v%s results found. Executed on %s for '%s' (n=%dk).",
        achillesMetadata$ACHILLES_VERSION,
        achillesMetadata$ACHILLES_EXECUTION_DATE,
        achillesMetadata$ACHILLES_SOURCE_NAME,
        achillesMetadata$PERSON_COUNT_THOUSANDS
    ))

    # Create the export folder if it does not exist
    if (!file.exists(outputFolder)) {
        dir.create(outputFolder, recursive = TRUE)
    }

    if (is.null(databaseId)) {
        databaseId <- .getSourceName(connectionDetails, cdmDatabaseSchema)
    }

    .executeDasbhoardExportAnalyses(
        connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        vocabDatabaseSchema = vocabDatabaseSchema,
        resultsDatabaseSchema = resultsDatabaseSchema
    )

    analysisIds <- getAnalysisIdsToExport()

    # Query and write achilles results
    connection <- DatabaseConnector::connect(connectionDetails)
    tryCatch({
            # Obtain the data from the results tables
            sql <- SqlRender::loadRenderTranslateSql(
                sqlFilename = "export.sql",
                packageName = "DashboardExport",
                dbms = connectionDetails$dbms,
                results_database_schema = resultsDatabaseSchema,
                achilles_database_schema = achillesDatabaseSchema,
                min_cell_count = smallCellCount,
                analysis_ids = analysisIds,
                de_results_table = 'dashboard_export_results',
                package_version = utils::packageVersion(pkg = "DashboardExport")
            )
            ParallelLogger::logInfo("Exporting achilles_results and achilles_results_dist...")
            results <- DatabaseConnector::querySql(
                connection = connection,
                sql = sql
            )

            # Save the data to the export folder
            outputPath <- file.path(
                outputFolder,
                sprintf("dashboard_export_%s_%s.csv", databaseId, format(Sys.time(), "%Y%m%d"))
            )
            readr::write_csv(results, outputPath)
            ParallelLogger::logInfo(sprintf("Results written to %s", outputPath))
        },
        error = function(e) {
            ParallelLogger::logError("Export query was not executed successfully")
            ParallelLogger::logError(e)
        },
        finally = {
            DatabaseConnector::disconnect(connection = connection)
            rm(connection)
        }
    )
    invisible()
}

.checkAchillesTablesExist <- function(connectionDetails, resultsDatabaseSchema) {
  requiredAchillesTables <- c("achilles_analysis", "achilles_results", "achilles_results_dist")
  achillesTablesExist <- tryCatch({
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    for (table in requiredAchillesTables) {
      sql <- SqlRender::translate(
               SqlRender::render(
                 "SELECT COUNT(*) FROM @resultsDatabaseSchema.@table",
                 resultsDatabaseSchema = resultsDatabaseSchema,
                 table = table
               ),
               targetDialect = "postgresql"
             )
      DatabaseConnector::executeSql(
        connection = connection,
        sql = sql,
        progressBar = FALSE,
        reportOverallTime = FALSE
      )
    }
    TRUE
  },
  error = function(e) {
    FALSE
  },
  finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })
  return(achillesTablesExist)
}

#' @title Get Achilles analysis ids to be exported
#' @return vector of integer analysis ids
#' @export
getAnalysisIdsToExport <- function() {
    .readRequiredAnalyses()$analysis_id
}

#' @title Get minimally required Achilles analysis ids, used in the DARWIN Database Dashboard
#' @return vector of integer analysis ids
#' @export
getRequiredAnalysisIds <- function() {
    df <- .readRequiredAnalyses()
    df[df$used_in_dashboard_materialized_view != "", 'analysis_id']
}

.readRequiredAnalyses <- function() {
    utils::read.csv(
        file = system.file("csv", "required_analysis_ids.csv", package = "DashboardExport"),
        stringsAsFactors = FALSE
    )
}

.getAvailableAchillesAnalysisIds <- function(connectionDetails, resultsDatabaseSchema) {
    sql <- SqlRender::loadRenderTranslateSql(
        sqlFilename = "getAchillesAnalyses.sql",
        packageName = "DashboardExport",
        dbms = connectionDetails$dbms,
        results_database_schema = resultsDatabaseSchema
    )

    connection <- DatabaseConnector::connect(connectionDetails)
    result <- tryCatch({
            DatabaseConnector::querySql(
                connection = connection,
                sql = sql
            )
        },
        error = function(e) {
            ParallelLogger::logError("Could not get available achilles analyses")
            ParallelLogger::logError(e)
        },
        finally = {
            DatabaseConnector::disconnect(connection = connection)
            rm(connection)
        }
    )
    result$ANALYSIS_ID
}

.getAchillesMetadata <- function(connectionDetails, resultsDatabaseSchema) {
   sql <- SqlRender::loadRenderTranslateSql(
        sqlFilename = "getAchillesMetadata.sql",
        packageName = "DashboardExport",
        dbms = connectionDetails$dbms,
        results_database_schema = resultsDatabaseSchema
    )

    connection <- DatabaseConnector::connect(connectionDetails)
    tryCatch({
            DatabaseConnector::querySql(
                connection = connection,
                sql = sql
            )
        },
        error = function(e) {
            ParallelLogger::logError("Could not get Achilles metadata.")
            ParallelLogger::logError(e)
        },
        finally = {
            DatabaseConnector::disconnect(connection = connection)
            rm(connection)
        }
    )
}

.getSourceName <- function(connectionDetails, cdmDatabaseSchema) {
  sql <- SqlRender::render(
    sql = "select cdm_source_name from @cdmDatabaseSchema.cdm_source",
    cdmDatabaseSchema = cdmDatabaseSchema
  )
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sourceName <- tryCatch({
    s <- DatabaseConnector::querySql(connection = connection, sql = sql)
    s[1, ]
  }, error = function(e) {
    ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })
  sourceName
}

.executeDasbhoardExportAnalyses <- function(connectionDetails, cdmDatabaseSchema, vocabDatabaseSchema, resultsDatabaseSchema) {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection), add = TRUE)

    # Create DashboardExport results table. Drop if exists.
    resultsTable <- 'dashboard_export_results'
    ddl_sql <- SqlRender::loadRenderTranslateSql(
        sqlFilename = 'dashboardExportResults_DDL.sql',
        packageName = "DashboardExport",
        dbms = connectionDetails$dbms,
        results_database_schema = resultsDatabaseSchema,
        results_table = resultsTable
    )

    DatabaseConnector::executeSql(
        connection = connection,
        sql = ddl_sql,
        errorReportFile = file.path(
            outputFolder,
            paste0("dashboardExportError_ddl.txt")
        ),
        progressBar = FALSE,
        reportOverallTime = FALSE
    )
    ParallelLogger::logInfo(sprintf('Executing DashboardExport analyses, writing to %s.%s', resultsDatabaseSchema, resultsTable))

    # Execute DashboardExport Analyses
    analysisDetails <- .readRequiredAnalyses()
    analysesIdsToExecute <- analysisDetails[analysisDetails$source == 'custom', 'analysis_id']
    for (analysisId in analysesIdsToExecute) {
        ParallelLogger::logInfo(sprintf(
            "Analysis %d (%s) -- START",
            analysisId,
            analysisDetails[analysisDetails$analysis_id == analysisId, 'description']
        ))

        sql <- SqlRender::loadRenderTranslateSql(
            sqlFilename = file.path('analyses', paste(analysisId, "sql", sep = ".")),
            packageName = "DashboardExport",
            dbms = connectionDetails$dbms,
            cdm_database_schema = cdmDatabaseSchema,
            vocab_database_schema = vocabDatabaseSchema,
            results_database_schema = resultsDatabaseSchema,
            results_table = resultsTable,
            warnOnMissingParameters = FALSE
        )

        tryCatch({
                DatabaseConnector::executeSql(
                    connection = connection,
                    sql = sql,
                    errorReportFile = file.path(
                        outputFolder,
                        paste0("dashboardExportError_", analysisId, ".txt")
                    )
                )
            }, error = function(e) {
                ParallelLogger::logError(sprintf("Analysis %d -- ERROR %s", analysisId, e))
            }
        )
    }
}