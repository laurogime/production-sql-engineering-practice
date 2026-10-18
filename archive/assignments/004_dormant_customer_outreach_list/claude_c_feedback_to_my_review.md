Good question to ask before assuming the code is wrong — but look at the production solution again, specifically the ORDER BY clause:

sql
ORDER BY
    date_joined ASC,
    customer_id ASC;

customer_id ASC is the tiebreaker. It's not missing — it's the second column in the ORDER BY. When two rows have the same date_joined (like your two 2019-09-26 rows), SQL Server falls back to sorting by customer_id to decide their relative order, which resolves the tie deterministically since customer_id is unique.

So this one is:

❌ Not actually an issue — the tiebreaker is present; it may just not have been obvious as a "tiebreaker" because it's expressed as a second ORDER BY column rather than as a separately labeled clause. That's actually the standard way tiebreakers are implemented in SQL — there's no dedicated "tiebreaker" keyword; a tiebreaker is just an additional column added to ORDER BY, evaluated only when everything before it is equal.