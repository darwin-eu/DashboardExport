-- Export achilles results
-- Combines regular and _dist results into one output.
-- Adds package-specific analyses 0,430,630,730,740,741,830,1830,2130,5000

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

    -- Analysis id 0 expected as first row in output
    SELECT 
        0 as analysis_id,  
        stratum_1 as stratum_1, -- Achilles source name
        CAST('@package_version' AS VARCHAR(255)) as stratum_2, 
        CONVERT(VARCHAR,GETDATE(),112) as stratum_3,
        stratum_2 as stratum_4, -- Achilles version
        stratum_3 as stratum_5, -- Achilles execution date
        count_value as count_value -- Achilles distinct person count
    FROM @results_database_schema.achilles_results
    WHERE analysis_id = 0

    UNION ALL

    -- Regular achilles_results
    SELECT 
        CASE 
            -- Re-id analysis_id xx30 to prevent clashes
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
    WHERE analysis_id > 0 
    AND analysis_id < 2000000 -- exclude timings

    UNION ALL

    -- DashboardExport-specific analyses
    SELECT *
    FROM @results_database_schema.@de_results_table

) ar
WHERE count_value > @min_cell_count 
    {@analysis_ids != ''} ? {AND analysis_id IN (@analysis_ids)}

UNION ALL

-- Dist
SELECT
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
