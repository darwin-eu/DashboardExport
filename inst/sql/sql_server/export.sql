-- Export achilles results
-- Combines regular and _dist results into one output.
-- Adds package-specific analyses 0,430,630,730,830,1830,2130,5000

SELECT 
    analysis_id,
    stratum_1,
    stratum_2,
    stratum_3,
    stratum_4,
    stratum_5,
    floor((count_value+99)/100)*100 as count_value,
    cast(null as float) min_value,
    cast(null as float) max_value,
    cast(null as float) avg_value,
    cast(null as float) stdev_value,
    cast(null as float) median_value,
    cast(null as float) p10_value,
    cast(null as float) p25_value,
    cast(null as float) P75_value,
    cast(null as float) p90_value
FROM (
    SELECT 
    CASE 
        WHEN analysis_id in (430,630,730,830,1830,2130) THEN analysis_id + 10 
        ELSE analysis_id 
    END as analysis_id,
    stratum_1,
    stratum_2,
    stratum_3,
    stratum_4,
    stratum_5,
    count_value
    FROM @results_database_schema.achilles_results
    WHERE analysis_id != 0

    UNION ALL

    select 
        0 as analysis_id,  
        stratum_1 as stratum_1, -- Achilles source name
        CAST('@package_version' AS VARCHAR(255)) as stratum_2, 
        CONVERT(VARCHAR,GETDATE(),112) as stratum_3,
        stratum_2 as stratum_4, -- Achilles version
        stratum_3 as stratum_5, -- Achilles execution date
        count_value as count_value -- Achilles distinct person count
    from @results_database_schema.achilles_results
    where analysis_id = 0

    UNION ALL

    -- 430	Number of descendant condition occurrence records,by condition_concept_id
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
        JOIN @cdm_database_schema.CONCEPT_ANCESTOR ca
            ON ca.DESCENDANT_CONCEPT_ID = co.CONDITION_CONCEPT_ID
        GROUP BY ca.ANCESTOR_CONCEPT_ID
    ) c
        ON c.CONCEPT_ID = co.CONDITION_CONCEPT_ID
    GROUP BY co.CONDITION_CONCEPT_ID, c.DRC

    UNION ALL

    -- 630	Number of descendant procedure occurrence records, by procedure_concept_id
    SELECT
        630 as analysis_id,
        CAST(co.procedure_concept_id AS VARCHAR(255)) AS stratum_1,
        cast(null as varchar(255)) AS stratum_2,
        cast(null as varchar(255)) as stratum_3,
        cast(null as varchar(255)) as stratum_4,
        cast(null as varchar(255)) as stratum_5,
        c.DRC as count_value
    FROM @cdm_database_schema.procedure_occurrence co
    JOIN (
        SELECT ca.ancestor_concept_id AS concept_id, COUNT_BIG(*) AS DRC
        FROM @cdm_database_schema.procedure_occurrence co
        JOIN @cdm_database_schema.concept_ancestor ca
            ON ca.descendant_concept_id = co.procedure_concept_id
        GROUP BY ca.ancestor_concept_id
    ) c
        ON c.concept_id = co.procedure_concept_id
    GROUP BY co.procedure_concept_id, c.DRC

    UNION ALL

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

    UNION ALL

    -- 830	Number of descendant observation occurrence records, by observation_concept_id
    SELECT
        830 as analysis_id,
        CAST(co.observation_concept_id AS VARCHAR(255)) AS stratum_1,
        cast(null as varchar(255)) AS stratum_2,
        cast(null as varchar(255)) as stratum_3,
        cast(null as varchar(255)) as stratum_4,
        cast(null as varchar(255)) as stratum_5,
        c.DRC as count_value
    FROM @cdm_database_schema.observation co
    JOIN (
        SELECT ca.ancestor_concept_id AS concept_id, COUNT_BIG(*) AS DRC
        FROM @cdm_database_schema.observation co
        JOIN @cdm_database_schema.concept_ancestor ca
            ON ca.descendant_concept_id = co.observation_concept_id
        GROUP BY ca.ancestor_concept_id
    ) c
        ON c.concept_id = co.observation_concept_id
    GROUP BY co.observation_concept_id, c.DRC

    UNION ALL

    -- 1830	Number of descendant measurement occurrence records, by measurement_concept_id
    SELECT
        1830 as analysis_id,
        CAST(co.measurement_concept_id AS VARCHAR(255)) AS stratum_1,
        cast(null as varchar(255)) AS stratum_2,
        cast(null as varchar(255)) as stratum_3,
        cast(null as varchar(255)) as stratum_4,
        cast(null as varchar(255)) as stratum_5,
        c.DRC as count_value
    FROM @cdm_database_schema.measurement co
    JOIN (
        SELECT ca.ancestor_concept_id AS concept_id, COUNT_BIG(*) AS DRC
        FROM @cdm_database_schema.measurement co
        JOIN @cdm_database_schema.concept_ancestor ca
            ON ca.descendant_concept_id = co.measurement_concept_id
        GROUP BY ca.ancestor_concept_id
    ) c
        ON c.concept_id = co.measurement_concept_id
    GROUP BY co.measurement_concept_id, c.DRC

    UNION ALL

    -- 2130	Number of descendant device exposure records, by device_concept_id
    SELECT
        2130 as analysis_id,
        CAST(co.device_concept_id AS VARCHAR(255)) AS stratum_1,
        cast(null as varchar(255)) AS stratum_2,
        cast(null as varchar(255)) as stratum_3,
        cast(null as varchar(255)) as stratum_4,
        cast(null as varchar(255)) as stratum_5,
        c.DRC as count_value
    FROM @cdm_database_schema.device_exposure co
    JOIN (
        SELECT ca.ancestor_concept_id AS concept_id, COUNT_BIG(*) AS DRC
        FROM @cdm_database_schema.device_exposure co
        JOIN @cdm_database_schema.concept_ancestor ca
            ON ca.descendant_concept_id = co.device_concept_id
        GROUP BY ca.ancestor_concept_id
    ) c
        ON c.concept_id = co.device_concept_id
    GROUP BY co.device_concept_id, c.DRC
) ar
WHERE count_value > @min_cell_count 
    AND analysis_id < 2000000 -- exclude timings
    {@analysis_ids != ''} ? {AND analysis_id IN (@analysis_ids)}

