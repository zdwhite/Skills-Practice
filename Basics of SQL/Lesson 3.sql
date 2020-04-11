### SUM

/*
1.Find the total amount of poster_qty paper ordered in the orders table.
*/
SELECT SUM(o.poster_qty) as poster_total
FROM orders as o
/*
2.Find the total amount of standard_qty paper ordered in the orders table.
*/
SELECT SUM(o.standard_qty ) as standard_total
FROM orders as o
/*
3.Find the total dollar amount of sales using the total_amt_usd in the orders table.
*/
SELECT SUM(o.total_amt_usd) as sales_revenue
FROM orders as o
/*
4.Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. This should give a dollar amount for each order in the table.
*/
SELECT o.standard_amt_usd a + o.gloss_amt_usd as total _standard_gloss
FROM orders as o
/*
5.Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a mathematical operator.
*/

SELECT SUM(o.standard_amt_usd)/SUM(o.standard_qty) as standard_unit_price
FROM orders as o


### Questions: MIN, MAX, & AVERAGE

/*
1.When was the earliest order ever placed? You only need to return the date.
*/
SELECT min(o.occurred_at)
FROM orders as o;

/*
2.Try performing the same query as in question 1 without using an aggregation function.
*/
SELECT min(o.occurred_at)
FROM orders as o;
/*
3.When did the most recent (latest) web_event occur?
*/
SELECT max(w.occurred_at)
FROM web_events as w;
/*
4. Try to perform the result of the previous query without using an aggregation function.
*/

SELECT max(w.occurred_at)
FROM web_events as w;

/*
5.Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.

*/

SELECT AVG(o.standard_amt_usd) as avg_standard_revenue, AVG(o.standard_qty) as avg_standard_qty, AVG(o.gloss_amt_usd) as avg_gloss_revenue, AVG(o.gloss_qty) as avg_gloss_qty, AVG(o.poster_amt_usd) as avg_poster_revenue ,AVG(o.poster_qty) as avg_poster_qty
FROM orders as o;

/*
6.Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders?
*/
SELECT o.total_amt_usd
FROM orders as o
order by o.total_amt_usd
Limit 3456

### GROUP BY Note

/*
1.Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
*/
SELECT a.name as account, o.occurred_at
FROM accounts as a
JOIN orders as o
ON o.account_id = a.id
ORDER BY o.occurred_at
LIMIT 1;

/*
2.Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.
*/
SELECT a.name, sum(o.total_amt_usd) as account_sales
FROM accounts as a
JOIN orders as o
ON o.account_id = a.id
GROUP BY a.name
ORDER BY account_sales desc;
/*
3.Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.
*/

SELECT w.occurred_at,w.channel,a.name
FROM web_events as w
JOIN accounts as a
ON w.account_id=a.id
ORDER BY w.occurred_at desc
LIMIT 1;

/*
4.Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.
*/

SELECT w.channel, count(w.channel)
FROM web_events as w
GROUP BY w.channel
ORDER BY w.count desc;

/*
5.Who was the primary contact associated with the earliest web_event?
*/
SELECT w.occurred_at , a.primary_poc
FROM web_events as w
JOIN accounts as a
ON w.account_id = a.id
ORDER BY w.occurred_at
LIMIT 1;
/*
6.What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.
*/
SELECT a.name, min(o.total_amt_usd) as min_order
FROM accounts as a
JOIN orders as o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY min_order;


/*
7.Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps.
*/

SELECT r.name,count(s.name)
FROM sales_reps as s
JOIN region as r
ON s.region_id = r.id
GROUP BY r.name
ORDER BY count;

### GROUP BY PART II
/*
1.For each account, determine the average amount of each type of paper they purchased across their orders. Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.
*/
SELECT a.name, avg(o.standard_qty) as avg_standard_qty ,avg(o.poster_qty) as avg_poster_qty ,avg(o.gloss_qty) as avg_gloss_qty
FROM accounts as a
JOIN orders as o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name ;

/*
2. For each account, determine the average amount spent per order on each paper type. Your result should have four columns - one for the account name and one for the average amount spent on each paper type.
*/
SELECT a.name, avg(o.standard_amt_usd) as avg_standard_rev ,avg(poster_amt_usd) as avg_poster_rev ,avg(gloss_amt_usd) as avg_gloss_rev
FROM accounts as a
JOIN orders as o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name ;

