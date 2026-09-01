# @file getCdmSource.R
#
# Copyright 2026 Darwin EU Coordination Center
#
# This file is part of DashboardExport
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
# @author Peter Rijnbeek
# @author Maxim Moinat


#' Get CDM source table
#' @param connectionDetails                An R object of type \code{DatabaseConnectorConnectionDetails}
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM schema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param outputFolder                     Path to store logs and SQL files
#' @return                                 A data frame with the CDM source table
.getCdmSource <- function(
  connectionDetails,
  cdmDatabaseSchema
) {
  connection <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  sql_rendered <- SqlRender::render(
    "select * from @schema.cdm_source",
    schema = cdmDatabaseSchema,
    table = table
  )

  sql_translated <- SqlRender::translate(sql_rendered, targetDialect = connectionDetails$dbms)

  cdmSource <- tryCatch({
    DatabaseConnector::querySql(connection, sql_translated, snakeCaseToCamelCase = TRUE)
  }, error = function(e) {
    NULL
  })

  return(cdmSource)
}
