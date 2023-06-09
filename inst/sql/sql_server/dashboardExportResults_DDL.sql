
-- DDL FOR THE RESULTS Table

IF OBJECT_ID('@results_database_schema.@results_table', 'U') IS NOT NULL
  DROP TABLE @results_database_schema.@results_table;
  
CREATE TABLE @results_database_schema.@results_table (
	analysis_id     BIGINT,
	stratum_1_name  VARCHAR(255),
	stratum_2_name  VARCHAR(255),
	stratum_3_name  VARCHAR(255),
	stratum_4_name  VARCHAR(255),
	stratum_5_name  VARCHAR(255),
	count_value     BIGINT
);