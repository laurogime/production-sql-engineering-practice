## Code Review — Attempt 1

---

### A. Overall Assessment
Strong first attempt at window functions. The CTE layering is clean, the grain is correct, and three window functions are implemented. There are two logical errors in the window functions that produce incorrect results, and one production-quality issue with the percentage column. The foundation is solid.

---

### B. Correctness

**Critical issues:**

- **`running_total` is ordered `DESC` — this is logically wrong for a running total.** A running total accumulates forward in time — January adds to February, February adds to March. `ORDER BY monthly_transaction_2024 DESC` accumulates backward, meaning the most recent month shows the smallest value and earlier months show larger values. The correct direction is `ASC`.

- **`DENSE_RANK()` ordered `ASC` — ranks the lowest amount as 1.** The assignment asks for the highest amount ranked 1. Your `ORDER BY total_transaction` without `DESC` means the smallest channel amount gets rank 1. Add `DESC`.

**Minor issues:**
- `percentage_per_channel` is showing 15+ decimal places — `NULLIF` is correctly used to prevent division by zero, but the result needs `ROUND(..., 2)` and `CAST AS DECIMAL(10, 2)` for production financial output.
- `row_num` is a misleading alias for a rank — `channel_rank` better communicates intent.
- `is_flagged = 0` — confirm `is_flagged` is stored as an integer `0/1` and not `'N'/'Y'`. If it's a character type, this filter silently returns no rows on some configurations.

**Correct decisions:**
- `DATETRUNC(MONTH, transaction_date)` — correct and clean for monthly grouping ✅
- Date range filter using `>= '2024-01-01' AND < '2025-01-01'` — correct, sargable, and index-friendly ✅
- `NULLIF(..., 0)` in percentage denominator — correct NULL safety ✅
- `SUM OVER PARTITION BY transaction_type, monthly_transaction_2024` for percentage — correct window ✅
- `DENSE_RANK()` chosen over `RANK()` — appropriate since ties should share the same rank ✅
- Three-CTE layering separates concerns cleanly ✅

---

### C. Data Grain

**Intended grain:** One row per `(month, transaction_type, channel)`

**Actual grain:** Matches — one row per `(monthly_transaction_2024, transaction_type, channel)` ✅

**Window function grain:**
- `percentage_per_channel` — partitioned by `(transaction_type, month)` — correct, gives channel share within type and month ✅
- `running_total` — partitioned by `transaction_type`, ordered by month — correct partition, wrong sort direction ⚠️
- `DENSE_RANK()` — partitioned by `(transaction_type, month)`, ordered by amount — correct partition, wrong sort direction ⚠️

---

### D. Code Quality & Structure

- Three-CTE structure with clear separation of responsibilities ✅
- Comments on each CTE explaining grain and purpose ✅
- Consistent alignment and formatting ✅
- `row_num` alias is misleading for a rank value ⚠️
- Percentage column lacks rounding ⚠️

---

### E. SQL Best Practices

- Running total direction error is a classic window function mistake — always ask "does this accumulate in the direction time flows?"
- Rank direction error — always re-read "highest ranked 1" vs "lowest ranked 1" explicitly
- Financial percentages without rounding are not production-ready

---

### F. Performance

- Early filtering in `monthly_transaction` CTE reduces rows before aggregation ✅
- `DATETRUNC` on `transaction_date` in `WHERE` — note this is applied to the raw column before filtering, which is fine here since the range filter `>= / <` is sargable ✅
- Window functions computed in a separate CTE after aggregation — efficient, avoids recomputing raw row-level windows ✅

---

### G. Scalability

- Filtering 2024 data early limits the working dataset ✅
- Three-layer CTE approach means each layer processes only what it needs ✅
- Window functions on already-aggregated data — much cheaper than windowing on raw transaction rows ✅

---

### H. Cost Efficiency

- Efficient design overall ✅
- Two fixable errors aside, the compute pattern is appropriate for production ✅

---

### I. Edge Cases

- `NULLIF(..., 0)` handles zero-sum partition ✅
- Months with no transactions are naturally excluded — acceptable for this report
- `is_flagged` type assumption — worth verifying ⚠️

---

### J. Production Readiness

Not production-ready due to the two window function direction errors and unrounded percentage. All three are small fixes.

---

### K. Production Verdict

⚠️ APPROVE WITH CHANGES

---

### L. Score: 7.5/10

Solid first attempt at window functions. The architecture is production-appropriate and the partition logic is correct — the errors are in sort directions, which are easy to fix once you understand why they matter. Fix the three issues and resubmit.