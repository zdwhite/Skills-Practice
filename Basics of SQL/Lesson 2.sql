### Your first JOIN

/*
1.Try pulling all the data from the accounts table, and all the data from the orders table.
*/
select orders.*,orders.*
from orders
join accounts
on orders.account_id = accounts.id;

/*
2.Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and the primary_poc from the accounts table.
*/
select orders.standard_qty, orders.gloss_qty, orders.poster_qty,accounts.website,accounts.primary_poc
from orders
join accounts
on orders.account_id = accounts.id;


### Helpful ERD For Answering the Below Questions

/*
1. Definitions
Has a unique value for every row in that column. There is one in every table.
	Primary Key

The link to the primary key that exists in another table.
	Foreign Key

The primary key in every table of our example database.
	id

A foreign key that exists in both the web_events and orders tables.
	account_id

The ON statement associated with a JOIN of the web_events and accounts tables.
	ON web_events.account_id = accounts.id

*/

/*
2. 
There is one and only one of these columns in every table.

They are a column in a table.
*/

/*
3.
They are always linked to a primary key.

In the above database, every foreign key is associated with the crow-foot notation, which suggests it can appear multiple times in the column of a table.
*/


### JOIN Questions Part 1
/*
1.Provide a table for all web_events associated with account name of Walmart. There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.

*/
SELECT w.id,a.primary_poc,w.channel,a.name 
FROM web_events as w
JOIN accounts as a
ON w.account_id = a.id
WHERE a.name = 'Walmart';


/*
2.Provide a table that provides the region for each sales_rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
*/

SELECT a.name as account_name, s.name as rep_name, r.name as region
FROM sales_reps as s
JOIN region as r
ON s.region_id = r.id 
JOIN accounts as a
ON s.id = a.sales_rep_id
ORDER BY a.name;

/*
3.Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name, and unit price. A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.

*/

o.total_amt_usd/(total+.01) as Unit_Price
FROM orders as o
JOIN accounts as a
ON a.id = o.account_id
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON s.region_id = r.id;

/*
Definitions
The primary key of the Country table.
	Country.countryid


The primary key of the State table.
	State.stateid


The foreign key that would be used in JOINing the tables.
	State.countryid

The number of columns in resulting table.
	3

The number of rows in the resulting table.
	6

The number of times countryid 1 will show up in resulting table.
	2

The number of times countryid 6 will show up in the resulting table.
	0


The number of columns in resulting table.
	3

The number of rows in the resulting table.
	8

The number of times countryid 1 will show up in resulting table.
	2

The number of times countryid 6 will show up in the resulting table.
	1
*/

### Last CHECK

/*
1.Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT a.name as account_name, s.name as rep_name, r.name as region
FROM sales_reps as s
JOIN region as r
ON s.region_id = r.id
AND r.name = 'Midwest' 
JOIN accounts as a
ON s.id = a.sales_rep_id
ORDER BY a.name;

/*
2.Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where the sales rep has a first name starting with S and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.

*/
SELECT a.name as account_name, s.name as rep_name, r.name as region
FROM sales_reps as s
JOIN region as r
ON s.region_id = r.id
AND r.name = 'Midwest'
AND s.name LIKE 'S%' 
JOIN accounts as a
ON s.id = a.sales_rep_id
ORDER BY a.name;


/*
3.Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where the sales rep has a last name starting with K and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.

*/

SELECT a.name as account_name, s.name as rep_name, r.name as region
FROM sales_reps as s
JOIN region as r
ON s.region_id = r.id
AND r.name = 'Midwest'
AND s.name LIKE '% K%' 
JOIN accounts as a
ON s.id = a.sales_rep_id
ORDER BY a.name;

/*
4.Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100. Your final table should have 3 columns: region name, account name, and unit price. In order to avoid a division by zero error, adding .01 to the denominator here is helpful total_amt_usd/(total+0.01).

*/
SELECT r.name as region,a.name as accnt_name,o.total_amt_usd/(total+.01) as Unit_Price
FROM orders as o
JOIN accounts as a
ON a.id = o.account_id
AND o.standard_qty > 100
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON s.region_id = r.id;

/*
5.Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the smallest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).

*/
SELECT r.name as region,a.name as accnt_name,o.total_amt_usd/(total+.01) as Unit_Price
FROM orders as o
JOIN accounts as a
ON a.id = o.account_id
AND o.standard_qty > 100
AND o.poster_qty >50
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON s.region_id = r.id;
/*
6.Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).
*/
SELECT r.name as region,a.name as accnt_name,o.total_amt_usd/(total+.01) as Unit_Price
FROM orders as o
JOIN accounts as a
ON a.id = o.account_id
AND o.standard_qty > 100
AND o.poster_qty >50
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON s.region_id = r.id
ORDER BY Unit_Price DESC;

/*
7.What are the different channels used by account id 1001? Your final table should have only 2 columns: account name and the different channels. You can try SELECT DISTINCT to narrow down the results to only the unique values.

*/

SELECT DISTINCT a.name,w.channel
FROM web_events as w
JOIN accounts as a
ON w.account_id=a.id
AND account_id = 1001;


/*
8.Find all the orders that occurred in 2015. Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.
*/
SELECT o.occurred_at,a.name as accnt_name,o.total,o.total_amt_usd
FROM orders as o
JOIN accounts as a
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015 00:00:00' and '01-01-2016 00:00:00'
ORDER BY o.occurred_at;
