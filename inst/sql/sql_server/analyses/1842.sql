-- 1842 Number of records by measurement_concept_id by age decile

INSERT INTO @results_database_schema.@results_table (
SELECT
    1842 AS analysis_id,
    m.measurement_concept_id AS stratum_1,
    FLOOR((YEAR(m.measurement_date) - p.year_of_birth) / 10) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.person p
JOIN @cdm_database_schema.measurement m
    ON p.person_id = m.person_id
JOIN @cdm_database_schema.observation_period op
    ON m.person_id = op.person_id
    AND m.measurement_date >= op.observation_period_start_date
    AND m.measurement_date <= op.observation_period_end_date
WHERE measurement_concept_id > 0
GROUP BY
    m.measurement_concept_id,
    FLOOR((YEAR(m.measurement_date) - p.year_of_birth) / 10)
)