# @file executeDEAnalyses.R
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

#' exportAnalyses
#'
#' @description
#' Export Achilles and DashboardExport analysis results to a single csv file.
#'
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
#' @param smallCellCount           To avoid patient identifiability, cells with small counts
#'                                 (<= smallCellCount) are deleted. Set to NULL if you don't want any deletions.
#'                                 Default = 5.
#' @param analysis_ids             List of analysis ids to export. Default is to export all analyses.
#' @param outputFolder             Path to store logs and SQL files
#' @param databaseId               Name of the source, used in the filename exported
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms="sql server", server="your_server")
#' .executeDEAnalyses(
#'   connectionDetails = connectionDetails,
#'   cdmDatabaseSchema = cdmDatabaseSchema,
#'   resultsDatabaseSchema = resultsDatabaseSchema
#' )
#' exportResults(
#'   connectionDetails = connectionDetails,
#'   cdmDatabaseSchema = cdmDatabaseSchema,
#'   resultsDatabaseSchema = resultsDatabaseSchema,
#'   achillesDatabaseSchema = achillesDatabaseSchema,
#'   smallCellCount = smallCellCount,
#'   analysisIds = analysisIds,
#'   outputFolder = outputFolder,
#'   databaseId = databaseId
#' )
#' }
#' @export
exportResults <- function(
  connectionDetails,
  cdmDatabaseSchema,
  resultsDatabaseSchema,
  outputFolder,
  databaseId,
  achillesDatabaseSchema = resultsDatabaseSchema,
  smallCellCount = 5,
  analysisIds = getAnalysisIdsToExport()
) {
  connection <- DatabaseConnector::connect(connectionDetails)

  results <- tryCatch({
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

    ParallelLogger::logInfo("Exporting achilles_results, achilles_results_dist and dashboard_export_results...")
    DatabaseConnector::querySql(
      connection = connection,
      sql = sql
    )
  }, error = function(e) {
    ParallelLogger::logError("Export query was not executed successfully")
    ParallelLogger::logError(e)
    NULL
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
    NULL
  })

  if (is.null(results)) {
    return(NULL)
  }

  # Save the data to the export folder
  outputPath <- file.path(
    outputFolder,
    sprintf("dashboard_export_%s_%s.csv", databaseId, format(Sys.time(), "%Y%m%d"))
  )
  readr::write_csv(results, outputPath)
  ParallelLogger::logInfo(sprintf("Results written to %s", outputPath))

  # Debugging for export format
  print(
    results[results['ANALYSIS_ID'] == '5000', ]
  )
  print(
    results[results['ANALYSIS_ID'] == '206', ]
  )

  utils::write.table(
    results,
    file.path(
      outputFolder,
      sprintf("dashboard_export_%s_%s_utils_write.csv", databaseId, format(Sys.time(), "%Y%m%d"))
    ),
    quote = FALSE,
    sep = ",",
    dec = ".",
    row.names = FALSE
  )

  invisible()
}