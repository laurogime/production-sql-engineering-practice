-- Problem 01: Dormant Customer Outreach List
-- Difficulty: Easy
-- Date: 2026-10-19

-- The Customer Retention team needs a list of inactive
-- customers, prioritizing those who joined earliest.

-- Deliver: Full name, state, and date joined.

SELECT 
    customer_id,
    CONCAT(last_name, ', ', first_name) AS full_name,
    state,
    date_joined
FROM dbo.customers
WHERE is_active = 0
ORDER BY 
    date_joined ASC, 
    full_name ASC,
    customer_id ASC;
    

-- Problem 02: Premium Invite Shortlist
-- Difficulty: Easy
-- Date: 2026-10-19

-- The Product team wants to invite the 15 highest-income
-- customers to participate in a premium-tier pilot.

-- Deliver: Full name, city, state, and annual income.
-- Prioritize customers with the highest income.
-- Ensure consistent ordering when incomes are equal.


SELECT TOP 15
    customer_id,
    CONCAT(last_name, ', ', first_name) AS full_name,
    city,
    state,
    annual_income_aud
FROM dbo.customers
ORDER BY 
    annual_income_aud DESC, 
    full_name ASC, 
    customer_id ASC;



