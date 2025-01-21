-- 2342 Number of records by episode_concept_id by age decile
INSERT INTO @results_database_schema.@results_table
SELECT
  2342 AS analysis_id,
  ep.episode_concept_id AS stratum_1,
  FLOOR((YEAR(ep.episode_start_date) - p.year_of_birth) / 10) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  COUNT_BIG(*) AS count_value
FROM @cdm_database_schema.person p
JOIN @cdm_database_schema.episode ep
  ON p.person_id = ep.person_id
JOIN @cdm_database_schema.observation_period op
  ON ep.person_id = op.person_id
  AND ep.episode_start_date >= op.observation_period_start_date
  AND ep.episode_start_date <= op.observation_period_end_date
WHERE episode_concept_id != 0
GROUP BY
  ep.episode_concept_id,
  FLOOR((YEAR(ep.episode_start_date) - p.year_of_birth) / 10)
;