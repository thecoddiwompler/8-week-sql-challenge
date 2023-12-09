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
		all_detailed_transactions
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
customers AS (
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
	customers


-- C. Data Allocation Challenge

-- running customer balance column that includes the impact each transaction

SELECT
	customer_id,
	txn_date,
	SUM(
		CASE
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE txn_amount *(-1)
		END
	) OVER(
		PARTITION BY customer_id
		ORDER BY
			txn_date
	) running_balance
FROM
	data_bank.customer_transactions;


-- customer balance at the end of each month

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
	customer_id;


-- minimum, average, and maximum values of the running balance for each customer

WITH running_balance AS (
	SELECT
		customer_id,
		txn_date,
		SUM(
			CASE
				WHEN txn_type = 'deposit' THEN txn_amount
				ELSE txn_amount *(-1)
			END
		) OVER(
			PARTITION BY customer_id
			ORDER BY
				txn_date
		) running_balance
	FROM
		data_bank.customer_transactions
)
SELECT
	customer_id,
	txn_date,
	running_balance,
	MIN(running_balance) OVER(
		PARTITION BY customer_id
		ORDER BY
			txn_date
	) min_running_balance,
	MAX(running_balance) OVER(
		PARTITION BY customer_id
		ORDER BY
			txn_date
	) max_running_balance,
	ROUND(
		AVG(running_balance) OVER(
			PARTITION BY customer_id
			ORDER BY
				txn_date
		),
		2
	) avg_running_balance
FROM
	running_balance;


-- Option 1: data is allocated based on the amount of money at the end of the previous month

-- Assumption: Some customers do not maintain a positive account balance at the end of the month. I'm assuming that no data is allocated when the amount of money at the end of the previous month is negative.

WITH all_months AS (
	SELECT
		DISTINCT TO_CHAR(txn_date, 'MonthYYYY') month_name,
		TO_CHAR(txn_date, 'MM') month_num,
		TO_CHAR(txn_date, 'YY') year_num
	FROM
		data_bank.customer_transactions
	UNION
	SELECT
		DISTINCT TO_CHAR(txn_date + 30, 'MonthYYYY') month_name,
		TO_CHAR(txn_date + 30, 'MM') month_num,
		TO_CHAR(txn_date + 30, 'YY') year_num
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
),
month_end_balance AS (
	SELECT
		customer_id,
		month_name,
		month_num,
		LEAD(month_num) OVER(
			PARTITION BY customer_id
			ORDER BY
				month_num
		) next_month_num,
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
),
previous_month_end_balance AS (
	SELECT
		a.customer_id,
		a.month_name,
		a.month_num,
		b.month_end_balance previous_month_end_balance
	FROM
		month_end_balance a
		LEFT OUTER JOIN month_end_balance b ON a.customer_id = b.customer_id
		AND a.month_num = b.next_month_num
)
SELECT
	month_name,
	SUM(
		CASE
			WHEN previous_month_end_balance < 0 THEN 0
			ELSE previous_month_end_balance
		END
	) data_required
FROM
	previous_month_end_balance
GROUP BY
	month_name,
	month_num
ORDER BY
	month_num;


-- Option 2: data is allocated based on the average amount of money kept in the account in the previous 30 days

-- Assumption: Some customers do not maintain a positive average account in the month. I'm assuming that no data is allocated when the average balance is negative.

WITH all_corner_dates AS (      -- Get the first date and last date of all the months
	SELECT
		DISTINCT DATE_TRUNC('month', txn_date) corner_date
	FROM
		data_bank.customer_transactions
	UNION
	SELECT
		DISTINCT DATE_TRUNC('month', txn_date) + INTERVAL '1 month' - INTERVAL '1 day'
	FROM
		data_bank.customer_transactions
),
all_customers AS (              -- Get all the distinct customer
	SELECT
		DISTINCT customer_id
	FROM
		data_bank.customer_transactions
),
all_transactions AS (           -- Get all the transactions of all the dates for all the customers
	SELECT
		customer_id,
		txn_date,
		SUM(
			CASE
				WHEN txn_type = 'deposit' THEN txn_amount
				ELSE txn_amount *(-1)
			END
		) AS transaction_amount
	FROM
		data_bank.customer_transactions
	GROUP BY
		customer_id,
		txn_date
	UNION
	SELECT
		a.customer_id,
		b.corner_date txn_date,
		0 AS transaction_amount
	FROM
		all_customers a
		CROSS JOIN all_corner_dates b
),
all_detailed_transactions AS (      -- Take the union of all the transactions and all first and last dates with transaction value as 0
	SELECT
		customer_id,
		txn_date,
		COALESCE(
			EXTRACT(
				days
				FROM
					LEAD(txn_date) OVER(
						PARTITION BY customer_id,
						DATE_TRUNC('month', txn_date)
						ORDER BY
							txn_date
					) - txn_date
			),
			1
		) total_days,
		SUM(transaction_amount) OVER(
			PARTITION BY customer_id
			ORDER BY
				txn_date
		) running_balance
	FROM
		all_transactions
),
average_balance AS (        -- Get the average balance of all the customers for all months
	SELECT
		customer_id,
		TO_CHAR(txn_date, 'Month YYYY') month_name,
		TO_CHAR(txn_date, 'MM') month_num,
		ROUND(
			SUM(total_days * running_balance) * 1.0 / SUM(total_days),
			2
		) average_balance
	FROM
		all_detailed_transactions
	GROUP BY
		customer_id,
		TO_CHAR(txn_date, 'Month YYYY'),
		TO_CHAR(txn_date, 'MM')
)
SELECT
	month_name,
	SUM(
		CASE
			WHEN average_balance > 0 THEN average_balance
			ELSE 0
		END
	) data_allocated
FROM
	average_balance
GROUP BY
	month_name,
	month_num
ORDER BY
	month_num;


-- Option 3: data is updated real-time

-- Assumption: Some Customers have balance in negative on transaction date. It has been assumed that they do not require any Data Storage and they have been not included in calculation.

WITH running_balance AS (
  SELECT
    DISTINCT customer_id,
    txn_date,
    TO_CHAR(txn_date, 'MM') month_num,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE txn_amount *(-1)
      END
    ) OVER(
      PARTITION BY customer_id
      ORDER BY
        txn_date
    ) running_balance
  FROM
    data_bank.customer_transactions
)
SELECT
  TO_CHAR(txn_date, 'Month YYYY') month_name,
  sum(
    CASE
      WHEN running_balance > 0 THEN running_balance
      ELSE 0
    END
  ) data_required