/*
3. Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
*/
SELECT s.name, w.channel , count(w.channel)
FROM web_events as w
JOIN accounts as a
ON w.account_id = a.id
JOIN sales_reps as s
ON a.sales_rep_id
GROUP BY s.name,w.channel
ORDER BY count desc;

/*
4. Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
*/
SELECT r.name,w.channel,count(w.channel)
FROM web_events as w
JOIN accounts as a
ON w.account_id = a.id
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON s.region_id = r.id
GROUP BY r.name , w.channel
ORDER BY count desc;

### DISTINCT QUIZ /* I'll note I don't like these examples at all */

/*
1. Use DISTINCT to test if there are any accounts associated with more than one region.
*/
SELECT DISTINCT a.name as account,r.name as region
FROM accounts as a
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON r.id = s.region_id
ORDER BY account;
/*
If i'm wrong I think it's probably better to do it like this w.o distinct
*/
SELECT a.name as account, count(r.name) as num_regions
FROM accounts as a
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON r.id = s.region_id
GROUP BY account
ORDER BY num_regions desc;


/*
2. Have any sales reps worked on more than one account?
*/

SELECT DISTINCT s.name as rep, a.name as account
FROM accounts as a
JOIN sales_reps as s
ON a.sales_rep_id = s.id
ORDER BY rep;

### Having Quiz

/*How many of the sales reps have more than 5 accounts that they manage?*/
SELECT s.name as rep, count(a.name) as num_accounts
FROM accounts as a
JOIN sales_reps as s
ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING count(a.name) > 5
ORDER BY num_accounts desc;

/*How many accounts have more than 20 orders?*/
SELECT a.name as account, count(o.account_id) as num_orders
FROM accounts as a
JOIN orders as o
ON o.account_id = a.id
GROUP BY a.name
HAVING count(o.account_id) > 20
ORDER BY num_orders desc;

/*Which account has the most orders?*/
SELECT a.name as account, count(o.account_id) as num_orders
FROM accounts as a
JOIN orders as o
ON o.account_id = a.id
GROUP BY a.name
HAVING count(o.account_id) > 20
ORDER BY num_orders desc
LIMIT 1;

/*Which accounts spent more than 30,000 usd total across all orders?*/
SELECT a.name account, sum(o.total_amt_usd) total_account_rev
FROM accounts as a
JOIN orders as o
ON a.id = o.account_id
GROUP BY a.name
HAVING sum(o.total_amt_usd) > 30000
ORDER BY total_account_rev desc;

/*Which accounts spent less than 1,000 usd total across all orders?*/
SELECT a.name account, sum(o.total_amt_usd) total_account_rev
FROM accounts as a
JOIN orders as o
ON a.id = o.account_id
GROUP BY a.name
HAVING sum(o.total_amt_usd) < 1000
ORDER BY total_account_rev desc;

/*Which account has spent the most with us?*/
SELECT a.name account, sum(o.total_amt_usd) total_account_rev
FROM accounts as a
JOIN orders as o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_account_rev desc
Limit 1;

/*Which account has spent the least with us?*/
SELECT a.name account, sum(o.total_amt_usd) total_account_rev
FROM accounts as a
JOIN orders as o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_account_rev
Limit 1;

/*Which accounts used facebook as a channel to contact customers more than 6 times?*/
SELECT a.name ,w.channel, count(w.channel)
FROM accounts as a
JOIN web_events as w
ON a.id = w.account_id
GROUP BY a.name,w.channel
HAVING w.channel = 'facebook' and count(w.channel) >6
ORDER BY count desc;

/*Which account used facebook most as a channel?*/

SELECT a.name ,w.channel, count(w.channel)
FROM accounts as a
JOIN web_events as w
ON a.id = w.account_id
GROUP BY a.name,w.channel
HAVING w.channel = 'facebook'
ORDER BY count desc
LIMIT 1;

/*Which channel was most frequently used by most accounts?
 
 Their solution to this problem is as obtuse as the question would suggest.
*/
SELECT a.name ,w.channel, count(w.channel)
FROM accounts as a
JOIN web_events as w
ON a.id = w.account_id
GROUP BY  a.name,w.channel
ORDER BY count desc;


###Date Function Quiz

/* Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?*/

SELECT DATE_TRUNC('year',occurred_at) as year, SUM(total_amt_usd) as total_sales
FROM orders
GROUP BY DATE_TRUNC('year',occurred_at)
ORDER BY SUM(total_amt_usd) desc;

