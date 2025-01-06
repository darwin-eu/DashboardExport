-- Number of records per fact_relationship.relationship_concept_id
INSERT INTO @results_database_schema.@results_table
SELECT 
	3001 AS analysis_id,
	fr.relationship_concept_id AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.fact_relationship fr
GROUP BY fr.relationship_concept_id;