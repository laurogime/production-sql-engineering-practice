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

-- Checking the ddata types
EXEC sp_help 'dbo.customers';

-- Conclusion: I confirmed that the data type of is_active column is bit. Therefore, WHERE filter is correct.
