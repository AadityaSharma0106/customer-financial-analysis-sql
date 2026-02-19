CREATE DATABASE finance_project;
USE finance_project;

# Preview the data
select * 
from customer_financial_profiles
limit 10;

# Check missing values
SELECT 
COUNT(*) AS total_rows,
COUNT(current_age) AS age_not_null,
COUNT(per_capita_income) AS income_not_null,
COUNT(credit_score) AS credit_not_null
FROM customer_financial_profiles;	

# Check duplicates
SELECT id,
    COUNT(*) AS duplicate_count
FROM customer_financial_profiles
GROUP BY id
HAVING COUNT(*) > 1;

# Custom table
CREATE TABLE customers AS
SELECT DISTINCT
    client_id,
    current_age,
    birth_year,
    birth_month,
    gender,
    address,
    per_capita_income,
    yearly_income,
    total_debt,
    credit_score,
    num_credit_cards
FROM customer_financial_profiles;

CREATE TABLE transactions AS
SELECT
    transaction_id,
    client_id,
    date,
    amount,
    use_chip,
    merchant_id,
    merchant_city,
    merchant_state,
    zip
FROM customer_financial_profiles;

# Age distribution
SELECT 
    CASE
        WHEN current_age < 25 THEN '18-24'
        WHEN current_age BETWEEN 25 AND 34 THEN '25-34'
        WHEN current_age BETWEEN 35 AND 44 THEN '35-44'
        WHEN current_age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS customer_count
FROM customers
GROUP BY age_group
ORDER BY customer_count DESC;

# Counting of male and female
SELECT gender, COUNT(*) AS count
FROM customers
GROUP BY gender;

# State wise customers
SELECT 
    SUBSTRING_INDEX(address, ',', -1) AS state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;

# Revenue Analysis
# Total revenue generated
SELECT 
    SUM(amount) AS total_revenue
FROM transactions;

# Revenue per customers
SELECT 
    client_id,
    SUM(amount) AS revenue_per_customer
FROM transactions
GROUP BY client_id
ORDER BY revenue_per_customer DESC;

# Revenue by city
SELECT 
    merchant_city,
    SUM(amount) AS city_revenue
FROM transactions
GROUP BY merchant_city
ORDER BY city_revenue DESC;

# Profitability Segmentation
# High-Value Customers
SELECT 
    client_id,
    SUM(amount) AS total_spent,
    AVG(credit_score) AS avg_credit_score
FROM customer_financial_profiles
GROUP BY client_id
HAVING total_spent > 50000
ORDER BY total_spent DESC;

# Risk Analysis
# High-Risk Customers
SELECT 
    client_id,
    credit_score,
    total_debt
FROM customer_financial_profiles
WHERE credit_score < 600
   OR total_debt > 300000;

# Risk Segmentation
SELECT 
    CASE
        WHEN credit_score >= 750 THEN 'Low Risk'
        WHEN credit_score BETWEEN 650 AND 749 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_category,
    COUNT(*) AS customer_count
FROM customers
GROUP BY risk_category;

#Churn Indicators
# Low Engagement Customers
SELECT 
    client_id,
    COUNT(*) AS total_transactions
FROM customer_financial_profiles
GROUP BY client_id
HAVING COUNT(*) < 5
ORDER BY total_transactions;

# Profitability vs Risk
# High Value but Risky Customers
SELECT 
    client_id,
    SUM(amount) AS total_spent,
    AVG(credit_score) AS avg_credit_score
FROM customer_financial_profiles
GROUP BY client_id
HAVING total_spent > 40000
   AND avg_credit_score < 650;

# Advanced level
# Debt to Income ratio (DTi)
SELECT 
    client_id,
    total_debt / yearly_income AS dti_ratio
FROM customers
ORDER BY dti_ratio DESC;

# Customer Lifetime Value (CLV)
SELECT 
    client_id,
    COUNT(*) AS transactions,
    SUM(amount) AS lifetime_value
FROM transactions
GROUP BY client_id
ORDER BY lifetime_value DESC;

# Revenue by Risk Category
SELECT 
    CASE
        WHEN c.credit_score >= 750 THEN 'Low Risk'
        WHEN c.credit_score BETWEEN 650 AND 749 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_category,
    SUM(t.amount) AS revenue
FROM customers c
JOIN transactions t
ON c.client_id = t.client_id
GROUP BY risk_category;
