-- 642 Number of records by procedure_concept_id by age decile

INSERT INTO @results_database_schema.@results_table (
SELECT
    642 AS analysis_id,
    po.procedure_concept_id AS stratum_1,
    FLOOR((YEAR(po.procedure_date) - p.year_of_birth) / 10) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.person p
JOIN @cdm_database_schema.procedure_occurrence po
    ON p.person_id = po.person_id
JOIN @cdm_database_schema.observation_period op
    ON po.person_id = op.person_id
    AND po.procedure_date >= op.observation_period_start_date
    AND po.procedure_date <= op.observation_period_end_date
WHERE procedure_concept_id != 0
GROUP BY
    po.procedure_concept_id,
    FLOOR((YEAR(po.procedure_date) - p.year_of_birth) / 10)
)