/*Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
	1a. This is a confusing question, does it mean all months between Jan 2017 and Dec 2013? Because all months have sales numbers.
	1b. Or does it mean sum the sales for the same month of every year and compare them?
*/

SELECT DATE_TRUNC('month',occurred_at) as month_year, SUM(total_amt_usd) as total_sales
FROM orders
GROUP BY DATE_TRUNC('month',occurred_at)
ORDER BY SUM(total_amt_usd) desc;

/* or */

SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) as total_sales
FROM orders
WHERE occurred_at BETWEEN '2013-12-01' and '2017-01-01'
GROUP BY 1
ORDER BY 2 desc;


/*Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?*/

SELECT DATE_PART('year', occurred_at) ord_year, SUM(total_amt_usd) as total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' and '2017-01-01'
GROUP BY 1
ORDER BY 2 desc;

/*Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented by the dataset?*/

SELECT DATE_PART('month', occurred_at) ord_month, count(id) as total_orders
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' and '2017-01-01'
GROUP BY 1
ORDER BY 2 desc;

/*In which month of which year did Walmart spend the most on gloss paper in terms of dollars?*/

SELECT DATE_TRUNC('month', occurred_at) ord_month, SUM(gloss_amt_usd) as total_sales
FROM orders
JOIN accounts as a
ON orders.account_id=a.id
WHERE occurred_at BETWEEN '2014-01-01' and '2017-01-01'
GROUP BY 1,a.name
HAVING a.name = 'Walmart'
ORDER BY 2 desc
LIMIT 1;

### 'CASE' QUIZ

/* 
Write a query to display for each order, the account ID, total amount of the order, and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
*/
SELECT account_id, total,
	CASE WHEN total > 3000 or total = 3000 THEN 'Large' ELSE 'Small' END AS order_lvl
FROM orders

/* 
Write a query to display the number of orders in each of three categories, based on the total number of items in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
*/
SELECT account_id, total,
	CASE 
    	WHEN total > 2000 or total = 3000 THEN 'At Least 2000' 
     	WHEN total BETWEEN 1000 and 2000 THEN 'Between 1000 and 2000'
    	ELSE 'Less than 1000' END AS order_lvl
FROM orders
ORDER BY total desc


/* 
We would like to understand 3 different levels of customers based on the amount associated with their purchases. The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. Order with the top spending customers listed first.
*/
SELECT a.name, SUM(total_amt_usd) as tot_sales,
	CASE 
		WHEN SUM(total_amt_usd) > 200000  THEN 'greater than 200,000' 
		WHEN SUM(total_amt_usd) BETWEEN 200000 and 100000 THEN 'Between 200000 and 100000'
		ELSE 'Less than 100000' END AS life_time_value
FROM orders
JOIN accounts as a
ON orders.account_id=a.id
GROUP BY a.name
ORDER BY tot_sales desc

/* 
We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.

*/
SELECT a.name, SUM(total_amt_usd) as tot_sales,
	CASE 
		WHEN SUM(total_amt_usd) > 200000  THEN 'greater than 200,000' 
		WHEN SUM(total_amt_usd) BETWEEN 200000 and 100000 THEN 'Between 200000 and 100000'
		ELSE 'Less than 100000' END AS life_time_value
FROM orders
JOIN accounts as a
ON orders.account_id=a.id
WHERE occurred_at BETWEEN '2016-01-01' and '2017-01-01'
GROUP BY a.name
ORDER BY tot_sales desc

/* 
We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. Place the top sales people first in your final table.
*/
SELECT s.name, count(o.id) as tot_order
	CASE
		WHEN count(o.id) > 200 THEN 'Is a closer'
		ELSE 'Not a closer' END AS closer
FROM orders as o
JOIN accounts as a
ON o.account_id = a.id
JOIN sales_reps as s
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY count(o.id) desc;

/* 
The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table. You might see a few upset sales people by this criteria!
*/

SELECT s.name, count(o.id) as tot_order, sum(total_amt_usd) as tot_sales,
	CASE
		WHEN count(o.id) > 200 or  sum(total_amt_usd) > 750000 THEN 'Is a closer'
		WHEN count(o.id) > 150 or  sum(total_amt_usd) > 500000 THEN 'can close'
		ELSE 'Not a closer' END AS closer
FROM orders as o
JOIN accounts as a
ON o.account_id = a.id
JOIN sales_reps as s
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY count(o.id) desc;

