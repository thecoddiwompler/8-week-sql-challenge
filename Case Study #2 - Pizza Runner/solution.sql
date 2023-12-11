-- A. Pizza Metrics

-- 1. How many pizzas were ordered?

SELECT COUNT(order_id) AS pizza_count
FROM pizza_runner.customer_orders;


-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_order_count
FROM pizza_runner.customer_orders;


-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(DISTINCT order_id) AS successful_order_count
FROM pizza_runner.runner_orders
WHERE UPPER(cancellation) NOT LIKE '%CANCELLATION%' OR cancellation IS NULL
GROUP BY runner_id;


--4. How many of each type of pizza was delivered?

SELECT cus_orders.pizza_id, pizza_names.pizza_name, COUNT(cus_orders.pizza_id) AS pizza_count
FROM pizza_runner.customer_orders cus_orders
INNER JOIN pizza_runner.pizza_names pizza_names
ON cus_orders.pizza_id = pizza_names.pizza_id
INNER JOIN pizza_runner.runner_orders runner_orders
ON runner_orders.order_id = cus_orders.order_id
WHERE UPPER(runner_orders.cancellation) NOT LIKE '%CANCELLATION%' OR runner_orders.cancellation IS NULL
GROUP BY cus_orders.pizza_id, pizza_names.pizza_name;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

WITH meatlovers AS (
    SELECT cus_orders.customer_id, COUNT(cus_orders.pizza_id) AS meatlovers_count
    FROM pizza_runner.customer_orders cus_orders
    INNER JOIN
    pizza_runner.pizza_names pizza_names
    on cus_orders.pizza_id=pizza_names.pizza_id
    WHERE UPPER(pizza_names.pizza_name)='MEATLOVERS'
    GROUP BY cus_orders.customer_id
),
vegetarian AS (
    SELECT cus_orders.customer_id, COUNT(cus_orders.pizza_id) AS vegetarian_count
    FROM pizza_runner.customer_orders cus_orders
    INNER JOIN
    pizza_runner.pizza_names pizza_names
    on cus_orders.pizza_id=pizza_names.pizza_id
    WHERE UPPER(pizza_names.pizza_name)='VEGETARIAN'
    GROUP BY cus_orders.customer_id
)
SELECT COALESCE(meatlovers.customer_id, vegetarian.customer_id), COALESCE(meatlovers.meatlovers_count,0), COALESCE(vegetarian.vegetarian_count,0)
FROM meatlovers
FULL OUTER JOIN vegetarian
ON meatlovers.customer_id=vegetarian.customer_id

-- Alternatively, We can solve it using SUM() in easier way


-- 6. What was the maximum number of pizzas delivered in a single order?

WITH cte AS (
    SELECT cus_orders.order_id, COUNT(cus_orders.order_id) counter
    FROM pizza_runner.customer_orders cus_orders
    INNER JOIN
    pizza_runner.runner_orders runner_orders
    ON cus_orders.order_id=runner_orders.order_id
    WHERE UPPER(runner_orders.cancellation) NOT LIKE '%CANCELLATION%' OR runner_orders.cancellation IS NULL
    GROUP BY cus_orders.order_id
),
max AS (
    SELECT MAX(counter) counter
    FROM cte
)
SELECT cte.order_id, max.counter
FROM cte
INNER JOIN
max
ON cte.counter=max.counter


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT cus_orders.customer_id,
COUNT(CASE WHEN cus_orders.exclusions NOT IN ('null','') OR cus_orders.extras NOT IN ('','null') THEN cus_orders.order_id END) AS having_change,
COUNT(CASE WHEN cus_orders.exclusions IN ('null','') AND (cus_orders.extras IN ('','null') OR cus_orders.extras IS NULL) THEN cus_orders.order_id END) AS not_having_change
FROM pizza_runner.customer_orders cus_orders
INNER JOIN
pizza_runner.runner_orders runner_orders
ON cus_orders.order_id=runner_orders.order_id
WHERE UPPER(runner_orders.cancellation) NOT LIKE '%CANCELLATION%' OR runner_orders.cancellation IS NULL
GROUP BY cus_orders.customer_id


-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) delivered_pizzas
FROM pizza_runner.customer_orders cus_orders
INNER JOIN
pizza_runner.runner_orders runner_orders
ON cus_orders.order_id=runner_orders.order_id
WHERE (UPPER(runner_orders.cancellation) NOT LIKE '%CANCELLATION%' OR runner_orders.cancellation IS NULL)
AND cus_orders.exclusions NOT IN ('null','') AND cus_orders.extras NOT IN ('','null')


-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT(HOURS FROM cus_orders.order_time) hours, COUNT(cus_orders.order_id) volume
FROM pizza_runner.customer_orders cus_orders
GROUP BY EXTRACT(HOURS FROM cus_orders.order_time)
ORDER BY EXTRACT(HOURS FROM cus_orders.order_time)


