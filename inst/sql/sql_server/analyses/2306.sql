-- 2306 Distribution of age by episode_concept_id (by gender_concept_id)

with cte as (
  SELECT 
    ep.episode_concept_id AS subject_id,
    p.gender_concept_id,
    ep.episode_start_year - p.year_of_birth AS count_value
  FROM 
    @cdm_database_schema.person p
  JOIN (
    SELECT 
      ep.person_id,
      ep.episode_concept_id,
      MIN(YEAR(ep.episode_start_date)) AS episode_start_year
    FROM 
      @cdm_database_schema.episode ep
    JOIN 
      @cdm_database_schema.observation_period op 
    ON 
      ep.person_id = op.person_id
    AND 
      ep.episode_start_date >= op.observation_period_start_date
    AND 
      ep.episode_start_date <= op.observation_period_end_date
    GROUP BY 
      ep.person_id,
      ep.episode_concept_id
    ) ep 
  ON 
    p.person_id = ep.person_id
), overallStats as
(
  SELECT
    subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM cte
	GROUP BY subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  SELECT
    subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    count_value,
    count_big(*) as total,
    row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM cte
  GROUP BY subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  SELECT
    s.stratum1_id,
    s.stratum2_id,
    s.count_value,
    s.total,
    sum(p.total) as accumulated
  FROM statsView s
  JOIN statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  GROUP BY s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
INSERT INTO @results_database_schema.@results_table_dist
SELECT 
  2306 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum_1,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
FROM priorStats p
JOIN overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;
