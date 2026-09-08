-- Assignment 003: Transaction Summary Report
-- Grain: one row per 2024's monthly transaction's type and channel
-- Filters: not flagged transactions

WITH monthly_transaction AS (
    -- Pre-filter not flagged transactions
    -- Setting up all of the necessary columns
    -- Grain: one row per monthly transaction in the year 2024
    SELECT
        DATETRUNC(MONTH, transaction_date) AS monthly_transaction_2024,
        transaction_type,
        channel,
        amount_aud,
        transaction_id
    FROM dbo.transactions
    WHERE 
        transaction_date >= '2024-01-01' 
        AND transaction_date < '2025-01-01'
        AND is_flagged = 0
),

transaction_calculation AS (
    -- grain: one row per 2024's monthly transaction's type and channel
    SELECT
        monthly_transaction_2024,
        transaction_type,
        channel,
        CAST(
            ROUND(SUM(amount_aud), 2)
            AS DECIMAL(18, 2)
        )                                                       AS total_transaction,
        COUNT(transaction_id)                                   AS number_of_transactions,
        CAST(
            ROUND(AVG(amount_aud), 2)
            AS DECIMAL(10, 2)
         )                                                      AS avg_transaction
    FROM  monthly_transaction
    GROUP BY  monthly_transaction_2024, transaction_type, channel
),

window_function_calculation AS (
    SELECT
        monthly_transaction_2024,
        transaction_type,
        channel,
        total_transaction,
        number_of_transactions,
        avg_transaction,
        CAST(ROUND((total_transaction * 100.0) / NULLIF(SUM(total_transaction) OVER (
            PARTITION BY transaction_type, monthly_transaction_2024
        ), 0), 2)
        AS DECIMAL(10, 2)
        )                                                                   AS percentage_per_channel,
        SUM(total_transaction) OVER (
            PARTITION BY transaction_type
            ORDER BY monthly_transaction_2024 ASC
        )                                                                   AS running_total,
        DENSE_RANK() OVER (
            PARTITION BY transaction_type, monthly_transaction_2024
            ORDER BY total_transaction DESC
            )                                                               AS channel_rank
    FROM  transaction_calculation
)

SELECT 
    monthly_transaction_2024,
    transaction_type,
    channel,
    total_transaction,
    number_of_transactions,
    avg_transaction,
    percentage_per_channel,
    running_total,
    channel_rank
FROM window_function_calculation;