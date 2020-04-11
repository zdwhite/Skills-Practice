### LEFT & RIGHT Quizzes

/* In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table. */

WITH t1 as (SELECT RIGHT(a.website,3) as domain 
	FROM accounts as a)

SELECT t1 as domain ,count(t1)
FROM t1
GROUP BY t1

/*There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).*/

WITH t1 as (SELECT LEFT(a.name,1) as Initial 
	FROM accounts as a)

SELECT t1 as Initial ,count(t1)
FROM t1
GROUP BY t1
ORDER BY t1.count desc

/* Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter? */

WITH t1 as (SELECT LEFT(UPPER(a.name),1) as fl, count(*) 
	FROM accounts as a
	GROUP BY fl)
	
SELECT sum(count),
	CASE 
		WHEN t1.fl in ('0','1','2','3','4','5','6','7','8','9') THEN 'Number'
		ELSE 'Letter' END AS alpha_num
FROM t1
GROUP BY alpha_num


/* Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else? */

WITH t1 as (SELECT LEFT(LOWER(a.name),1) as fl, count(*) 
	FROM accounts as a
	GROUP BY fl),
	
	t2 as (SELECT sum(count),
		CASE 
			WHEN t1.fl in ('a','e','i','o','u') THEN 'vowel'
			ELSE 'not_vowel' END AS is_vowel
	FROM t1
	GROUP BY is_vowel)

select *
from t2


### Quizzes POSITION & STRPOS

/* Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc. */
SELECT LEFT(a.primary_poc,STRPOS(a.primary_poc, ' ')-1) as first, RIGHT(a.primary_poc,-STRPOS(a.primary_poc, ' ')) as last
FROM accounts as a

/* Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.*/

SELECT LEFT(s.name,STRPOS(s.name, ' ')-1) as first, RIGHT(s.name,-STRPOS(s.name, ' ')) as last
FROM sales_reps as s

### CONCAT

/* Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.*/

SELECT 	LEFT(a.primary_poc,STRPOS(a.primary_poc, ' ')-1) ||'.'|| 
		RIGHT(a.primary_poc,-STRPOS(a.primary_poc, ' '))||'@'||
		RIGHT(LEFT(a.website,-4),-4)||'.com'	
FROM accounts as a

/* You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your solution should be just as in question 1. Some helpful documentation is here. */

SELECT 	LEFT(a.primary_poc,STRPOS(a.primary_poc, ' ')-1) ||'.'|| 
		RIGHT(a.primary_poc,-STRPOS(a.primary_poc, ' '))||'@'||
		RIGHT(LEFT(a.website,-4),-4)||'.com'	
FROM accounts as a

/* We would also like to create an initial password, which they will change after their first log in. 
	The first password will be the first letter of the primary_poc's first name (lowercase), 
	then the last letter of their first name (lowercase), 
	the first letter of their last name (lowercase), 
	the last letter of their last name (lowercase), 
	the number of letters in their first name, 
	the number of letters in their last name, 
	and then the name of the company they are working with, all capitalized with no spaces. */


WITH t1 as (SELECT 	LEFT(a.primary_poc,STRPOS(a.primary_poc, ' ')-1) as first,
		RIGHT(a.primary_poc,-STRPOS(a.primary_poc, ' '))as last, 
		RIGHT(LEFT(a.website,-4),-4) as name,
		LEFT(a.primary_poc,STRPOS(a.primary_poc, ' ')-1) ||'.'|| 
		RIGHT(a.primary_poc,-STRPOS(a.primary_poc, ' '))||'@'||
		RIGHT(LEFT(a.website,-4),-4)||'.com' as email
		FROM accounts as a)

SELECT first,last,email,
	left(LOWER(t1.first),1)||right(LOWER(first),1)||left(lower(last),1)||right(lower(last),1)||LENGTH(first)||LENGTH(LAST)||UPPER(name) as pid
FROM t1

### QUIZ CAST

/* Write a query to change the date into the correct SQL date format. You will need to use at least SUBSTR and CONCAT to perform this operation. 

Then cast it to date format*/

WITH t1 as (SELECT LEFT(date,strpos(date,' ')-1) as date,time,id
	FROM sf_crime_data
	LIMIT 10),
	
	t2 as (SELECT (RIGHT(t1.date,4)||'-'||LEFT(t1.date,2)||'-'||LEFT(RIGHT(t1.date,-strpos(t1.date,'/')),2))::date as date, t1.id
	FROM t1)

SELECT *
FROM sf_crime_data
JOIN t2
ON t2.id=sf_crime_data.id


### COALESCE QUIZ
/* Fill in the account ID*/

SELECT a.*,o.*,COALESCE(a.id,a.id) as id
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/* FILL in orders.account_id with account.id*/
SELECT a.*,o.*,COALESCE(a.id,a.id) as id,COALESCE(o.account_id,a.id)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


/* FILL qty and usd columns with 0*/
SELECT a.*,o.*,COALESCE(a.id,a.id) as id,
	COALESCE(o.account_id,a.id) as account_id,
	COALESCE(o.gloss_qty,0) as gloss_qty,
	COALESCE(o.poster_qty,0) as poster_qty,
	COALESCE(o.standard_amt_usd,0) as standard_amt_usd,
	COALESCE(o.gloss_amt_usd,0) as gloss_amt_usd,
	COALESCE(o.poster_amt_usd,0) as poster_amt_usd,
	COALESCE(o.standard_qty,0) as standard_qty

FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/* how many ids*/

WITH t1 as (SELECT a.*,o.*,COALESCE(a.id,a.id) as id,
		COALESCE(o.account_id,a.id) as account_id,
		COALESCE(o.gloss_qty,0) as gloss_qty,
		COALESCE(o.poster_qty,0) as poster_qty,
		COALESCE(o.standard_amt_usd,0) as standard_amt_usd,
		COALESCE(o.gloss_amt_usd,0) as gloss_amt_usd,
		COALESCE(o.poster_amt_usd,0) as poster_amt_usd,
		COALESCE(o.standard_qty,0) as standard_qty

	FROM accounts a
	LEFT JOIN orders o
	ON a.id = o.account_id)

SELECT *
FROM t1
