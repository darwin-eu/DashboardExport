-- 2330	Number of descendant episode records, by episode_concept_id
INSERT INTO @results_database_schema.@results_table
SELECT
    2330 as analysis_id,
    CAST(ep.episode_concept_id AS VARCHAR(255)) AS stratum_1,
    cast(null as varchar(255)) AS stratum_2,
    cast(null as varchar(255)) as stratum_3,
    cast(null as varchar(255)) as stratum_4,
    cast(null as varchar(255)) as stratum_5,
    c.DRC as count_value
FROM @cdm_database_schema.episode ep
    JOIN (
    SELECT ca.ancestor_concept_id AS concept_id, COUNT_BIG(*) AS DRC
    FROM @cdm_database_schema.episode ep
    JOIN @cdm_database_schema.concept_ancestor ca
    ON ca.descendant_concept_id = ep.episode_concept_id
    GROUP BY ca.ancestor_concept_id
    ) c
ON c.concept_id = ep.episode_concept_id
GROUP BY ep.episode_concept_id, c.DRC
;