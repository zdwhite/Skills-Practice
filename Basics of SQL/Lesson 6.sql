### Window Functions 1

/* Create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. Your final table should have two columns: one with the amount being added for each new row, and a second with the running total.*/

SELECT standard_amt_usd, SUM(standard_amt_usd) OVER (ORDER BY occurred_at) as running_total
FROM orders o

/* this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable. Your final table should have three columns: One with the amount being added for each row, one for the truncated date, and a final column with the running total within each year. */

WITH t1 as (SELECT occurred_at,standard_amt_usd, DATE_PART('year',occurred_at) as yop
FROM orders)

SELECT yop,standard_amt_usd,SUM(standard_amt_usd) OVER (PARTITION BY yop ORDER BY occurred_at) as running_total
from t1

/* Select the id, account_id, and total from the orders table, then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition. Your final table should have these four columns.

*/

SELECT o.id, o.account_id, o.total , RANK() OVER (PARTITION BY account_id ORDER BY total desc) as total_rank
FROM orders as o

/* Run the query that Derek wrote in the previous video in the first SQL Explorer below. Keep the query results in mind; you'll be comparing them to the results of another query next.

Now remove ORDER BY DATE_TRUNC('month',occurred_at) in each line of the query that contains it in the SQL Explorer below. Evaluate your new query, compare it to the results in the SQL Explorer above, and answer the subsequent quiz questions.
*/

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ) AS max_std_qty
FROM orders

	/* The function is being applied over the partition window as a whole and not being sub-divied by month.*/
	
/*  create and use an alias to shorten the following query (which is different than the one in Derek's previous video) that has multiple window functions. Name the alias account_year_window, which is more descriptive than main_window in the example above.*/

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))


### LAG AND LEAD

/* In the previous video, Derek outlines how to compare a row to a previous or subsequent row. This technique can be usefuld when analyzing time-based events. Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total revenue ("total" meaning from sales of all types of paper) compares to the next order's total revenue.

Modify Derek's query from the previous video in the SQL Explorer below to perform this analysis. You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so. In your query results, there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference. */

SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) as lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
) sub

### Quiz Percentiles
SELECT  id,
		account_id,
		occurred_at,
		standard_qty,
		NTILE(4) OVER (ORDER BY standard_qty) as quartile,
		NTILE(5) OVER (ORDER BY standard_qty) as quintile,
		NTILE(100) OVER (ORDER BY standard_qty) as percentile
	FROM orders
	ORDER BY standard_qty desc


/* Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column*/

SELECT  account_id,
		occurred_at,
		standard_qty,
		NTILE(4) OVER (ORDER BY standard_qty) as standard_quartile
	FROM orders
	ORDER BY standard_qty desc

/* Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.*/

SELECT  account_id,
		occurred_at,
		gloss_qty,
		NTILE(2) OVER (ORDER BY gloss_qty) as gloss_half
	FROM orders
	ORDER BY gloss_qty desc
	
	
/* Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.*/

SELECT  account_id,
		occurred_at,
		total_amt_usd,
		NTILE(100) OVER (ORDER BY total_amt_usd) as total_percentile
	FROM orders
	ORDER BY total_amt_usd desc