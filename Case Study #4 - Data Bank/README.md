# [8-Week SQL Challenge](https://github.com/thecoddiwompler/8-week-sql-challenge)
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/thecoddiwompler/8-week-sql-challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/thecoddiwompler?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/thecoddiwompler)

## Case Study #4: Data Bank

<img src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/data_bank.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [8-Week SQL Challenge](#8-week-sql-challenge)
  - [Case Study #4: Data Bank](#case-study-4-data-bank)
  - [📚 Table of Contents](#-table-of-contents)
  - [Business Task](#business-task)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
  - [A. Customer Nodes Exploration](#a-customer-nodes-exploration)
  - [B. Customer Transactions](#b-customer-transactions)
  - [C. Data Allocation Challenge](#c-data-allocation-challenge)
  - [D. Extra Challenge](#d-extra-challenge)
  - [Extension Request](#extension-request)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-4/). 

***

## Business Task
Danny launched a new initiative, Data Bank which runs **banking activities** and also acts as the world’s most secure distributed **data storage platform**!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. 

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Entity Relationship Diagram

<img width="631" alt="image" src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/databank_er_diagram.png">

**Table 1: `regions`**

This regions table contains the `region_id` and their respective `region_name` values.

<img width="176" alt="image" src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/databank_regions.png">

**Table 2: `customer_nodes`**

Customers are randomly distributed across the nodes according to their region. This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

<img width="412" alt="image" src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/databank_customer_nodes.png">

**Table 3: Customer Transactions**

This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.

<img width="343" alt="image" src="https://github.com/thecoddiwompler/8-week-sql-challenge/blob/main/IMG/databank_customer_transactions.png">

***

# Case Study Questions

## A. Customer Nodes Exploration

1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th, and 95th percentile for this same reallocation days metric for each region?

## B. Customer Transactions

6. What is the unique count and total amount for each transaction type?
7. What is the average total historical deposit counts and amounts for all customers?
8. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
9. What is the closing balance for each customer at the end of the month?
10. What is the percentage of customers who increase their closing balance by more than 5%?

## C. Data Allocation Challenge

To test out a few different hypotheses, the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

- Option 1: data is allocated based on the amount of money at the end of the previous month
- Option 2: data is allocated based on the average amount of money kept in the account in the previous 30 days
- Option 3: data is updated real-time

For this multi-part challenge question, you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

- running customer balance column that includes the impact each transaction
- customer balance at the end of each month
- minimum, average, and maximum values of the running balance for each customer

Using all of the data available, how much data would have been required for each option on a monthly basis?

## D. Extra Challenge

Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Special notes:

- Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!

## Extension Request

The Data Bank team wants you to use the outputs generated from the above sections to create a quick Powerpoint presentation which will be used as marketing materials for both external investors who might want to buy Data Bank shares and new prospective customers who might want to bank with Data Bank.

Using the outputs generated from the customer node questions, generate a few headline insights which Data Bank might use to market it’s world-leading security features to potential investors and customers.

With the transaction analysis - prepare a 1 page presentation slide which contains all the relevant information about the various options for the data provisioning so the Data Bank management team can make an informed decision.