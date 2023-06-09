-- 831 Number of records by observation_concept_id by age decile

INSERT INTO @results_database_schema.@results_table (
SELECT
    831 AS analysis_id,
    o.observation_concept_id AS stratum_1,
    FLOOR((YEAR(ob.observation_date) - p.year_of_birth) / 10) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.person p
    JOIN @cdm_database_schema.observation o
ON p.person_id = co.person_id
    JOIN @cdm_database_schema.observation_period op
    ON co.person_id = op.person_id
    AND o.observation_date >= op.observation_period_start_date
    AND o.observation_date <= op.observation_period_end_date
WHERE observation_concept_id > 0 -- not in original 404 analysis
GROUP BY
    o.observation_concept_id,
    FLOOR((YEAR(ob.observation_date) - p.year_of_birth) / 10)
)