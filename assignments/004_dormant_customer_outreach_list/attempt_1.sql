-- Assignment 004: Dormant Customer Outreach List
-- Grain: one row per inactive customers
-- Filters: inactive

SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    state,
    date_joined
FROM dbo.customers
WHERE is_active = 0
ORDER BY date_joined ASC;
