-- 2305 Number of episode records, by episode_concept_id by episode_type_concept_id

INSERT INTO @results_database_schema.@results_table
SELECT 
	2305 AS analysis_id,
	CAST(ep.episode_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(ep.episode_type_concept_id AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(po.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.episode ep
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	ep.person_id = op.person_id
AND 
	ep.episode_start_date >= op.observation_period_start_date
AND 
	ep.episode_start_date <= op.observation_period_end_date
GROUP BY 
	ep.episode_concept_id,
	ep.episode_type_concept_id
;
