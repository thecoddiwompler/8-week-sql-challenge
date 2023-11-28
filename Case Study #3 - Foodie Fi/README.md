# [8-Week SQL Challenge](https://github.com/thecoddiwompler/8-week-sql-challenge)
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/thecoddiwompler/8-week-sql-challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/thecoddiwompler?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/thecoddiwompler)

# 🥑 Case Study #3: Foodie-Fi

<img src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/foodiefi.png" width="500" height="520" alt="image">

## 📚 Table of Contents
- [8-Week SQL Challenge](#8-week-sql-challenge)
- [🥑 Case Study #3: Foodie-Fi](#-case-study-3-foodie-fi)
  - [📚 Table of Contents](#-table-of-contents)
  - [Business Task](#business-task)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
- [Foodie-Fi Data Analysis Questions](#foodie-fi-data-analysis-questions)
  - [General Information](#general-information)
  - [Trial Plan Analysis](#trial-plan-analysis)
  - [Plan Date Analysis](#plan-date-analysis)
  - [Churn Analysis](#churn-analysis)
  - [Plan Status Analysis](#plan-status-analysis)
  - [Plan Breakdown at Specific Date](#plan-breakdown-at-specific-date)
  - [Annual Plan Upgrade Analysis](#annual-plan-upgrade-analysis)
  - [Average Days to Annual Plan](#average-days-to-annual-plan)
  - [Average Days to Annual Plan Breakdown](#average-days-to-annual-plan-breakdown)
  - [Monthly Downgrade Analysis](#monthly-downgrade-analysis)
- [Challenge Payment Question](#challenge-payment-question)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***

## Business Task
Danny and his friends launched a new startup Foodie-Fi and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world.

This case study focuses on using subscription style digital data to answer important business questions on customer journey, payments, and business performances.

## Entity Relationship Diagram

![image](https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/foodiefi_er_diagram.png)

**Table 1: `plans`**

<img width="207" alt="image" src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/foodiefi_plans.png">

There are 5 customer plans.

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their Foodie-Fi service — they will have a Churn plan record with a null price, but their plan will continue until the end of the billing period.

**Table 2: `subscriptions`**

<img width="245" alt="image" src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/foodiefi_subscriptions.png">

Customer subscriptions show the **exact date** where their specific `plan_id` starts.

If customers downgrade from a pro plan or cancel their subscription — the higher plan will remain in place until the period is over — the `start_date` in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan — the higher plan will take effect straightaway.

When customers churn, they will keep their access until the end of their current billing period, but the start_date will be technically the day they decided to cancel their service.

***

# Foodie-Fi Data Analysis Questions
***

## General Information

1. How many customers has Foodie-Fi ever had?

## Trial Plan Analysis

2. What is the monthly distribution of trial plan `start_date` values for our dataset? Use the start of the month as the group by value.

## Plan Date Analysis

3. What `plan_start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`.

## Churn Analysis

4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

5. How many customers have churned straight after their initial free trial? What percentage is this rounded to the nearest whole number?

## Plan Status Analysis

6. What is the number and percentage of customer plans after their initial free trial?

## Plan Breakdown at Specific Date

7. What is the customer count and percentage breakdown of all 5 `plan_name` values at 2020-12-31?

## Annual Plan Upgrade Analysis

8. How many customers have upgraded to an annual plan in 2020?

## Average Days to Annual Plan

9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

## Average Days to Annual Plan Breakdown

10. Can you further breakdown the average value into 30 day periods (i.e., 0-30 days, 31-60 days, etc.)?

## Monthly Downgrade Analysis

11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


# Challenge Payment Question
***

The Foodie-Fi team requires the creation of a new payments table for the year 2020, detailing amounts paid by each customer in the subscriptions table. The table should adhere to the following specifications:

1. **Monthly Payments:**
   - Monthly payments always occur on the same day of the month as the original `start_date` of any monthly paid plan.

2. **Upgrades from Basic to Monthly or Pro Plans:**
   - Upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately.

3. **Upgrades from Pro Monthly to Pro Annual:**
   - Upgrades from pro monthly to pro annual are paid at the end of the current billing period and also start at the end of the month period.

4. **Churned Customers:**
   - Once a customer churns, they will no longer make payments.

Example outputs for this table might look like the following:

| customer_id | plan_id |   plan_name   | start_date | price  | payment_order |
|-------------|---------|---------------|------------|--------|---------------|
| 15          | 2       | pro monthly   | 2020-03-24 | 19.90  | 1             |
| 16          | 1       | basic monthly | 2020-06-07 | 9.90   | 1             |
| 16          | 3       | pro annual    | 2020-10-21 | 199.00 | 2             |
| 17          | 1       | basic monthly | 2020-08-03 | 9.90   | 1             |
| 17          | 3       | pro annual    | 2020-12-11 | 199.00 | 2             |
| 18          | 2       | pro monthly   | 2020-07-13 | 19.90  | 1             |
| 19          | 2       | pro monthly   | 2020-06-29 | 19.90  | 1             |
| 19          | 3       | pro annual    | 2020-08-29 | 199.00 | 2             |
| 20          | 1       | basic monthly | 2020-04-15 | 9.90   | 1             |
| 20          | 3       | pro annual    | 2020-06-05 | 199.00 | 2             |
| 21          | 1       | basic monthly | 2020-02-11 | 9.90   | 1             |
| 21          | 2       | pro monthly   | 2020-06-03 | 19.90  | 2             |
| 22          | 2       | pro monthly   | 2020-01-17 | 19.90  | 1             |
| 23          | 3       | pro annual    | 2020-05-20 | 199.00 | 1             |
| 24          | 2       | pro monthly   | 2020-11-17 | 19.90  | 1             |
| 25          | 1       | basic monthly | 2020-05-17 | 9.90   | 1             |
| 25          | 2       | pro monthly   | 2020-06-16 | 19.90  | 2             |
| 26          | 2       | pro monthly   | 2020-12-15 | 19.90  | 1             |
| 27          | 2       | pro monthly   | 2020-08-31 | 19.90  | 1             |
| 28          | 3       | pro annual    | 2020-07-07 | 199.00 | 1             |
| 29          | 2       | pro monthly   | 2020-01-30 | 19.90  | 1             |
| 30          | 1       | basic monthly | 2020-05-06 | 9.90   | 1             |
| 31          | 2       | pro monthly   | 2020-06-29 | 19.90  | 1             |
| 31          | 3       | pro annual    | 2020-11-29 | 199.00 | 2             |
| 32          | 1       | basic monthly | 2020-06-19 | 9.90   | 1             |
| 32          | 2       | pro monthly   | 2020-07-18 | 10.00  | 2             |
| 33          | 2       | pro monthly   | 2020-09-10 | 19.90  | 1             |
| 34          | 1       | basic monthly | 2020-12-27 | 9.90   | 1             |
| 35          | 2       | pro monthly   | 2020-09-10 | 19.90  | 1             |
| 36          | 2       | pro monthly   | 2020-03-03 | 19.90  | 1             |