-- 10. What was the volume of orders for each day of the week?

SELECT TO_CHAR(cus_orders.order_time, 'Day') dow, COUNT(cus_orders.order_id) volume
FROM pizza_runner.customer_orders cus_orders
GROUP BY TO_CHAR(cus_orders.order_time, 'Day'), EXTRACT(dow FROM cus_orders.order_time)
ORDER BY EXTRACT(dow FROM cus_orders.order_time)


-- B. Runner and Customer Experience

--Assumption- I am treating multiple types of pizzas in single order as single and I am not considering them separate to calculate metrics.

-- 11. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
    TO_CHAR(registration_date, 'w') registration_week,
    COUNT(runner_id) registration_count
FROM
    pizza_runner.runners
GROUP BY
    TO_CHAR(registration_date, 'w')
ORDER BY
    registration_week;


-- 12. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?

WITH cte AS (
    SELECT
        b.runner_id,
        a.order_time,
        TO_TIMESTAMP(b.pickup_time, 'YYYY-MM-DD HH24:MI:SS') pickup_time
    FROM
        pizza_runner.customer_orders a
        INNER JOIN pizza_runner.runner_orders b ON a.order_id = b.order_id
    WHERE
        b.pickup_time != 'null'
    GROUP BY
        b.runner_id,
        a.order_time,
        TO_TIMESTAMP(b.pickup_time, 'YYYY-MM-DD HH24:MI:SS')
    ORDER BY
        b.runner_id
)
SELECT
    runner_id,
    ROUND(
        AVG(
            (
                EXTRACT(
                    SECOND
                    FROM
                        pickup_time - order_time
                ) + EXTRACT(
                    MINUTE
                    FROM
                        pickup_time - order_time
                ) * 60
            ) / 60
        ),
        2
    ) avg_time
FROM
    cte
GROUP BY
    runner_id;


-- 13. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH cte AS (
    SELECT
        a.order_id,
        a.order_time,
        TO_TIMESTAMP(b.pickup_time, 'YYYY-MM-DD HH24:MI:SS') pickup_time
    FROM
        pizza_runner.customer_orders a
        INNER JOIN pizza_runner.runner_orders b ON a.order_id = b.order_id
    WHERE
        b.pickup_time != 'null'
    ORDER BY
        a.order_id
),
pizza_count_prep_time AS (
    SELECT
        order_id,
        COUNT(order_id) pizza_count,
        AVG(
            (
                EXTRACT(
                    SECOND
                    FROM
                        pickup_time - order_time
                ) + EXTRACT(
                    MINUTE
                    FROM
                        pickup_time - order_time
                ) * 60
            ) / 60
        ) prep_time
    FROM
        cte
    GROUP BY
        order_id
)
SELECT
    pizza_count,
    ROUND(AVG(prep_time), 2) prep_time
FROM
    pizza_count_prep_time
GROUP BY
    pizza_count;


-- 14. What was the average distance traveled for each customer?

WITH cte AS (
    SELECT
        b.customer_id,
        b.order_id,
        TO_NUMBER(a.distance, '999.99') distance
    FROM
        pizza_runner.runner_orders a
        INNER JOIN pizza_runner.customer_orders b ON a.order_id = b.order_id
    WHERE
        distance != 'null'
    GROUP BY
        b.customer_id,
        b.order_id,
        to_number(a.distance, '999.99')
)
SELECT
    customer_id,
    ROUND(AVG(distance), 2) avg_distance_travelled
FROM
    cte
GROUP BY
    customer_id
ORDER BY
    customer_id;


-- 15. What was the difference between the longest and shortest delivery times for all orders?

SELECT
    MAX(TO_NUMBER(duration, '999.99')) - MIN(TO_NUMBER(duration, '999.99')) difference
FROM
    pizza_runner.runner_orders
WHERE
    duration != 'null';


-- 16. What was the average speed for each runner for each delivery, and do you notice any trends for these values?

SELECT
    runner_id,
    order_id,
    ROUND(
        TO_NUMBER(distance, '999.99') /(TO_NUMBER(duration, '999.99') / 60),
        2
    ) || ' Km/hr' avg_speed
FROM
    pizza_runner.runner_orders
WHERE
    distance != 'null'
ORDER BY
    runner_id,
    order_id;


-- 17. What is the successful delivery percentage for each runner?

SELECT
    runner_id,
    ROUND(
        (
            COUNT(runner_id) - COUNT(runner_id) FILTER(
                WHERE
                    LOWER(cancellation) LIKE '%cancellation%'
            )
        ) * 100.0 / COUNT(runner_id),
        2
    ) successful_delivery_percentage
FROM
    pizza_runner.runner_orders
GROUP BY
    runner_id
ORDER BY
    runner_id;


-- C. Ingredient Optimization

