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
