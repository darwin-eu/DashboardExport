-- 943 Number of records by drug_concept_id by ICH age group
-- If day and/or month of birth are not given, then these are set to 1.

WITH cte1 AS (
    SELECT
        person_id,
        datefromparts(
            year_of_birth,
            coalesce(month_of_birth, 1),
            coalesce(day_of_birth, 1)
        ) as date_of_birth
    FROM @cdm_database_schema.person
), cte2 as (
    SELECT
        p.person_id,
        de.drug_concept_id,
        DATEDIFF(day, p.date_of_birth, de.drug_era_start_date) AS age_days,
        DATEDIFF(year, p.date_of_birth, de.drug_era_start_date) AS age_years
    FROM cte1 p
    JOIN @cdm_database_schema.drug_era de
        ON p.person_id = de.person_id
    JOIN @cdm_database_schema.observation_period op
        ON de.person_id = op.person_id
        AND de.drug_era >= op.observation_period_start_date
        AND de.drug_era <= op.observation_period_end_date
    WHERE DATEDIFF(year, p.date_of_birth, de.drug_era_start_date) < 19
        AND drug_era_concept_id != 0
), cte3 as (
    SELECT *,
        case
            when age_days < 0
                then 'Negative age'
            when age_days < 28
                then 'Term newborn infants (0 to 27 days)*'
            when age_years < 2
                then 'Infants and toddlers (28 days to 23 months)*'
            when age_years < 12
                then 'Children (2 to 11 years)'
            when age_years < 19
                then 'Adolescents (12 to 18 years)'
        end as age_group
    from cte2
)
INSERT INTO @results_database_schema.@results_table
    select
        943 as analysis_id,
        drug_concept_id as stratum_1,
        age_group as stratum_2,
        CAST(NULL AS VARCHAR(255)) AS stratum_3,
        CAST(NULL AS VARCHAR(255)) AS stratum_4,
        CAST(NULL AS VARCHAR(255)) AS stratum_5,
        count_big(*) as count_value
    from cte3
    group by drug_concept_id, age_group
;