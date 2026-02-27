-- CDM Source
WITH ranked_cdm_source AS (
    SELECT
        cdm_source_name,
        cdm_release_date,
        cdm_version,
        source_release_date,
        vocabulary_version,
        cdm_version
        ROW_NUMBER() OVER (ORDER BY cdm_release_date DESC) AS rn
    FROM @cdm_database_schema.cdm_source
)
INSERT INTO @results_database_schema.@results_table
    SELECT
        5000 as analysis_id,
        cdm_source_name as stratum_1,
        CONCAT(YEAR(source_release_date), '-', MONTH(source_release_date), '-', DAY(source_release_date)) as stratum_2,
        CONCAT(YEAR(cdm_release_date), '-', MONTH(cdm_release_date), '-', DAY(cdm_release_date)) as stratum_3,
        cdm_version as stratum_4,
        vocabulary.vocabulary_version as stratum_5,
        999 as count_value -- needs to be > min_cell_count to pass export
    FROM ranked_cdm_source
    cross join (
        select vocabulary_version 
        from @cdm_database_schema.vocabulary
        where vocabulary_id = 'None'
    ) vocabulary
;