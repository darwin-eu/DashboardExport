-- CDM Source
INSERT INTO @results_database_schema.@results_table
    SELECT
        5000 as analysis_id,
        cdm_source_name as stratum_1,
        CONCAT(YEAR(source_release_date), '-', MONTH(source_release_date), '-', DAY(source_release_date)) as stratum_2,
        CONCAT(YEAR(cdm_release_date), '-', MONTH(cdm_release_date), '-', DAY(cdm_release_date)) as stratum_3,
        cdm_version as stratum_4,
        vocabulary.vocabulary_version as stratum_5,
        999 as count_value -- needs to be > min_cell_count to pass export
    FROM @cdm_database_schema.cdm_source
    cross join (
        select vocabulary_version 
        from @cdm_database_schema.vocabulary
        where vocabulary_id = 'None'
    ) vocabulary
;