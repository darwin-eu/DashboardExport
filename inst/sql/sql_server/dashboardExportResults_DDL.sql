-- DDLs FOR THE RESULTS Table

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


IF OBJECT_ID('@results_database_schema.@results_table_dist', 'U') IS NOT NULL
  DROP TABLE @results_database_schema.@results_table_dist;
  
CREATE TABLE @results_database_schema.@results_table_dist (
	analysis_id     BIGINT,
	stratum_1_name  VARCHAR(255),
	stratum_2_name  VARCHAR(255),
	stratum_3_name  VARCHAR(255),
	stratum_4_name  VARCHAR(255),
	stratum_5_name  VARCHAR(255),
	count_value     BIGINT,
  min_value       FLOAT,
  max_value       FLOAT,
  avg_value       FLOAT,
  stdev_value     FLOAT,
  p10_value       FLOAT,
  p25_value       FLOAT,
  median_value    FLOAT,
  p75_value       FLOAT,
  p90_value       FLOAT
);