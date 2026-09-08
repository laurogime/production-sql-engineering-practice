-- ============================================================
-- Assignment 003: Monthly Transaction Summary Report — 2024
-- Grain: one row per (month, transaction_type, channel)
-- Filters: 2024 transactions, non-flagged only
-- Window functions:
--   1. percentage_per_channel: channel share within type and month
--   2. running_total: cumulative amount within type over time
--   3. channel_rank: channel ranked by amount within type and month
-- ============================================================

WITH filtered_transactions AS (
    -- Pre-filter 2024 non-flagged transactions
    -- Sargable date range avoids function on indexed column
    -- Grain: one row per raw transaction
    SELECT
        DATETRUNC(MONTH, transaction_date)  AS transaction_month,
        transaction_type,
        channel,
        amount_aud,
        transaction_id
    FROM dbo.transactions
    WHERE
        transaction_date >= '2024-01-01'
        AND transaction_date  < '2025-01-01'
        AND is_flagged         = 0
),

monthly_aggregates AS (
    -- Aggregate to report grain
    -- Grain: one row per (transaction_month, transaction_type, channel)
    SELECT
        transaction_month,
        transaction_type,
        channel,
        CAST(
            ROUND(SUM(amount_aud), 2)
            AS DECIMAL(18, 2)
        )                                   AS total_transaction,
        COUNT(transaction_id)               AS number_of_transactions,
        CAST(
            ROUND(AVG(amount_aud), 2)
            AS DECIMAL(10, 2)
        )                                   AS avg_transaction
    FROM filtered_transactions
    GROUP BY
        transaction_month,
        transaction_type,
        channel
),

window_metrics AS (
    -- Apply window functions on aggregated data
    -- Cheaper than windowing on raw transaction rows
    SELECT
        transaction_month,
        transaction_type,
        channel,
        total_transaction,
        number_of_transactions,
        avg_transaction,

        -- Channel share within transaction type and month
        CAST(
            ROUND(
                (total_transaction * 100.0)
                / NULLIF(
                    SUM(total_transaction) OVER (
                        PARTITION BY transaction_type, transaction_month
                    ), 0
                ),
            2)
            AS DECIMAL(10, 2)
        )                                   AS percentage_per_channel,

        -- Cumulative amount within transaction type over time
        CAST(
            ROUND(
                SUM(total_transaction) OVER (
                    PARTITION BY transaction_type
                    ORDER BY transaction_month ASC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ),
            2)
            AS DECIMAL(18, 2)
        )                                   AS running_total,

        -- Channel rank by amount within transaction type and month
        -- Highest amount = rank 1
        DENSE_RANK() OVER (
            PARTITION BY transaction_type, transaction_month
            ORDER BY total_transaction DESC
        )                                   AS channel_rank

    FROM monthly_aggregates
)

SELECT
    transaction_month,
    transaction_type,
    channel,
    total_transaction,
    number_of_transactions,
    avg_transaction,
    percentage_per_channel,
    running_total,
    channel_rank
FROM window_metrics
ORDER BY
    transaction_month   ASC,
    transaction_type    ASC,
    channel             ASC;