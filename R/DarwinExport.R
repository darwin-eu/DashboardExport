# @file CatalogueExport
#
# Copyright 2023 DARWIN-EU (R)
#
# This file is part of CatalogueExport and is based on OHDSI's Achilles
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
# @author DARWIN-EU (R)
# @author Maxim Moinat


#' The main CatalogueExport analyses (for v5.x)
#'
#' @description
#' \code{CatalogueExport} exports a set of  descriptive statistics summary from the CDM, to be uploaded in the Database Catalogue.
#'
#' @details
#' \code{CatalogueExport} exports a set of  descriptive statistics summary from the CDM, to be uploaded in the Database Catalogue.
#'
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM schema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema. 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param scratchDatabaseSchema            Fully qualified name of the database schema that will store all of the intermediate scratch tables, so for example, on SQL Server, 'cdm_scratch.dbo'. 
#'                                         Must be accessible to/from the cdmDatabaseSchema and the resultsDatabaseSchema. Default is resultsDatabaseSchema. 
#'                                         Making this "#" will run CatalogueExport in single-threaded mode and use temporary tables instead of permanent tables.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param oracleTempSchema                 For Oracle only: the name of the database schema where you want all temporary tables to be managed. Requires create/insert permissions to this database. 
#' @param sourceName		                   String name of the data source name. If blank, CDM_SOURCE table will be queried to try to obtain this.
#' @param analysisIds		                   (OPTIONAL) A vector containing the set of CatalogueExport analysisIds for which results will be generated. 
#'                                         If not specified, all analyses will be executed. Use \code{\link{getAnalysisDetails}} to get a list of all CatalogueExport analyses and their Ids.
#' @param createTable                      If true, new results tables will be created in the results schema. If not, the tables are assumed to already exist, and analysis results will be inserted (slower on MPP).
#' @param smallCellCount                   To avoid patient identifiability, cells with small counts (<= smallCellCount) are deleted. Set to NULL if you don't want any deletions.
#' @param cdmVersion                       Define the OMOP CDM version used:  currently supports v5 and above. Use major release number or minor number only (e.g. 5, 5.3)
#' @param createIndices                    Boolean to determine if indices should be created on the resulting CatalogueExport tables. Default= TRUE
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run CatalogueExport in parallel. Default is 1 thread.
#' @param tempPrefix                       (OPTIONAL, multi-threaded mode) The prefix to use for the scratch CatalogueExport analyses tables. Default is "tmpach"
#' @param dropScratchTables                (OPTIONAL, multi-threaded mode) TRUE = drop the scratch tables (may take time depending on dbms), FALSE = leave them in place for later removal.
#' @param sqlOnly                          Boolean to determine if CatalogueExport should be fully executed. TRUE = just generate SQL files, don't actually run, FALSE = run CatalogueExport
#' @param outputFolder                     Path to store logs and SQL files
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE
#' @return                                 An object of type \code{catalogueResults} containing details for connecting to the database containing the results 
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms="sql server", server="some_server")
#' results <- achilles(connectionDetails = connectionDetails,
#'                     cdmDatabaseSchema = "cdm",
#'                     resultsDatabaseSchema="results",
#'                     scratchDatabaseSchema="scratch",
#'                     sourceName="Some Source",
#'                     cdmVersion = "5.3",
#'                     numThreads = 10,
#'                     outputFolder = "output")
#' }
#' @export
darwinExport <- function(
    connectionDetails,
    cdmDatabaseSchema,
    resultsDatabaseSchema,
    vocabDatabaseSchema = cdmDatabaseSchema,
    analysisIds = NULL,
    createTable = TRUE,
    smallCellCount = 5,
    sqlOnly = FALSE,
    outputFolder = "output",
    verboseMode = TRUE)
{
    # Simple export of Achilles results to one csv for processing by the database Catalogue
    # Rounds counts up to the nearest hundred, removes small cell counts.

    # TODO:
    # - provide with list of required analysis_ids
    # - test with Catalogue import

    # Log execution ----------------------------------------
    ParallelLogger::clearLoggers()
    unlink(file.path(outputFolder, "log_catalogueExport.txt"))

    if (verboseMode) {
        appenders <- list(
            ParallelLogger::createConsoleAppender(),
            ParallelLogger::createFileAppender(
                layout = ParallelLogger::layoutParallel,
                fileName = file.path(outputFolder, "log_catalogueExport.txt")
            )
        )
    } else {
        appenders <- list(
            ParallelLogger::createFileAppender(
                layout = ParallelLogger::layoutParallel,
                fileName = file.path(outputFolder, "log_catalogueExport.txt")
            )
        )
    }

    logger <- ParallelLogger::createLogger(
        name = "catalogueExport",
        threshold = "INFO",
        appenders = appenders
    )
    ParallelLogger::registerLogger(logger)

    # Ensure the export folder exists
    if (!file.exists(outputFolder)) {
        dir.create(outputFolder, recursive = TRUE)
    }

    # Export achilles results to one csv
    connection <- DatabaseConnector::connect(connectionDetails)
    tryCatch({
            # Obtain the data from the results tables
            sql <- SqlRender::loadRenderTranslateSql(
                sqlFilename = "export.sql",
                packageName = "DarwinExport",
                dbms = connectionDetails$dbms,
                warnOnMissingParameters = FALSE,
                results_database_schema = resultsDatabaseSchema,
                min_cell_count = smallCellCount,
                analysis_ids = analysisIds
            )
            ParallelLogger::logInfo("Exporting achilles_results and achilles_results_dist")
            results <- DatabaseConnector::querySql(
                connection = connection,
                sql = sql
            )

            # Save the data to the export folder
            outputPath <- file.path(outputFolder, sprintf("catalogue_results-%s.csv", Sys.Date()))
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
}