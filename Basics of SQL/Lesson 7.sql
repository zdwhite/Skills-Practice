###  FULL OUTER JOIN

/* each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)*/

SELECT *
FROM accounts as a
FULL JOIN sales_reps as s
ON a.sales_rep_id = s.id

/* but also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these returned rows will be empty)
 */
 
SELECT *
FROM accounts as a
FULL JOIN sales_reps as s
ON a.sales_rep_id = s.id
WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL


### Inequality JOINs

/* write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name, like so: */

SELECT  a.name as account,
		a.primary_poc,
		s.name as rep
FROM accounts as a
LEFT JOIN sales_reps as s
ON s.id = a.sales_rep_id
AND a.primary_poc < s.name

### SELF JOINs

/* Modify the query from the previous video, to perform the same interval analysis except for the web_events table
	1. change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
	2. add a column for the channel variable in both instances of the table in your query*/

SELECT w1.id AS w1_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
	   w1.channel as w1_channel,
       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at,
	   w2.channel as w2_channel
	   
  FROM web_events w1
 LEFT JOIN web_events w2
   ON w1.account_id = w2.account_id
  AND w2.occurred_at < w1.occurred_at
  AND  w1.occurred_at <= w2.occurred_at + INTERVAL '1 days'
ORDER BY w1.account_id, w1.occurred_at

### UNION
/* Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table. Then inspect the results and answer the subsequent quiz.*/

WITH t1 AS (
	SELECT *
	FROM accounts

UNION ALL

SELECT *
	FROM accounts
	)


SELECT *
	FROM t1

/* Add a WHERE clause to each of the tables that you unioned in the query above, filtering the first table where name equals Walmart and filtering the second table where name equals Disney. Inspect the results then answer the subsequent quiz.*/
WITH t1 AS (
	SELECT *
	FROM accounts
	WHERE name = 'Walmart'

UNION ALL

SELECT *
	FROM accounts
	WHERE name = 'Disney'
	)


SELECT *
	FROM t1
/* Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. Then do a COUNT the number of times a name appears in the double_accounts table. If you do this correctly, your query results should have a count of 2 for each name.*/

WITH double_accounts AS (
	SELECT *
	FROM accounts

UNION ALL

SELECT *
	FROM accounts
	)


SELECT count(*)
	FROM double_accounts
	
