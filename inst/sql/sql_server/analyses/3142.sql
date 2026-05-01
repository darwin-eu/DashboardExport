-- 3142 Number of records by age decile
INSERT INTO @results_database_schema.@results_table
SELECT
  3142 AS analysis_id,
  CAST(NULL AS VARCHAR(255)) AS stratum_1,
  FLOOR((YEAR(pet.pregnancy_start_date) - p.year_of_birth) / 10) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.person p
JOIN @cdm_database_schema.pregnancy pet
  ON p.person_id = pet.person_id
-- JOIN @cdm_database_schema.observation_period op
--   ON pet.person_id = op.person_id
--   AND pet.pregnancy_start_date >= op.observation_period_start_date
--   AND pet.pregnancy_start_date <= op.observation_period_end_date
GROUP BY
  FLOOR((YEAR(pet.pregnancy_start_date) - p.year_of_birth) / 10)
;