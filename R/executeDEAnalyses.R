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

.executeDEAnalyses <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, outputFolder, cdmVersion) {
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection), add = TRUE)
  # Create DashboardExport results table. Drop if exists.
  resultsTable <- 'dashboard_export_results'
  ParallelLogger::logInfo(sprintf('Creating results table %s.%s', resultsDatabaseSchema, resultsTable))
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
    # Skip episode queries for older cdm versions
    if (floor(analysisId / 100) == 23 && cdmVersion != '5.4') {
      ParallelLogger::logInfo(sprintf(
        "Analysis %d (%s) -- SKIPPED",
        analysisId,
        analysisDetails[analysisDetails$analysis_id == analysisId, 'description']
      ))
      next
    }
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
    })
  }
}