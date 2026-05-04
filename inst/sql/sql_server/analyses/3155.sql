-- 3155 Distribution of length of observation period among children linked to pregnancy
with cte as (
  SELECT 
    DATEDIFF(dd, op.observation_period_start_date, op.observation_period_end_date) as count_value
  FROM 
    @cdm_database_schema.infant
  JOIN 
    @cdm_database_schema.observation_period op 
  ON 
    infant.person_id = op.person_id
-- AND 
--   pet.pregnancy_start_date >= op.observation_period_start_date
-- AND 
--   pet.pregnancy_start_date <= op.observation_period_end_date
), overallStats as
(
  SELECT
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM cte
),
statsView (count_value, total, rn) as
(
  SELECT
    count_value,
    count_big(*) as total,
    row_number() over (order by count_value) as rn
  FROM cte
  GROUP BY count_value
),
priorStats (count_value, total, accumulated) as
(
  SELECT
    s.count_value,
    s.total,
    sum(p.total) as accumulated
  FROM statsView s
  JOIN statsView p on p.rn <= s.rn
  GROUP BY s.count_value, s.total, s.rn
)
INSERT INTO @results_database_schema.@results_table_dist
SELECT 
  3155 as analysis_id,
  CAST(NULL AS VARCHAR(255)) AS stratum_1,
  CAST(NULL AS VARCHAR(255)) AS stratum_2,
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
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;
