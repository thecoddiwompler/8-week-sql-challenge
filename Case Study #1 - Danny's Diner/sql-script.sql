-- 1. What is the total amount each customer spent at the restaurant?


WITH cte AS (
    SELECT 
        sales.customer_id, 
        sales.product_id, 
        menu.price
    FROM
        dannys_diner.sales sales
    INNER JOIN
        dannys_diner.menu menu
        ON sales.product_id = menu.product_id
),
solution AS (
    SELECT 
        customer_id, 
        sum(price) AS total_price
    FROM cte
    GROUP BY customer_id
)

SELECT 
    *
FROM solution;


-- 2. How many days has each customer visited the restaurant?


SELECT 
    sales.customer_id, 
    COUNT(DISTINCT sales.order_date) AS days_visited
FROM 
    dannys_diner.sales sales
GROUP BY 
    sales.customer_id;


-- 3. What was the first item from the menu purchased by each customer?


WITH CTE AS (
    SELECT 
        sales.customer_id, 
        sales.product_id, 
        sales.order_date, 
        menu.product_name,
        ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date, sales.product_id) AS rn
    FROM 
        dannys_diner.sales sales
    INNER JOIN
        dannys_diner.menu menu
    ON sales.product_id = menu.product_id
)
SELECT 
    customer_id, 
    product_name 
FROM 
    cte
WHERE 
    rn = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?


WITH CTE AS (
    SELECT 
        sales.product_id, 
        COUNT(sales.product_id) AS counter
    FROM 
        dannys_diner.sales sales
    GROUP BY 
        sales.product_id
)
SELECT 
    menu.product_name 
FROM 
    dannys_diner.menu menu
INNER JOIN 
    cte 
    ON menu.product_id = cte.product_id
WHERE 
    cte.counter IN (SELECT MAX(counter) FROM cte);


-- 5. Which item was the most popular for each customer?


WITH CTE AS (
    SELECT 
        sales.customer_id, 
        sales.product_id, 
        COUNT(sales.product_id) AS counter
    FROM 
        dannys_diner.sales sales
    GROUP BY 
        sales.customer_id, sales.product_id
),
SOLUTION AS (
    SELECT 
        cte.customer_id, 
        menu.product_name,
        RANK() OVER(PARTITION BY cte.customer_id ORDER BY cte.counter DESC) AS rn
    FROM 
        cte
    INNER JOIN 
        dannys_diner.menu menu
        ON cte.product_id = menu.product_id
)

SELECT 
    customer_id, product_name 
FROM 
    solution 
WHERE 
    rn = 1;


-- 6. Which item was purchased first by the customer after they became a member?


WITH CTE AS (
    SELECT 
        sales.customer_id, 
        menu.product_name, 
        sales.order_date,
        RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rn
    FROM 
        dannys_diner.sales sales
    INNER JOIN 
        dannys_diner.members members
        ON sales.customer_id = members.customer_id
        AND sales.order_date >= members.join_date
    INNER JOIN 
        dannys_diner.menu menu
        ON sales.product_id = menu.product_id
)

SELECT 
    customer_id, product_name, order_date 
FROM 
    cte
WHERE 
    rn = 1;


-- 7. Which item was purchased just before the customer became a member?


WITH CTE AS (
    SELECT 
        sales.customer_id, 
        menu.product_name, 
        sales.order_date,
        RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS rn
    FROM 
        dannys_diner.sales sales
    INNER JOIN 
        dannys_diner.members members
        ON sales.customer_id = members.customer_id
        AND sales.order_date < members.join_date
    INNER JOIN 
        dannys_diner.menu menu
        ON sales.product_id = menu.product_id
)

SELECT 
    customer_id, product_name, order_date 
FROM 
    cte
WHERE 
    rn = 1;


-- 8. What is the total items and amount spent for each member before they became a member?


SELECT 
    sales.customer_id,
    COUNT(sales.product_id) AS total_items,
    SUM(menu.price) AS amount_spent
FROM 
    dannys_diner.sales sales
INNER JOIN 
    dannys_diner.menu menu
    ON sales.product_id = menu.product_id
INNER JOIN 
    dannys_diner.members members
    ON sales.customer_id = members.customer_id
    AND sales.order_date < members.join_date
GROUP BY 
    sales.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


WITH CTE AS (
    SELECT 
        sales.customer_id,
        CASE WHEN UPPER(menu.product_name) = 'SUSHI' THEN menu.price * 20
             ELSE menu.price * 10 
        END AS points
    FROM 
        dannys_diner.sales sales
    INNER JOIN 
        dannys_diner.menu menu
        ON sales.product_id = menu.product_id
)
SELECT 
    customer_id,
    SUM(points) AS points_earned
FROM 
    cte
GROUP BY 
    customer_id;
 -- I have assumed all members have earned points whether they're members or not


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


WITH CTE AS (
    SELECT 
        sales.customer_id,
        CASE WHEN order_date BETWEEN join_date AND (join_date + INTERVAL '6 days') THEN menu.price * 20
             WHEN UPPER(menu.product_name) = 'SUSHI' THEN menu.price * 20
             ELSE menu.price * 10 
        END AS points
    FROM 
        dannys_diner.sales sales
    INNER JOIN 
        dannys_diner.members members
        ON sales.customer_id = members.customer_id
    INNER JOIN 
        dannys_diner.menu menu
        ON sales.product_id = menu.product_id
    WHERE 
        sales.order_date < '2021-02-01'
)
SELECT 
    customer_id,
    SUM(points) AS points_earned
FROM 
    cte
GROUP BY 
    customer_id;


-- Bonus Questions

-- Join All The Things


SELECT 
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    CASE WHEN members.join_date <= sales.order_date THEN 'Y' ELSE 'N' END AS member_flag
FROM 
    dannys_diner.sales sales
INNER JOIN 
    dannys_diner.menu menu
    ON sales.product_id = menu.product_id
LEFT OUTER JOIN 
    dannys_diner.members members
    ON sales.customer_id = members.customer_id
ORDER BY 
    sales.customer_id, sales.order_date;


-- Rank All The Things


SELECT 
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    'Y' AS member_flag,
    CAST(DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS CHAR) AS ranking
FROM 
    dannys_diner.sales sales
INNER JOIN 
    dannys_diner.menu menu
    ON sales.product_id = menu.product_id
LEFT OUTER JOIN 
    dannys_diner.members members
    ON sales.customer_id = members.customer_id
WHERE 
    members.join_date <= sales.order_date

UNION ALL

SELECT 
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    'N' AS member_flag,
    'NULL' AS ranking
FROM 
    dannys_diner.sales sales
INNER JOIN 
    dannys_diner.menu menu
    ON sales.product_id = menu.product_id
LEFT OUTER JOIN 
    dannys_diner.members members
    ON sales.customer_id = members.customer_id
WHERE 
    members.join_date > sales.order_date
    OR members.join_date IS NULL

ORDER BY 
    customer_id, order_date;