FROM
  running_balance
GROUP BY
  TO_CHAR(txn_date, 'Month YYYY'),
  month_num
ORDER BY
  month_num;



-- D. Extra Challenge

-- Part 1. Calculated using Simple Interest

-- Option 1: data is allocated based on the amount of money at the end of the previous month

-- Assumption: 
	-- Some customers do not maintain a positive account balance at the end of the month. I'm assuming that no data is allocated when the amount of money at the end of the previous month is negative.
	-- I have assumed interest credited is 0 when balance on that day is negative.

WITH RECURSIVE date_generator(n) AS (
  SELECT
    DATE_TRUNC('month', MIN(txn_date)) AS txn_date
  FROM
    data_bank.customer_transactions
  UNION
  SELECT
    n + INTERVAL '1 day' AS txn_date
  FROM
    date_generator
  WHERE
    n < (
      SELECT
        DATE_TRUNC('month', MAX(txn_date)) + INTERVAL '1 month' - INTERVAL '1 day'
      FROM
        data_bank.customer_transactions
    )
),
detailed_date_customer AS (
  SELECT
    DISTINCT a.n txn_date,
    b.customer_id
  FROM
    date_generator a
    CROSS JOIN data_bank.customer_transactions b
),
total_transactions AS (
  SELECT
    customer_id,
    txn_date,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE txn_amount *(-1)
      END
    ) txn_amount
  FROM
    data_bank.customer_transactions
  GROUP BY
    customer_id,
    txn_date
),
detailed_transactions AS (
  SELECT
    a.txn_date,
    a.customer_id,
    COALESCE(b.txn_amount, 0) txn_amount
  FROM
    detailed_date_customer a
    LEFT OUTER JOIN total_transactions b ON a.txn_date = b.txn_date
    AND a.customer_id = b.customer_id
),
interest_calc AS (
  SELECT
    customer_id,
    txn_date,
    SUM(txn_amount) OVER(
      PARTITION BY customer_id
      ORDER BY
        txn_date
    ) running_balance,
    CASE
      WHEN SUM(txn_amount) OVER(
        PARTITION BY customer_id
        ORDER BY
          txn_date
      ) > 0 THEN SUM(txn_amount) OVER(
        PARTITION BY customer_id
        ORDER BY
          txn_date
      ) * (0.06 / 365)
      ELSE 0
    END interest_credited
  FROM
    detailed_transactions
),
cumulative_interest_calc AS (
  SELECT
    customer_id,
    txn_date,
    running_balance,
    SUM(interest_credited) OVER(
      PARTITION BY customer_id
      ORDER BY
        txn_date
    ) cumulative_interest_earned
  FROM
    interest_calc
),
month_end_balance AS (
  SELECT
    customer_id,
    txn_date,
    running_balance + cumulative_interest_earned AS balance
  FROM
    cumulative_interest_calc
  WHERE
    txn_date = DATE_TRUNC('month', txn_date) + INTERVAL '1 month' - INTERVAL '1 day'
)
SELECT
  TO_CHAR(txn_date + INTERVAL '1 day', 'Month YYYY') month_name,
  SUM(
    CASE
      WHEN balance > 0 THEN balance
      ELSE 0
    END
  ) data_required
