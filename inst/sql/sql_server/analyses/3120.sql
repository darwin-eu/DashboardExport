-- 3120	Number of records by start month
WITH rawData AS (
  SELECT 
    YEAR(pet.pregnancy_start_date) * 100 + MONTH(pet.pregnancy_start_date) AS stratum_1,
    COUNT_BIG(pet.person_id) AS count_value
  FROM @cdm_database_schema.pregnancy pet
  -- JOIN @cdm_database_schema.observation_period op 
  --   ON pet.person_id = op.person_id
  --   AND pet.pregnancy_start_date >= op.observation_period_start_date
  --   AND pet.pregnancy_start_date <= op.observation_period_end_date
  GROUP BY 
    YEAR(pet.pregnancy_start_date) * 100 + MONTH(pet.pregnancy_start_date)
)
INSERT INTO @results_database_schema.@results_table
SELECT
	3120 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
FROM 
	rawData;