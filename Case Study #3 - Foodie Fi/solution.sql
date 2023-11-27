-- B. Data Analysis Question


-- 1. How many customers has Foodie-Fi ever had?

SELECT
  COUNT(DISTINCT customer_id)
FROM
  foodie_fi.subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset -use the start of the month as the group by value?

SELECT
  TO_CHAR(subscriptions.start_date, 'YYYY-Mon') MONTH_NAME,
  COUNT(*) CUSTOMER_COUNT
FROM
  foodie_fi.subscriptions subscriptions
  INNER JOIN foodie_fi.plans plans ON subscriptions.plan_id = plans.plan_id
WHERE
  plans.plan_name = 'trial'
GROUP BY
  TO_CHAR(subscriptions.start_date, 'YYYY-Mon'),
  TO_CHAR(subscriptions.start_date, 'MM')
ORDER BY
  TO_CHAR(subscriptions.start_date, 'MM');

-- 3. What plan start_date values occur after the year 2020 for our dataset?  Show the breakdown by count of events for each plan_name.

SELECT
  plans.plan_name,
  COUNT(*) total_subscriptions
FROM
  foodie_fi.plans plans
  LEFT OUTER JOIN foodie_fi.subscriptions subscriptions ON plans.plan_id = subscriptions.plan_id
WHERE
  subscriptions.start_date > TO_DATE('2020-12-31', 'YYYY-MM-DD')
GROUP BY
  plans.plan_name,
  plans.plan_id
ORDER BY
  plans.plan_id;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
  COUNT(DISTINCT customer_id) FILTER (
    WHERE
      plan_id = 4
  ) total_customer,
  ROUND(
    COUNT(DISTINCT customer_id) FILTER (
      WHERE
        plan_id = 4
    ) * 100.0 / COUNT(DISTINCT customer_id),
    2
  ) churned_customer_percentage
FROM
  foodie_fi.subscriptions;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH cte AS (
  SELECT
    customer_id,
    plan_id,
    RANK() OVER(
      PARTITION BY customer_id
      ORDER BY
        start_date
    ) subscription_order
  FROM
    foodie_fi.subscriptions
),
total_customer_count AS (
  SELECT
    COUNT(DISTINCT customer_id) total_customer_count
  FROM
    foodie_fi.subscriptions
),
churn_count AS (
  SELECT
    COUNT(*) churn_count
  FROM
    cte a
    INNER JOIN cte b ON a.subscription_order = b.subscription_order -1
    AND a.customer_id = b.customer_id
  WHERE
    a.plan_id = 0
    AND b.plan_id = 4
)
SELECT
  churn_count.churn_count,
  ROUND(
    (churn_count.churn_count * 100.0) /(total_customer_count.total_customer_count),
    0
  ) percentage_churn_count
FROM
  churn_count,
  total_customer_count;

-- 6. What is the number and percentage of customer plans after their initial free trial?

WITH cte AS (
  SELECT
    customer_id,
    plan_id,
    RANK() OVER(
      PARTITION BY customer_id
      ORDER BY
        start_date
    ) subscription_order
  FROM
    foodie_fi.subscriptions
),
plan_details AS (
  SELECT
    plans.plan_name,
    COUNT(*) converted_customer
  FROM
    foodie_fi.plans plans
    INNER JOIN cte ON plans.plan_id = cte.plan_id
  WHERE
    cte.subscription_order = 2
  GROUP BY
    plans.plan_name
),
total_customer_count AS (
  SELECT
    COUNT(DISTINCT customer_id) total_customer_count
  FROM
    foodie_fi.subscriptions
)
SELECT
  INITCAP(plan_details.plan_name) plan_name,
  plan_details.converted_customer,
  ROUND(
    (plan_details.converted_customer) * 100.0 /(total_customer_count.total_customer_count),
    2
  ) conversion_percentage
FROM
  plan_details
  CROSS JOIN total_customer_count;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH cte AS (
  SELECT
    subscriptions.customer_id,
    MAX(start_date) active_plan_date
  FROM
    foodie_fi.subscriptions subscriptions
  WHERE
    start_date <= TO_DATE('2020-12-31', 'YYYY-MM-DD')
  GROUP BY
    subscriptions.customer_id
),
current_plan AS (
  SELECT
    cte.customer_id,
    plans.plan_id,
    INITCAP(plans.plan_name) plan_name,
    cte.active_plan_date
  FROM
    cte
    INNER JOIN foodie_fi.subscriptions subscriptions ON cte.active_plan_date = subscriptions.start_date
    AND cte.customer_id = subscriptions.customer_id
    INNER JOIN foodie_fi.plans plans ON subscriptions.plan_id = plans.plan_id
),
total_customer AS (
  SELECT
    COUNT(customer_id) total_customer
  FROM
    cte
),
customer_plan_count AS (
  SELECT
    current_plan.plan_name,
    current_plan.plan_id,
    COUNT(current_plan.customer_id) customer_count
  FROM
    current_plan
  GROUP BY
    current_plan.plan_name,
    current_plan.plan_id
)
SELECT
  customer_plan_count.plan_name,
  customer_plan_count.customer_count,
  ROUND(
    customer_plan_count.customer_count * 100.0 / total_customer.total_customer,
    2
  ) percentage_count
FROM
  customer_plan_count
  CROSS JOIN total_customer
ORDER BY
  customer_plan_count.plan_id;

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT
  COUNT(customer_id) customer_count
FROM
  foodie_fi.subscriptions subscriptions
WHERE
  subscriptions.plan_id = 3
  AND TO_CHAR(subscriptions.start_date, 'YYYY') = '2020';

-- 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

SELECT
  ROUND(AVG(a.start_date - b.start_date), 0)
FROM
  foodie_fi.subscriptions a
  INNER JOIN foodie_fi.subscriptions b ON a.customer_id = b.customer_id
WHERE
  a.plan_id = 3
  AND b.plan_id = 0;

-- 10. Can you further break down this average value into 30-day periods (i.e., 0-30 days, 31-60 days, etc.)?

WITH cte AS (
  SELECT
    (a.start_date - b.start_date) days_taken,
    WIDTH_BUCKET(a.start_date - b.start_date, 0, 365, 12) bucket_no
  FROM
    foodie_fi.subscriptions a
    INNER JOIN foodie_fi.subscriptions b ON a.customer_id = b.customer_id
  WHERE
    a.plan_id = 3
    AND b.plan_id = 0
)
SELECT
  (bucket_no -1) * 30 || ' - ' || bucket_no * 30 || ' days' AS avg_days_taken_to_upgrade_plan,
  COUNT(bucket_no) customer_count
FROM
  cte
GROUP BY
  bucket_no
ORDER BY
  bucket_no;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

SELECT
  COUNT(*) customer_count
FROM
  foodie_fi.subscriptions a
  INNER JOIN foodie_fi.subscriptions b ON a.customer_id = b.customer_id
  AND b.start_date > a.start_date
WHERE
  a.plan_id = 2
  AND b.plan_id = 1;