FROM
  month_end_balance
GROUP BY
  txn_date
ORDER BY
  txn_date;


-- Option 2: data is allocated based on the average amount of money kept in the account in the previous 30 days

-- Assumption: 
	-- Some customers do not maintain a positive average account in the month. I'm assuming that no data is allocated when the average balance is negative.
	-- I have assumed interest credited is 0 when balance on that day is negative.

WITH RECURSIVE date_generator(n) AS (
  SELECT
    DATE_TRUNC('month', MIN(txn_date)) AS txn_date
  FROM
    data_bank.customer_transactions
  UNION
  SELECT
    n + INTERVAL '1 day' AS txn_date
  FROM
    date_generator
  WHERE
    n < (
      SELECT
        DATE_TRUNC('month', MAX(txn_date)) + INTERVAL '1 month' - INTERVAL '1 day'
      FROM
        data_bank.customer_transactions
    )
),
detailed_date_customer AS (
  SELECT
    DISTINCT a.n txn_date,
    b.customer_id
  FROM
    date_generator a
    CROSS JOIN data_bank.customer_transactions b
),
total_transactions AS (
  SELECT
    customer_id,
    txn_date,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE txn_amount *(-1)
      END
    ) txn_amount
  FROM
    data_bank.customer_transactions
  GROUP BY
    customer_id,
    txn_date
),
detailed_transactions AS (
  SELECT
    a.txn_date,
    a.customer_id,
    COALESCE(b.txn_amount, 0) txn_amount
  FROM
    detailed_date_customer a
    LEFT OUTER JOIN total_transactions b ON a.txn_date = b.txn_date
    AND a.customer_id = b.customer_id
),
interest_calc AS (
  SELECT
    customer_id,
    txn_date,
    SUM(txn_amount) OVER(
      PARTITION BY customer_id
      ORDER BY
        txn_date
    ) running_balance,
    CASE
      WHEN SUM(txn_amount) OVER(
        PARTITION BY customer_id
        ORDER BY
          txn_date
      ) > 0 THEN SUM(txn_amount) OVER(
        PARTITION BY customer_id
        ORDER BY
          txn_date
      ) * (0.06 / 365)
      ELSE 0
    END interest_credited
  FROM
    detailed_transactions
),
cumulative_interest_calc AS (
  SELECT
    customer_id,
    txn_date,
    running_balance,
    SUM(interest_credited) OVER(
      PARTITION BY customer_id
      ORDER BY
        txn_date
    ) cumulative_interest_earned
  FROM
    interest_calc
),
daily_balance_calc AS (
  SELECT
    customer_id,
    txn_date,
    running_balance + cumulative_interest_earned balance
  FROM
    cumulative_interest_calc
),
avg_monthly_balance AS (
  SELECT
    customer_id,
    TO_CHAR(txn_date, 'Month YYYY') month_name,
    TO_CHAR(txn_date, 'MM') month_no,
    AVG(balance) avg_balance
  FROM
    daily_balance_calc
  GROUP BY
    customer_id,
    TO_CHAR(txn_date, 'Month YYYY'),
    TO_CHAR(txn_date, 'MM')
)
SELECT
  month_name,
  ROUND(
    SUM(
      CASE
        WHEN avg_balance > 0 THEN avg_balance
        ELSE 0
      END
    ),
    2
  ) data_required
