-- A. Customer Nodes Exploration


-- 1. How many unique nodes are there on the Data Bank system?

SELECT
    COUNT(DISTINCT node_id) AS unique_nodes
FROM
    data_bank.customer_nodes;


-- 2. What is the number of nodes per region?

SELECT
    nodes.region_id,
    regions.region_name,
    COUNT(DISTINCT nodes.node_id) AS node_count
FROM
    data_bank.customer_nodes nodes
    INNER JOIN data_bank.regions ON nodes.region_id = regions.region_id
GROUP BY
    nodes.region_id,
    regions.region_name;


-- 3. How many customers are allocated to each region?

SELECT
    nodes.region_id,
    regions.region_name,
    COUNT(DISTINCT nodes.customer_id) AS customer_count
FROM
    data_bank.customer_nodes nodes
    INNER JOIN data_bank.regions ON nodes.region_id = regions.region_id
GROUP BY
    nodes.region_id,
    regions.region_name;


-- 4. How many days on average are customers reallocated to a different node?

WITH cte AS (
  SELECT
    customer_id,
    (end_date - start_date) + 1 AS stay_duration
  FROM
    data_bank.customer_nodes
  WHERE
    end_date != TO_DATE('9999-12-31', 'YYYY-MM-DD')
)
SELECT
  ROUND(AVG(stay_duration), 2) avg_days
FROM
  cte;


-- 5. What is the median, 80th, and 95th percentile for this same reallocation days metric for each region?

WITH cte AS (
    SELECT
        region_id,
        (end_date - start_date) + 1 reallocation_days,
        ROW_NUMBER() OVER(
            PARTITION BY region_id
            ORDER BY
                (end_date - start_date) + 1
        ) rank_days
    FROM
        data_bank.customer_nodes
    WHERE
        end_date != TO_DATE('9999-12-31', 'YYYY-MM-DD')
),
count_customers AS (
    SELECT
        region_id,
        COUNT(*) customer_count
    FROM
        cte
    GROUP BY
        region_id
),
percentile_score AS (
    SELECT
        a.region_id,
        a.reallocation_days,
        ROUND(a.rank_days * 100.0 / b.customer_count, 2) percentile
    FROM
        cte a
        INNER JOIN count_customers b ON a.region_id = b.region_id
),
staging_table AS (
    SELECT
        region_id,
        MIN(ABS(50 - percentile)) AS median_identifier,
        MIN(ABS(80 - percentile)) AS percentile_identifier_80th,
        MIN(ABS(95 - percentile)) AS percentile_identifier_95th
    FROM
        percentile_score
    GROUP BY
        region_id
),
median AS (
    SELECT
        a.region_id,
        a.reallocation_days
    FROM
        percentile_score a
        INNER JOIN staging_table b ON a.region_id = b.region_id
        AND ABS(50 - a.percentile) = b.median_identifier
),
percentile_80th AS (
    SELECT
        a.region_id,
        a.reallocation_days
    FROM
        percentile_score a
        INNER JOIN staging_table b ON a.region_id = b.region_id
        AND ABS(80 - a.percentile) = b.percentile_identifier_80th
),
percentile_95th AS (
    SELECT
        a.region_id,
        a.reallocation_days
    FROM
        percentile_score a
        INNER JOIN staging_table b ON a.region_id = b.region_id
        AND ABS(95 - a.percentile) = b.percentile_identifier_95th
)
SELECT
    DISTINCT a.region_id,
    d.region_name,
    a.reallocation_days median_reallocation_days,
    b.reallocation_days reallocation_days_80th_percentile,
    c.reallocation_days reallocation_days_95th_percentile
FROM
    median a
    INNER JOIN percentile_80th b ON a.region_id = b.region_id
    INNER JOIN percentile_95th c ON a.region_id = c.region_id
    INNER JOIN data_bank.regions d ON d.region_id = a.region_id
ORDER BY
    1