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
-- WHERE count_value > 5 AND analysis_id IN (100,110,200,201,202,203,501,511)

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
-- WHERE count_value > 5 AND analysis_id IN (100,110,200,201,202,203,501,511)
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
{@analysis_ids != ''} ? {AND analysis_id IN (@analysis_ids)}

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
{@analysis_ids != ''} ? {AND analysis_id IN (@analysis_ids)}
;