FROM
  avg_monthly_balance
GROUP BY
  month_name,
  month_no
ORDER BY
  month_no;


-- Option 3: data is updated real-time

-- Assumption:
	-- Some Customers have balance in negative on transaction date. It has been assumed that they do not require any Data Storage and they have been not included in calculation.
	-- I have assumed interest credited is 0 when balance on that day is negative.

WITH RECURSIVE date_generator(n) AS (
  SELECT
    DATE_TRUNC('month', MIN(txn_date)) AS txn_date
  FROM
    data_bank.customer_transactions
  UNION
  SELECT
    n + INTERVAL '1 day' AS txn_date
  FROM
    date_generator
  WHERE
    n < (
      SELECT
        DATE_TRUNC('month', MAX(txn_date)) + INTERVAL '1 month' - INTERVAL '1 day'
      FROM
        data_bank.customer_transactions
    )
),
detailed_date_customer AS (
  SELECT
    DISTINCT a.n txn_date,
    b.customer_id
  FROM
    date_generator a
    CROSS JOIN data_bank.customer_transactions b
),
total_transactions AS (
  SELECT
    customer_id,
    txn_date,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        ELSE txn_amount *(-1)
      END
    ) txn_amount
  FROM
    data_bank.customer_transactions
  GROUP BY
    customer_id,
    txn_date
),
detailed_transactions AS (
  SELECT
    a.txn_date,
    a.customer_id,
    COALESCE(b.txn_amount, 0) txn_amount
  FROM
    detailed_date_customer a
    LEFT OUTER JOIN total_transactions b ON a.txn_date = b.txn_date
    AND a.customer_id = b.customer_id
),
interest_calc AS (
  SELECT
    customer_id,
    txn_date,
    SUM(txn_amount) OVER(
      PARTITION BY customer_id
      ORDER BY
        txn_date
    ) running_balance,
    CASE
      WHEN SUM(txn_amount) OVER(
        PARTITION BY customer_id
        ORDER BY
          txn_date
      ) > 0 THEN SUM(txn_amount) OVER(
        PARTITION BY customer_id
        ORDER BY
          txn_date
      ) * (0.06 / 365)
      ELSE 0
    END interest_credited
  FROM
    detailed_transactions
),
cumulative_interest_calc AS (
  SELECT
    customer_id,
    txn_date,
    running_balance,
    SUM(interest_credited) OVER(
      PARTITION BY customer_id
      ORDER BY
        txn_date
    ) cumulative_interest_earned
  FROM
    interest_calc
),
daily_balance_calc AS (
  SELECT
    customer_id,
    txn_date,
    running_balance + cumulative_interest_earned balance
  FROM
    cumulative_interest_calc
),
total_balance_on_transaction_date AS (
  SELECT
    a.customer_id,
    a.txn_amount,
    a.txn_date,
    b.balance
  FROM
    total_transactions a
    INNER JOIN daily_balance_calc b ON a.customer_id = b.customer_id
    AND a.txn_date = b.txn_date
)
SELECT
  TO_CHAR(txn_date, 'Month YYYY') month_num,
  ROUND(
    SUM(
      CASE
        WHEN balance > 0 THEN balance
        ELSE 0
      END
    ),
    2
  ) data_required
FROM
  total_balance_on_transaction_date
GROUP BY
  TO_CHAR(txn_date, 'Month YYYY'),
  TO_CHAR(txn_date, 'MM')
ORDER BY
  TO_CHAR(txn_date, 'MM');