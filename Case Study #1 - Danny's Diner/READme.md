# [8-Week SQL Challenge](https://github.com/thecoddiwompler/8-week-sql-challenge)
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/thecoddiwompler/8-week-sql-challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/thecoddiwompler?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/thecoddiwompler)

# 🍜 Case Study #1 - Danny's Diner
<p align="center">
<img src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/diner.png" width=50% height=50%>

## 📚 Table of Contents
- [8-Week SQL Challenge](#8-week-sql-challenge)
- [🍜 Case Study #1 - Danny's Diner](#-case-study-1---dannys-diner)
  - [📚 Table of Contents](#-table-of-contents)
  - [🛠️ Problem Statement](#️-problem-statement)
  - [🛠️ ER Diagram](#️-er-diagram)
  - [📂 Dataset](#-dataset)
    - [**```sales```**](#sales)
    - [**```menu```**](#menu)
    - [**```members```**](#members)
  - [🛠️ Questions](#️-questions)
  - [🚀 Bonus Questions](#-bonus-questions)

---

## 🛠️ Problem Statement

> Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
>
> You can inspect the entity relationship diagram and example data below.
  
---
  
## 🛠️ ER Diagram

<p align="center">
<img src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/Danny's%20Diner.png" width=100% height=100%>
  
---

## 📂 Dataset
Danny has shared with you 3 key datasets for this case study:

### **```sales```**

<details>
<summary>
View table
</summary>

The sales table captures all ```customer_id``` level purchases with an corresponding ```order_date``` and ```product_id``` information for when and what menu items were ordered.

|customer_id|order_date|product_id|
|-----------|----------|----------|
|A          |2021-01-01|1         |
|A          |2021-01-01|2         |
|A          |2021-01-07|2         |
|A          |2021-01-10|3         |
|A          |2021-01-11|3         |
|A          |2021-01-11|3         |
|B          |2021-01-01|2         |
|B          |2021-01-02|2         |
|B          |2021-01-04|1         |
|B          |2021-01-11|1         |
|B          |2021-01-16|3         |
|B          |2021-02-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-07|3         |

 </details>

### **```menu```**

<details>
<summary>
View table
</summary>

The menu table maps the ```product_id``` to the actual ```product_name``` and price of each menu item.

|product_id |product_name|price     |
|-----------|------------|----------|
|1          |sushi       |10        |
|2          |curry       |15        |
|3          |ramen       |12        |

</details>

### **```members```**

<details>
<summary>
View table
</summary>

The final members table captures the ```join_date``` when a ```customer_id``` joined the beta version of the Danny’s Diner loyalty program.

|customer_id|join_date |
|-----------|----------|
|A          |1/7/2021  |
|B          |1/9/2021  |

 </details>


## 🛠️ Questions

1. What is the total amount spent by each customer at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu, and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What are the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


## 🚀 Bonus Questions

1. Join all the things - Recreate the following table output using the available data:

   | customer_id | order_date | product_name | price | member |
    |-------------|------------|--------------|-------|--------|
    | A           | 2021-01-01 | curry        | 15    | N      |
    | A           | 2021-01-01 | sushi        | 10    | N      |
    | A           | 2021-01-07 | curry        | 15    | Y      |
    | A           | 2021-01-10 | ramen        | 12    | Y      |
    | A           | 2021-01-11 | ramen        | 12    | Y      |
    | A           | 2021-01-11 | ramen        | 12    | Y      |
    | B           | 2021-01-01 | curry        | 15    | N      |
    | B           | 2021-01-02 | curry        | 15    | N      |
    | B           | 2021-01-04 | sushi        | 10    | N      |
    | B           | 2021-01-11 | sushi        | 10    | Y      |
    | B           | 2021-01-16 | ramen        | 12    | Y      |
    | B           | 2021-02-01 | ramen        | 12    | Y      |
    | C           | 2021-01-01 | ramen        | 12    | N      |
    | C           | 2021-01-01 | ramen        | 12    | N      |
    | C           | 2021-01-07 | ramen        | 12    | N      |


2. Rank All The Things - Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program. Output the following table:

    | customer_id | order_date | product_name | price | member | ranking |
    |-------------|------------|--------------|-------|--------|---------|
    | A           | 2021-01-01 | curry        | 15    | N      | null    |
    | A           | 2021-01-01 | sushi        | 10    | N      | null    |
    | A           | 2021-01-07 | curry        | 15    | Y      | 1       |
    | A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
    | A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
    | A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
    | B           | 2021-01-01 | curry        | 15    | N      | null    |
    | B           | 2021-01-02 | curry        | 15    | N      | null    |
    | B           | 2021-01-04 | sushi        | 10    | N      | null    |
    | B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
    | B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
    | B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
    | C           | 2021-01-01 | ramen        | 12    | N      | null    |
    | C           | 2021-01-01 | ramen        | 12    | N      | null    |
    | C           | 2021-01-07 | ramen        | 12    | N      | null    |
