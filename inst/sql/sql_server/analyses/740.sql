-- 740	Number of drug occurrence records, by route_concept_id
INSERT INTO @results_database_schema.@results_table (
SELECT 
    740 AS analysis_id,
    CAST(de.route_concept_id AS VARCHAR(255)) AS stratum_1,
    CAST(NULL AS VARCHAR(255)) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(*) AS count_value
FROM 
    @cdm_database_schema.drug_exposure de
JOIN @cdm_database_schema.observation_period op 
    ON de.person_id = op.person_id
    AND de.drug_exposure_start_date >= op.observation_period_start_date
    AND de.drug_exposure_start_date <= op.observation_period_end_date
GROUP BY de.route_concept_id
)