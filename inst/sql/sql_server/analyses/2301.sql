-- 2301 Number of episode records, by episode_concept_id

INSERT INTO @results_database_schema.@results_table
SELECT 
	2301 AS analysis_id,
	CAST(ep.episode_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(ep.person_id) AS count_value
FROM 
	@cdm_database_schema.episode ep
JOIN 
	@cdm_database_schema.observation_period op 
ON 
	ep.person_id = op.person_id
AND 
	ep.episode_start_date >= op.observation_period_start_date
AND 
	ep.episode_start_date <= op.observation_period_end_date
GROUP BY 
	ep.episode_concept_id;