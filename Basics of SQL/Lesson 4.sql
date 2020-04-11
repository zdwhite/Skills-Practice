### Subquery Quiz

/* Find the number of events that occur for each day for each channel*/

SELECT DATE_TRUNC('day', occurred_at) AS date, w.channel, count(w.id) as event_count
FROM web_events as w
GROUP BY 1,2
ORDER BY 1,3 desc
/* 
Quiz 1 is confusing, it's asking of the days listed which had the higest pair,

NOT for the given day was the channel listed the channel with the most events.
*/

/* Turn the above query into a subquery*/
SELECT *
FROM(SELECT DATE_TRUNC('day', occurred_at) AS date,
	w.channel, count(w.id) as event_count
	FROM web_events as w
	GROUP BY 1,2
	ORDER BY 1,3 desc
	) sub

/* Find the AVG num of events for each channel per day*/

SELECT w.channel, AVG(w.event_count) as avg_event_count
FROM(SELECT DATE_TRUNC('day', occurred_at) AS date, 
			w.channel, count(w.id) as event_count
	FROM web_events as w
	GROUP BY 1,2
	) sub
GROUP BY 1
ORDER BY 2 desc;


/* USE DATE_TRUNC to pull month level information about the first order ever placed in the orders table*/

SELECT *
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
	(SELECT DATE_TRUNC('month',MIN(occurred_at)) as min_month
	FROM orders)
ORDER BY occurred_at
	
/* Pull the average for each type of paper qty in the first month using the query above*/

