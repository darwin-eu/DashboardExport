-- 3154 Number of pregnancies with linked children
INSERT INTO @results_database_schema.@results_table
SELECT 
	3154 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT(DISTINCT pregnancy_id) AS count_value
FROM
	@cdm_database_schema.infant
;