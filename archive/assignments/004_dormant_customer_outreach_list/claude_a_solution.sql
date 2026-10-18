-- =============================================================================
-- Assignment 004: Dormant Customer Outreach List
-- =============================================================================
-- Grain      : One row per inactive customer. customers.customer_id is the
--              table's natural key; no JOINs are involved, so there is no
--              fan-out risk and the output grain matches the source grain 1:1.
-- Filter     : is_active = 0 (BIT, NOT NULL — confirmed via sp_help).
--              ASSUMPTION: 0 = inactive, 1 = active, based on the standard
--              is_<X> naming convention. This is NOT independently verified
--              against a data dictionary or business documentation — flag to
--              the data owner before this list drives a real campaign.
-- Ordering   : date_joined ASC (earliest-joined / longest-standing customers
--              first, per "prioritize by tenure"), with customer_id ASC as a
--              deterministic tiebreaker. date_joined alone is not guaranteed
--              unique across customers; an outreach list that silently
--              reorders itself between identical runs is not acceptable for
--              a repeatable operational report.
-- =============================================================================

SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    state,
    date_joined
FROM dbo.customers
WHERE is_active = 0
ORDER BY
    date_joined ASC,
    customer_id ASC;

-- =============================================================================

-- Tiebreaker confirmation:
SELECT date_joined, COUNT(*) AS occurrences
FROM dbo.customers
WHERE is_active = 0
GROUP BY date_joined
HAVING COUNT(*) > 1;