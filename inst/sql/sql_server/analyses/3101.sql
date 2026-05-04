-- 3101 Number of records by pregnancy outcome
INSERT INTO @results_database_schema.@results_table
SELECT 
	3101 AS analysis_id,
	CAST(pet.pregnancy_outcome AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(pet.person_id) AS count_value
FROM 
	@cdm_database_schema.pregnancy pet
-- JOIN 
-- 	@cdm_database_schema.observation_period op 
-- ON 
-- 	pet.person_id = op.person_id
-- AND 
-- 	pet.pregnancy_start_date >= op.observation_period_start_date
-- AND 
-- 	pet.pregnancy_start_date <= op.observation_period_end_date
GROUP BY 
	pet.pregnancy_outcome;