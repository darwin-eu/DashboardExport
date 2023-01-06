-- Export achilles results
-- Combines regular and _dist results into one output

-- SELECT 
--     analysis_id,
--     stratum_1,
--     stratum_2,
--     stratum_3,
--     stratum_4,
--     stratum_5,
--     floor((count_value+99)/100)*100 as count_value,
--     cast(null as float) min_value,
--     cast(null as float) max_value,
--     cast(null as float) avg_value,
--     cast(null as float) stdev_value,
--     cast(null as float) median_value,
--     cast(null as float) p10_value,
--     cast(null as float) p25_value,
--     cast(null as float) P75_value,
--     cast(null as float) p90_value
-- FROM results.achilles_results
-- WHERE count_value > 5 --AND analysis_id IN (100,110,200,201,202,203,501,511)

-- UNION

-- SELECT 
--     5000 as analysis_id,  
--     cdm_source_name as stratum_1, 
--     cast(source_release_date as varchar) as stratum_2, 
--     cast(cdm_release_date as varchar) as stratum_3, 
--     cdm_version as stratum_4,
--     vocabulary_version as stratum_5, 
--     NULL as count_value,
--     cast(null as float) min_value,
--     cast(null as float) max_value,
--     cast(null as float) avg_value,
--     cast(null as float) stdev_value,
--     cast(null as float) median_value,
--     cast(null as float) p10_value,
--     cast(null as float) p25_value,
--     cast(null as float) P75_value,
--     cast(null as float) p90_value
-- FROM cdm.cdm_source

-- UNION

-- select
--     analysis_id,
--     stratum_1,
--     stratum_2,
--     stratum_3,
--     stratum_4,
--     stratum_5,
--     floor((count_value+99)/100)*100 as count_value,
--     min_value,
--     max_value,
--     avg_value,
--     stdev_value,
--     median_value,
--     p10_value,
--     p25_value,
--     P75_value,
--     p90_value
-- FROM results.achilles_results_dist
-- WHERE count_value > 5 AND analysis_id > 0--AND analysis_id IN (100,110,200,201,202,203,501,511)
-- ;

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
FROM @results_database_schema.achilles_results
WHERE count_value > @min_cell_count 
    AND analysis_id < 2000000 -- exclude timings
{@analysis_ids != ''} ? {AND analysis_id IN (@analysis_ids)}

UNION

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

UNION

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