UNION ALL

-- DarwinExport specific analysis
SELECT 
    5000 as analysis_id,  
    cdm_source_name as stratum_1, 
    cast(source_release_date as varchar) as stratum_2, 
    cast(cdm_release_date as varchar) as stratum_3, 
    cdm_version as stratum_4,
    vocabulary_version as stratum_5, 
    -1 as count_value,
    cast(null as float) min_value,
    cast(null as float) max_value,
    cast(null as float) avg_value,
    cast(null as float) stdev_value,
    cast(null as float) median_value,
    cast(null as float) p10_value,
    cast(null as float) p25_value,
    cast(null as float) P75_value,
    cast(null as float) p90_value
FROM @cdm_database_schema.cdm_source

UNION ALL

select
    analysis_id,
    stratum_1,
    stratum_2,
    stratum_3,
    stratum_4,
    stratum_5,
    floor((count_value+99)/100)*100 as count_value,
    min_value,
    max_value,
    avg_value,
    stdev_value,
    median_value,
    p10_value,
    p25_value,
    P75_value,
    p90_value
FROM @results_database_schema.achilles_results_dist
WHERE count_value > @min_cell_count 
    AND analysis_id > 0 -- otherwise analysis_id 0 duplicated
    AND analysis_id < 2000000 -- exclude timings
{@analysis_ids != ''} ? {AND analysis_id IN (@analysis_ids)}
;
