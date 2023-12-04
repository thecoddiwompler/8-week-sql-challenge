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
    1;


-- B. Customer Transactions

-- 6. What is the unique count and total amount for each transaction type?

SELECT
	txn_type,
	COUNT(*) unique_count,
	SUM(txn_amount) total_amount
FROM
	data_bank.customer_transactions
GROUP BY
	txn_type;


-- 7. What is the average total historical deposit counts and amounts for all customers?

WITH cte AS (
	SELECT
		customer_id,
		COUNT(txn_amount) total_historical_deposit_count,
		SUM(txn_amount) total_historical_deposit_sum
	FROM
		data_bank.customer_transactions
	WHERE
		txn_type = 'deposit'
	GROUP BY
		customer_id
)
SELECT
	ROUND(AVG(total_historical_deposit_count), 2) avg_total_historical_deposit_count,
	ROUND(AVG(total_historical_deposit_sum), 2) avg_total_historical_deposit_sum
FROM
	cte;


-- 8. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH cte AS (
	SELECT
		TO_CHAR(txn_date, 'MonthYYYY') month_name,
		customer_id,
		COUNT(txn_type) FILTER(
			WHERE
				txn_type = 'deposit'
		) deposit_count,
		COUNT(txn_type) FILTER(
			WHERE
				txn_type = 'withdrawal'
		) withdrawal_count,
		COUNT(txn_type) FILTER(
			WHERE
				txn_type = 'purchase'
		) purchase_count
	FROM
		data_bank.customer_transactions
	GROUP BY
		TO_CHAR(txn_date, 'MonthYYYY'),
		customer_id
)
SELECT
	month_name,
	COUNT(customer_id)
FROM
	cte
WHERE
	deposit_count > 1
	AND (
		withdrawal_count = 1
		OR purchase_count = 1
	)
GROUP BY
	month_name;


-- 9. What is the closing balance for each customer at the end of the month?

WITH all_months AS (
	SELECT
		DISTINCT TO_CHAR(txn_date, 'MonthYYYY') month_name,
		TO_CHAR(txn_date, 'MM') month_num,
		TO_CHAR(txn_date, 'YY') year_num
	FROM
		data_bank.customer_transactions
),
all_customers AS (
	SELECT
		DISTINCT customer_id
	FROM
		data_bank.customer_transactions
),
all_detailed_customers AS (
	SELECT
		a.customer_id,
		b.month_name,
		b.month_num,
		b.year_num
	FROM
		all_customers a
		CROSS JOIN all_months b
),
all_transactions AS (
	SELECT
		customer_id,
		TO_CHAR(txn_date, 'MonthYYYY') month_name,
		TO_CHAR(txn_date, 'MM') month_num,
		TO_CHAR(txn_date, 'YY') year_num,
		SUM(
			CASE
				WHEN txn_type = 'deposit' THEN txn_amount
				ELSE txn_amount *(-1)
			END
		) total_transaction
	FROM
		data_bank.customer_transactions
	GROUP BY
		customer_id,
		TO_CHAR(txn_date, 'MonthYYYY'),
		TO_CHAR(txn_date, 'MM'),
		TO_CHAR(txn_date, 'YY')
),
all_detailed_transactions AS (
	SELECT
		a.customer_id,
		a.month_name,
		a.month_num,
		a.year_num,
		COALESCE(b.total_transaction, 0) total_transaction
	FROM
		all_detailed_customers a
		LEFT OUTER JOIN all_transactions b ON a.month_name = b.month_name
		AND a.customer_id = b.customer_id
)
SELECT
	customer_id,
	month_name,
	total_transaction,
	SUM(total_transaction) OVER(
		PARTITION BY customer_id
		ORDER BY
			year_num,
			month_num
	) month_end_balance
FROM
	all_detailed_transactions
ORDER BY
	customer_id


-- 10. What is the percentage of customers who increase their closing balance by more than 5%?

-- Assumption- It has been assumed that the question is asking for the percentage of customers who increased their closing balance by more than 5% in every single month.

WITH all_transactions AS (
  SELECT
    customer_id,
    TO_CHAR(txn_date, 'MonthYYYY') month_name,
    TO_CHAR(txn_date, 'MM') month_num,
    TO_CHAR(txn_date, 'YY') year_num,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE txn_amount *(-1)
      END
    ) total_transaction
  FROM
    data_bank.customer_transactions
  GROUP BY
    customer_id,
    TO_CHAR(txn_date, 'MonthYYYY'),
    TO_CHAR(txn_date, 'MM'),
    TO_CHAR(txn_date, 'YY')
),
month_end_balance AS (
  SELECT
    customer_id,
    month_name,
    month_num,
    year_num,
    SUM(total_transaction) OVER(
      PARTITION BY customer_id
      ORDER BY
        year_num,
        month_num
    ) month_end_balance
  FROM
    all_transactions
),
month_end_bal_perc_change AS (
  SELECT
    customer_id,
    month_name,
    month_end_balance,
    CASE
      WHEN LAG(month_end_balance) OVER(
        PARTITION BY customer_id
        ORDER BY
          year_num,
          month_num
      ) != 0 THEN (
        month_end_balance - LAG(month_end_balance) OVER(
          PARTITION BY customer_id
          ORDER BY
            year_num,
            month_num
        )
      ) * 100.0 / LAG(month_end_balance) OVER(
        PARTITION BY customer_id
        ORDER BY
          year_num,
          month_num
      )
      ELSE NULL
    END AS percentage_change
  FROM
    month_end_balance
),
all_customers AS (
  SELECT
    customer_id,
    MIN(percentage_change) min_percentage_change
  FROM
    month_end_bal_perc_change
  GROUP BY
    customer_id
)
SELECT
  ROUND(
    COUNT(customer_id) FILTER(
      WHERE
        min_percentage_change > 5
    ) * 100.0 / COUNT(customer_id),
    2
  ) customer_percentage
FROM
  all_customers