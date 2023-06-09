-- 742 Number of records by drug_concept_id by age decile

INSERT INTO @results_database_schema.@results_table (
SELECT
    742 AS analysis_id,
    de.drug_concept_id AS stratum_1,
    FLOOR((YEAR(de.drug_exposure_start_date) - p.year_of_birth) / 10) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.person p
JOIN @cdm_database_schema.drug_exposure de
    ON p.person_id = de.person_id
JOIN @cdm_database_schema.observation_period op
    ON de.person_id = op.person_id
    AND de.drug_exposure_start_date >= op.observation_period_start_date
    AND de.drug_exposure_start_date <= op.observation_period_end_date
WHERE drug_concept_id > 0
GROUP BY
    de.drug_concept_id,
    FLOOR((YEAR(de.drug_exposure_start_date) - p.year_of_birth) / 10)
)