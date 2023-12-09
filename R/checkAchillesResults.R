# @file R/Achilles_checks.R
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

.checkAchillesTablesExist <- function(connectionDetails, resultsDatabaseSchema) {
  required_achilles_tables <- c("achilles_analysis", "achilles_results", "achilles_results_dist")

  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection = connection))

  achilles_tables_exist <- TRUE
  for (table in required_achilles_tables) {
    table_exists <- DatabaseConnector::existsTable(connection, resultsDatabaseSchema, table)
    if (!table_exists) {
      ParallelLogger::logWarn(
        sprintf("Achilles table '%s.%s' has not been found", resultsDatabaseSchema, table)
      )
    }
    achilles_tables_exist <- achilles_tables_exist && table_exists
  }

  return(achilles_tables_exist)
}

#' @title Get Achilles analysis ids to be exported
#' @return vector of integer analysis ids
#' @export
getAnalysisIdsToExport <- function() {
    .readRequiredAnalyses()$analysis_id
}

#' @title Get minimally required Achilles analysis ids, used in the DARWIN Database Dashboard
#' @return vector of integer analysis ids
#' At the moment not used
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
