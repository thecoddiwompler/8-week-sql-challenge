# [8-Week SQL Challenge](https://github.com/thecoddiwompler/8-week-sql-challenge)
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/thecoddiwompler/8-week-sql-challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/thecoddiwompler?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/thecoddiwompler)


# 🍕 Case Study #2 - Pizza Runner
<p align="center">
<img src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/pizza_runner.png" width=50% height=50%>

## 📕 Table Of Contents
- [8-Week SQL Challenge](#8-week-sql-challenge)
- [🍕 Case Study #2 - Pizza Runner](#-case-study-2---pizza-runner)
  - [📕 Table Of Contents](#-table-of-contents)
  - [Overview](#overview)
  - [🛠️ Problem Statement](#️-problem-statement)
  - [🛠️ ER Diagram](#️-er-diagram)
- [Pizza Runner SQL Case Study](#pizza-runner-sql-case-study)
  - [A. Pizza Metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience](#b-runner-and-customer-experience)
  - [C. Ingredient Optimization](#c-ingredient-optimization)
  - [D. Pricing and Ratings](#d-pricing-and-ratings)
  - [E. Bonus Questions](#e-bonus-questions)

---

## Overview

- **Data Inspection:** Before diving into the questions, investigate the data, and consider handling null values and data types in the customer_orders and runner_orders tables.


## 🛠️ Problem Statement

> Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)
>
> Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”
> 
> Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so **Pizza Runner** was launched!
> 
> Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

---
  
---
  
## 🛠️ ER Diagram

<p align="center">
<img src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/Pizza%20Runner.png" width=100% height=100%>
  
---

# Pizza Runner SQL Case Study

This case study has LOTS of questions - they are broken up by area of focus including:

- Pizza Metrics
- Runner and Customer Experience
- Ingredient Optimisation
- Pricing and Ratings
- Bonus DML Challenges (DML = Data Manipulation Language)

Each of the following case study questions can be answered using a single SQL statement.

Again, there are many questions in this case study - please feel free to pick and choose which ones you’d like to try!

Before you start writing your SQL queries, however - you might want to investigate the data; you may want to do something with some of those null values and data types in the customer_orders and runner_orders tables!



## A. Pizza Metrics

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?


## B. Runner and Customer Experience

11. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
12. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?
13. Is there any relationship between the number of pizzas and how long the order takes to prepare?
14. What was the average distance traveled for each customer?
15. What was the difference between the longest and shortest delivery times for all orders?
16. What was the average speed for each runner for each delivery, and do you notice any trends for these values?
17. What is the successful delivery percentage for each runner?

## C. Ingredient Optimization

18. What are the standard ingredients for each pizza?
19. What was the most commonly added extra?
20. What was the most common exclusion?
21. Generate an alphabetically ordered comma-separated ingredient list for each pizza order in the format of one of the following:**
       - Meat Lovers
       - Meat Lovers - Exclude Beef
       - Meat Lovers - Extra Bacon
       - Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
22. Generate an alphabetically ordered comma-separated ingredient list for each pizza order from the `customer_orders` table and add a 2x in front of any relevant ingredients.
   - For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" 

23. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

## D. Pricing and Ratings

24. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
25. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra.
26. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner. How would you design an additional table for this new dataset? Generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
27. Using your newly generated table, can you join all of the information together to form a table which has the following information for successful deliveries?
       - customer_id
       - order_id
       - runner_id
       - rating
       - order_time
       - pickup_time
       - Time between order and pickup
       - Delivery duration
       - Average speed
       - Total number of pizzas
28. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras, and each runner is paid $0.30 per kilometer traveled - how much money does Pizza Runner have left over after these deliveries?


## E. Bonus Questions

29. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

Feel free to choose and answer the questions that interest you. Happy querying!
