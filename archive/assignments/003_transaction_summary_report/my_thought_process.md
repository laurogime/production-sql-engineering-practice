## planning stage process before attempting:
- I was inspecting all of the columns in the transactions table and running some syntax to check the results, especially on the type and channel if both are disctinct or not.  

## columns: 
dbo.transactions:
- months
- total transaction amount
- number of transactions
- average transaction amount

## additional columns:
- percentage of the channel's total monthly transaction amount within type
- running total of transaction amount within transaction type, ordered by month desc
- ranking of channels within type and month by total amount, with the highest of ranked 1

## aggregations:
- months
- transaction type
- channel

## filters:
- monthly in the year 2024
- transactions that is not flagged

## grain:
- one row per 2024's monthly transaction type and channel

## after attempt 1:
- I correctly structured the queries with some minor issues needed to fix
- I think this is so far my best first attempt
