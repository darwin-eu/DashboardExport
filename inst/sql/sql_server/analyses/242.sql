-- 242 Number of records by visit_concept_id by age decile
INSERT INTO @results_database_schema.@results_table (
SELECT
	242 AS analysis_id,
    vo.visit_concept_id AS stratum_1,
    FLOOR((YEAR(vo.visit_start_date) - p.year_of_birth) / 10) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.person p
JOIN @cdm_database_schema.visit_occurrence vo
    ON p.person_id = vo.person_id
JOIN @cdm_database_schema.observation_period op
    ON vo.person_id = op.person_id
    AND vo.visit_start_date >= op.observation_period_start_date
    AND vo.visit_start_date <= op.observation_period_end_date
WHERE visit_concept_id != 0
GROUP BY
    vo.visit_concept_id,
    FLOOR((YEAR(vo.visit_start_date) - p.year_of_birth) / 10)
)