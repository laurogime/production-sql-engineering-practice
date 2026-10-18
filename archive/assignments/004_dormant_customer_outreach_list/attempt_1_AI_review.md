A. Overall Assessment

Functionally close but not correct as submitted — one filter bug that produces the wrong grain of customer, plus a real bug in how is_active is being checked. This is Attempt 1 of 3.

B. Correctness

Critical:

WHERE is_active = 0 — go back and check what data type and values this column actually holds. From your own earlier work in this dataset, is_active is a Y/N character flag, not a bit/integer. Comparing a text column to the integer 0 is not the same operation as comparing it to 'N'. Depending on MSSQL's implicit conversion rules here, this either throws a conversion error, silently matches nothing, or — worse — silently matches something you didn't intend. You need to verify which of these actually happened, because your result set returning 14+ visible rows tells you something matched — the question is whether it matched the right thing for the right reason.

Minor:

None yet — I can't evaluate NULL handling, duplicates, or aggregation correctness because this query has none of those surfaces. That's not a gap in your work, just a note that those categories don't apply to this particular assignment.

Correct decisions:

CONCAT for the full name — reasonable, and you'd need to justify column order/separator choices if asked, which you have.
C. Data Grain
Intended grain: one row per currently-inactive customer.
Your query's actual grain: one row per customer matching is_active = 0 — which may not be the same population as "inactive," depending on the answer to the correctness bug above. This is the core issue: grain isn't just about JOINs multiplying rows — it's also about whether your filter predicate actually selects the population the business asked for. If is_active = 0 matches zero rows, an unexpected set of rows, or throws, your grain is wrong or your query doesn't run at all.
No JOINs, CTEs, subqueries, or window functions here, so no cardinality risk from those — single table, single filter, single sort. That part of the design is appropriately simple for what was asked.
D. Code Quality & Structure
Header comment block (assignment, grain, filters) — good habit, and exactly the kind of thing that helps another engineer understand intent at a glance without reading the query body.
Clean formatting, consistent capitalization, sensible aliasing.
Nothing to restructure here — this is a simple enough task that CTE/subquery organization isn't warranted, and adding it would be over-engineering.
E. SQL Best Practices
The is_active = 0 issue is the main anti-pattern to address here: relying on implicit type coercion between a character column and a numeric literal is a bad assumption about the schema, and it's the kind of thing that either fails loudly (best case) or fails silently (worst case, and much harder to catch in production).
No unnecessary operations, no redundant logic — the query is otherwise minimal and appropriate.
F. Performance
A single WHERE on an unindexed-by-default flag column plus an ORDER BY on a date column, over what's currently a small table — negligible cost at this scale regardless of the correctness issue. Nothing here is inherently inefficient; the performance conversation only becomes meaningful once we're talking about table size (see Scalability) or if this predicate bug causes a full scan pattern that wouldn't otherwise be necessary — but that's not really a performance question, it's the correctness question wearing a performance costume.
G. Scalability
At production/large scale, this exact shape (single equality filter + sort) is fine in principle — but a query that resolves its filter incorrectly doesn't get graded on scalability yet, because scaling an incorrect query just means producing the wrong answer faster and to more people. Fix correctness first; the scalability profile of the corrected version will look identical to this one, structurally.
H. Cost Efficiency
Not a meaningful axis to evaluate yet for the same reason as Performance — a query that isn't confirmed to filter correctly doesn't have a cost-efficiency story worth analyzing on top of that.
I. Edge Cases

Relevant ones for this assignment specifically:

What does is_active actually contain, and did your comparison operator match its real representation? (Already flagged above — this is the central edge case here, not a side note.)
Ties on date_joined — if two customers joined on the same date, your ORDER BY doesn't define a secondary tiebreaker. Is that acceptable for this business ask, or does "prioritize by tenure" imply the team would want a deterministic, repeatable order every time this report runs?
NULLs — does every customer have a non-null date_joined? If not, where would ORDER BY ... ASC put those rows, and is that where the business would want them?
J. Production Readiness

Not yet — the filter correctness question has to be resolved and verified before anything else here is meaningfully assessable as production-bound.

K. Production Verdict

❌ REQUEST CHANGES

L. Score

4/10 — clean formatting and good intent, but the central filter may not be doing what you think it's doing, and until you've confirmed that, the rest of the review is provisional.