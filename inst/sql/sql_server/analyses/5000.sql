-- CDM Source
INSERT INTO @results_database_schema.@results_table (
SELECT 
    5000 as analysis_id,  
    cdm_source_name as stratum_1, 
    cast(source_release_date as varchar) as stratum_2, 
    cast(cdm_release_date as varchar) as stratum_3, 
    cdm_version as stratum_4,
    vocabulary_version as stratum_5, 
    -1 as count_value
FROM @cdm_database_schema.cdm_source
)
;