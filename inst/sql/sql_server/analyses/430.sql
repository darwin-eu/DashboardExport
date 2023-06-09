-- 430	Number of descendant condition occurrence records,by condition_concept_id
INSERT INTO @results_database_schema.@results_table (
SELECT
    430 as analysis_id,
    CAST(co.CONDITION_CONCEPT_ID AS VARCHAR(255)) AS stratum_1,
    cast(null as varchar(255)) AS stratum_2,
    cast(null as varchar(255)) as stratum_3,
    cast(null as varchar(255)) as stratum_4,
    cast(null as varchar(255)) as stratum_5,
    c.DRC as count_value
FROM @cdm_database_schema.CONDITION_OCCURRENCE co
JOIN (
    SELECT ca.ANCESTOR_CONCEPT_ID AS CONCEPT_ID, COUNT_BIG(*) AS DRC
    FROM @cdm_database_schema.CONDITION_OCCURRENCE co
    JOIN @vocab_database_schema.CONCEPT_ANCESTOR ca
        ON ca.DESCENDANT_CONCEPT_ID = co.CONDITION_CONCEPT_ID
    GROUP BY ca.ANCESTOR_CONCEPT_ID
) c
    ON c.CONCEPT_ID = co.CONDITION_CONCEPT_ID
GROUP BY co.CONDITION_CONCEPT_ID, c.DRC
)
