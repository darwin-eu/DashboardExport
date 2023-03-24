-- 730	Number of descendant drug exposure records, by drug_concept_id
SELECT
    730 as analysis_id,
    CAST(co.drug_concept_id AS VARCHAR(255)) AS stratum_1,
    cast(null as varchar(255)) AS stratum_2,
    cast(null as varchar(255)) as stratum_3,
    cast(null as varchar(255)) as stratum_4,
    cast(null as varchar(255)) as stratum_5,
    c.DRC as count_value
FROM @cdm_database_schema.drug_exposure co
JOIN (
    SELECT ca.ancestor_concept_id AS concept_id, COUNT_BIG(*) AS DRC
    FROM @cdm_database_schema.drug_exposure co
    JOIN @cdm_database_schema.concept_ancestor ca
        ON ca.descendant_concept_id = co.drug_concept_id
    GROUP BY ca.ancestor_concept_id
) c
    ON c.concept_id = co.drug_concept_id
GROUP BY co.drug_concept_id, c.DRC
