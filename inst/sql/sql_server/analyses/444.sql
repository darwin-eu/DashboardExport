-- 444 Descendant Person Count (DPC) of condition occurrence records, by condition_concept_id
-- This is more accurate than summing person counts of individual concepts (401), because that potentially double counts persons.
INSERT INTO @results_database_schema.@results_table
SELECT
    444 as analysis_id,
    CAST(ancestor_concept_id AS VARCHAR(255)) AS stratum_1,
    CAST(NULL AS VARCHAR(255)) AS stratum_2,
    CAST(NULL AS VARCHAR(255)) AS stratum_3,
    CAST(NULL AS VARCHAR(255)) AS stratum_4,
    CAST(NULL AS VARCHAR(255)) AS stratum_5,
    COUNT_BIG(DISTINCT person_id)  AS count_value -- dpc
FROM @cdm_database_schema.concept_ancestor
JOIN @cdm_database_schema.condition_occurrence
    ON descendant_concept_id = condition_concept_id
GROUP BY ancestor_concept_id
;