SELECT avg(standard_qty	) as avg_standard ,avg(gloss_qty) as avg_gloss,avg(poster_qty) as avg_poster, sum(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
	(SELECT DATE_TRUNC('month',MIN(occurred_at)) as min_month
	FROM orders)
	
	
### Sub Query Mania

/* Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/

SELECT t3.name , t3.region , t3.max
FROM(SELECT s.name, r.name as region, max(o.total_amt_usd)
			FROM sales_reps as s
			JOIN region as r
			ON r.id = s. region_id
			JOIN accounts as a
			ON a.sales_rep_id = s.id
			JOIN orders as o	
			ON a.id = o.id
			group by s.name, region) t3

JOIN(SELECT t1.region,max(max) 
	FROM(SELECT s.name, r.name as region, max(o.total_amt_usd)
			FROM sales_reps as s
			JOIN region as r
			ON r.id = s. region_id
			JOIN accounts as a
			ON a.sales_rep_id = s.id
			JOIN orders as o	
			ON a.id = o.id
			group by s.name, region) t1
	GROUP BY t1.region) t2
on t2.region = t3.region and t2.max=t3.max

/* For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed? */
SELECT t3.name, t3.sales, t3.orders
FROM(SELECT r.name, sum(o.total_amt_usd) as sales, count(o.id) as orders
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		JOIN sales_reps as s
		ON s.id = a.sales_rep_id
		JOIN region as r
		ON s.region_id = r.id
		GROUP BY r.name) t3

JOIN(SELECT max(t1.sum) as sales, max(t1.count) as orders
	FROM(SELECT r.name, sum(o.total_amt_usd), count(o.id)
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		JOIN sales_reps as s
		ON s.id = a.sales_rep_id
		JOIN region as r
		ON s.region_id = r.id
		GROUP BY r.name) t1
		) t2
ON t2.sales=t3.sales and t2.orders = t3.orders


/* How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer? */

	/* first solve for the life time sum of standard _qty paper for all accounts*/

	SELECT a.name , sum(o.standard_qty) as lftm_standard_qty
	FROM orders as o
	JOIN accounts as a
	ON a.id = o.account_id
	GROUP BY a.name

	/* now return the element with the highest lftm_standard_qty  41617*/

	SELECT max(lftm_standard_qty)
		FROM(SELECT a.name , sum(o.standard_qty) as lftm_standard_qty
			FROM orders as o
			JOIN accounts as a
			ON a.id = o.account_id
			GROUP BY a.name)t1
	/* Next return a table with the sum of the total orders grouped by account*/

	SELECT a.name  as account , sum(o.total) tot_order
	FROM orders as o
	JOIN accounts as a
	ON a.id = o.account_id
	GROUP BY a.name
	order by tot_order desc
	
	/* Now only return rows haveing tot_order > the element returned in the previous question*/
SELECT t1.account,t1.tot_order
FROM(SELECT a.name  as account , sum(o.total) as tot_order
	FROM orders as o
	JOIN accounts as a
	ON a.id = o.account_id
    GROUP BY a.name
	order by tot_order desc) t1
GROUP BY account,tot_order
HAVING tot_order >= (SELECT max(lftm_standard_qty)
					FROM(SELECT a.name , sum(o.standard_qty) as lftm_standard_qty
						FROM orders as o
						JOIN accounts as a
						ON a.id = o.account_id
						GROUP BY a.name)t2)
						
/* For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?*/
	
	/* first group accounts and sum their life time sales*/
	SELECT a.name  as account , sum(o.total_amt_usd) as lftm_tot_rev
	FROM orders as o
	JOIN accounts as a
	ON a.id = o.account_id
    GROUP BY a.name
	order by lftm_tot_rev desc
	/* next just the account with the most life time sales*/
	SELECT t3.account
	FROM(SELECT a.name  as account , sum(o.total_amt_usd) as lftm_tot_rev
		FROM orders as o
		JOIN accounts as a
		ON a.id = o.account_id
		GROUP BY a.name
		order by lftm_tot_rev desc)t3
	
	
	JOIN(SELECT max(t1.lftm_tot_rev)
		FROM(SELECT a.name  as account , sum(o.total_amt_usd) as lftm_tot_rev
			FROM orders as o
			JOIN accounts as a
			ON a.id = o.account_id
			GROUP BY a.name
			order by lftm_tot_rev desc)t1
		)t2
	ON t2.max = t3.lftm_tot_rev
	/* now get a table with the counts of all the web_events per channel */
	SELECT a.name,w.channel,count(w.channel)
	FROM accounts as a
	JOIN web_events as w
	ON w.account_id = a.id
	/* finally join the account on the table above */
	SELECT t4.account,t4.channel,t4.count
		FROM(SELECT a.name as account,w.channel,count(w.channel)
			FROM accounts as a
			JOIN web_events as w
			ON w.account_id = a.id
			GROUP BY a.name,w.channel
			ORDER BY a.name,count desc) t4
	
	JOIN(SELECT t3.account
		FROM(SELECT a.name  as account , sum(o.total_amt_usd) as lftm_tot_rev
			FROM orders as o
			JOIN accounts as a
			ON a.id = o.account_id
			GROUP BY a.name
			order by lftm_tot_rev desc)t3
		
		JOIN(SELECT max(t1.lftm_tot_rev)
			FROM(SELECT a.name  as account , sum(o.total_amt_usd) as lftm_tot_rev
				FROM orders as o
				JOIN accounts as a
				ON a.id = o.account_id
				GROUP BY a.name
				order by lftm_tot_rev desc)t1
			)t2
		ON t2.max = t3.lftm_tot_rev
		)t5
	ON t5.account = t4.account

/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
*/

	/* First get the life time sales for all accounts*/
	SELECT a.name as account, sum(o.total_amt_usd) lftm_tot_rev
	FROM orders as o
	JOIN accounts as a
	ON o.account_id = a.id
	GROUP BY a.name
	
	/* Get just the top 10*/
	SELECT avg(lftm_tot_rev)
	FROM(SELECT a.name as account, sum(o.total_amt_usd) lftm_tot_rev
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		GROUP BY a.name
		LIMIT 10) t1

/* What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.	*/

	/* first generate a table of accounts and their life time $/order */
	SELECT a.name as account, sum(o.total_amt_usd)/sum(total) lftm_unit
	FROM orders as o
	JOIN accounts as a
	ON o.account_id = a.id
	GROUP BY a.name
	/* get the average dollar per order for the column of averages */
	SELECT avg(lftm_unit)
	FROM(SELECT a.name as account, sum(o.total_amt_usd)/sum(total) lftm_unit
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		GROUP BY a.name)t1
	/* Combine the two with a WHERE claus */
	SELECT t2.account,t2.lftm_unit
		FROM(SELECT a.name as account, sum(o.total_amt_usd)/sum(total) lftm_unit
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		GROUP BY a.name)t2
	WHERE lftm_unit >= (SELECT avg(t1.lftm_unit)
						FROM(SELECT a.name as account, sum(o.total_amt_usd)/sum(total) lftm_unit
							FROM orders as o
							JOIN accounts as a
							ON o.account_id = a.id
							GROUP BY a.name)t1
							)
	ORDER BY lftm_unit
	
### QUIZ ON WITH

/* Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/
WITH reg_perf AS (
          SELECT s.name, r.name as region, max(o.total_amt_usd)
			FROM sales_reps as s
			JOIN region as r
			ON r .id = s. region_id
			JOIN accounts as a
			ON a.sales_rep_id = s.id
			JOIN orders as o	
			ON a.id = o.id
			group by s.name, region),
	
	max_perf AS (SELECT reg_perf.region,max(max) 
				FROM reg_perf
				GROUP BY reg_perf.region)
SELECT *
FROM reg_perf
JOIN max_perf
ON reg_perf.region = max_perf.region and reg_perf.max=max_perf.max

/* For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed? */
WITH reg_tot_perf AS (SELECT r.name, sum(o.total_amt_usd), count(o.id)
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		JOIN sales_reps as s
		ON s.id = a.sales_rep_id
		JOIN region as r
		ON s.region_id = r.id
		GROUP BY r.name),
	 
	 max_perf as (SELECT max(reg_tot_perf.sum)
		FROM reg_tot_perf)
SELECT count
FROM reg_tot_perf
JOIN max_perf
ON max_perf.max=reg_tot_perf.sum

/* How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer? */

WITH tot_lftm_order as (SELECT a.name  as account , sum(o.total) as tot_order
	FROM orders as o
	JOIN accounts as a
	ON a.id = o.account_id
    GROUP BY a.name),
	
	max_lftm_stnd as (SELECT max(lftm_standard_qty) as max
					  FROM(SELECT a.name , sum(o.standard_qty) as lftm_standard_qty
						FROM orders as o
						JOIN accounts as a
						ON a.id = o.account_id
						GROUP BY a.name)t2)
SELECT *
FROM tot_lftm_order
GROUP BY tot_lftm_order.account,tot_lftm_order.tot_order
HAVING tot_lftm_order.tot_order >= (SELECT max
FROM max_lftm_stnd)

/* For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?*/
WITH 	a_wc_count as (SELECT a.name as account,w.channel,count(w.channel)
				FROM accounts as a
				JOIN web_events as w
				ON w.account_id = a.id
				GROUP BY a.name,w.channel
				ORDER BY a.name,count desc),
		
		lftm_tot_rev as	(SELECT a.name  as account , sum(o.total_amt_usd) as lftm_tot_rev
				FROM orders as o
				JOIN accounts as a
				ON a.id = o.account_id
				GROUP BY a.name
				order by lftm_tot_rev desc),
		max_lftm_tot_rev as (SELECT max(lftm_tot_rev.lftm_tot_rev)
				FROM lftm_tot_rev),
				
		accnt_max_lftm_total_rev as (SELECT lftm_tot_rev.account
				FROM lftm_tot_rev
				JOIN max_lftm_tot_rev
				ON max_lftm_tot_rev.max = lftm_tot_rev.lftm_tot_rev)
		
SELECT *
FROM a_wc_count
JOIN accnt_max_lftm_total_rev as a 
ON a.account = a_wc_count.account
	
/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
*/

	/* First get the life time sales for all accounts*/
	SELECT a.name as account, sum(o.total_amt_usd) lftm_tot_rev
	FROM orders as o
	JOIN accounts as a
	ON o.account_id = a.id
	GROUP BY a.name
	
	/* Get just the top 10*/
	SELECT avg(lftm_tot_rev)
	FROM(SELECT a.name as account, sum(o.total_amt_usd) lftm_tot_rev
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		GROUP BY a.name
		ORDER BY lftm_tot_rev desc
		LIMIT 10) t1

WITH lftm_tot_rev as (SELECT a.name as account, sum(o.total_amt_usd) lftm_tot_rev
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		GROUP BY a.name
		ORDER BY lftm_tot_rev desc
		LIMIT 10)
SELECT avg(lftm_tot_rev)
FROM lftm_tot_rev


/* What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.	*/
WITH lftm_unit as (SELECT a.name as account, sum(o.total_amt_usd)/sum(total) lftm_unit
		FROM orders as o
		JOIN accounts as a
		ON o.account_id = a.id
		GROUP BY a.name),
		
	avg_lftm_unit as (SELECT avg(lftm_unit.lftm_unit)
		FROM lftm_unit)

SELECT*
FROM lftm_unit
WHERE lftm_unit.lftm_unit >=(SELECT avg_lftm_unit.avg FROM avg_lftm_unit)
ORDER BY lftm_unit desc
