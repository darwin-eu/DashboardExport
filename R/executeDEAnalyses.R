# @file executeDEAnalyses.R
#
# Copyright 2026 Darwin EU Coordination Center
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
  # Recreate results tables
  .createDEResultsTables(connectionDetails, resultsDatabaseSchema)

  # Select DashboardExport Analyses
  analysisDetails <- .readRequiredAnalyses()
  analysesIdsToExecute <- analysisDetails[analysisDetails$source %in% c('custom', 'custom_dist'), 'analysis_id']

  # Skip episode queries for older cdm versions
  if (compareVersion(cdmVersion, '5.4') == -1) {
    ParallelLogger::logInfo("Skipping episode analyses as CDM version is older than 5.4.")
    analysesIdsToExecute <- analysesIdsToExecute[floor(analysesIdsToExecute / 100) != 23]    
  }

  # Skip PET queries if pregnancy table not found
  if (!.checkPregnancyTableExists(connectionDetails, cdmDatabaseSchema)) {
    ParallelLogger::logInfo("Skippping PET analyses as pregnancy table not found in CDM database.")
    analysesIdsToExecute <- analysesIdsToExecute[floor(analysesIdsToExecute / 100) != 31]
  }
  
  # Execute DashboardExport Analyses
  ParallelLogger::logInfo(sprintf('Starting execution of %d DashboardExport analyses, writing to %s.%s and %s.%s', length(analysesIdsToExecute), resultsDatabaseSchema, resultsTable, resultsDatabaseSchema, resultsTableDist))
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection), add = TRUE)

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
      results_database_schema = resultsDatabaseSchema,
      results_table = resultsTable,
      results_table_dist = resultsTableDist,
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

#' Create DashboardExport results tables. Drop if exists.
.createDEResultsTables <- function(connectionDetails, resultsDatabaseSchema) {
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection), add = TRUE)

  # Assign in parent environment so that it can be used in .executeDEAnalyses
  resultsTable <<- 'dashboard_export_results'
  resultsTableDist <<- paste0(resultsTable, '_dist')
  ParallelLogger::logInfo(sprintf('Creating results table %s.%s and %s.%s', resultsDatabaseSchema, resultsTable, resultsDatabaseSchema, resultsTableDist))
  ddl_sql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = 'dashboardExportResults_DDL.sql',
    packageName = "DashboardExport",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    results_table = resultsTable,
    results_table_dist = resultsTableDist
  )

  DatabaseConnector::executeSql(
    connection = connection,
    sql = ddl_sql,
    errorReportFile = "dashboardExportError_ddl.txt",
    progressBar = FALSE,
    reportOverallTime = FALSE
  )
}

#' Check if PET tables exist in the CDM database
.checkPregnancyTableExists <- function(connectionDetails, cdmDatabaseSchema) {
  connection <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  tryCatch({
    DatabaseConnector::querySql(
      connection, 
      SqlRender::render("SELECT * FROM @cdmDatabaseSchema.pregnancy", cdmDatabaseSchema = cdmDatabaseSchema)
    )
    return(TRUE)
  }, error = function(e) {
    return(FALSE)
  })
}
