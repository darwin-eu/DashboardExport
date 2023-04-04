-- 442 Number of records by condition_concept_id by age decile

SELECT 
	442 AS analysis_id,
    co.condition_concept_id AS stratum_1,
    FLOOR((YEAR(co.condition_start_date) - p.year_of_birth) / 10) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(*) AS count_value
FROM @cdmDatabaseSchema.person p
JOIN @cdmDatabaseSchema.condition_occurrence co 
    ON p.person_id = co.person_id
JOIN @cdmDatabaseSchema.observation_period op 
    ON co.person_id = op.person_id
    AND co.condition_start_date >= op.observation_period_start_date
    AND co.condition_start_date <= op.observation_period_end_date
WHERE condition_concept_id > 0 -- not in original 404 analysis
GROUP BY 
    co.condition_concept_id,
    FLOOR((YEAR(co.condition_start_date) - p.year_of_birth) / 10)
