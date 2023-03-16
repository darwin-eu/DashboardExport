-- 741 Number of drug exposure records, by drug_concept_id by route_concept_id
SELECT 
    741 AS analysis_id,
    CAST(de.drug_concept_id AS VARCHAR(255)) AS stratum_1,
    CAST(de.route_concept_id AS VARCHAR(255)) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(de.person_id) AS count_value
FROM 
    @cdm_database_schema.drug_exposure de
JOIN 
    @cdm_database_schema.observation_period op 
    ON de.person_id = op.person_id
    AND de.drug_exposure_start_date >= op.observation_period_start_date
    AND de.drug_exposure_start_date <= op.observation_period_end_date
    GROUP BY 
        de.drug_concept_id,
        de.route_concept_id