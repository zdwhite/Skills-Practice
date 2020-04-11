#### UDACITY SQL Project 

The project submission is a presentation, which will be reviewed, and for which you will need to Meet Expectations to pass. For the presentation component, you will create four slides. Each slide will:

	1. Have a question of interest.
	2. Have a supporting SQL query needed to answer the question.
	3. Have a supporting visualization created using the final data of your SQL query that answers your question of interest.
	
Your project will include:

	1. A set of slides with a question, visualization, and small summary on each slide.
	2. A text file with your queries needed to answer each of the four questions.
	
----- SET NUMBER 1
/* Question 1
We want to understand more about the movies that families are watching. The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out. */

with t1 as (SELECT *
FROM rental as r
JOIN inventory as i
ON i.inventory_id = r.inventory_id
JOIN film as f
ON i.film_id = f.film_id
JOIN film_category as fc
ON f.film_id = fc.film_id
JOIN category as c
on c.category_id = fc.category_id)

SELECT title,name,count(*)
FROM t1
where name in ('Animation','Children','Classics','Comedy','Family','Music')
group by title,name
order by 2,1


/* Question 2
Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. Can you provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories? Make sure to also indicate the category that these family-friendly movies fall into.*/

with t1 as (SELECT f.title,c.name,f.rental_duration
	FROM film as f
	JOIN film_category as fc
	ON f.film_id = fc.film_id
	JOIN category as c
	on c.category_id = fc.category_id)

SELECT *,ntile (4) over (ORDER BY rental_duration) as standard_quartile
FROM t1
where name in ('Animation','Children','Classics','Comedy','Family','Music')

/*
Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. The resulting table should have three columns:

	Category
	Rental length category
	Count
*/

with t1 as (SELECT f.title,c.name,f.rental_duration,
	ntile(4) over (ORDER BY rental_duration) as standard_quartile
	FROM film as f
	JOIN film_category as fc
	ON f.film_id = fc.film_id
	JOIN category as c
	on c.category_id = fc.category_id
	where name in ('Animation','Children','Classics','Comedy','Family','Music'))

SELECT name, standard_quartile,count(title)
FROM t1

GROUP BY name,standard_quartile
order by name,standard_quartile 

--- Question Set 2
/* Question 1:
We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.*/

with t1 as (SELECT DATE_PART('month',r.rental_date) as rental_month,
			DATE_PART('year',r.rental_date) as rental_year,
			sf.store_id
			FROM rental as r
			JOIN staff as sf
			ON r.staff_id = sf.staff_id)

SELECT *,count(*)
FROM t1
GROUP BY 1,2,3
ORDER BY 4 desc

/* Question 2
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?
*/

with t1 as (SELECT date_trunc('month', p.payment_date) as pay_mon,
				c.first_name || ' ' || c.last_name as fullname,
				p.customer_id,
				p.amount,
				p.payment_id
			
			FROM payment as p
			JOIN customer as c
			ON p.customer_id = c.customer_id),
	
	t2 as (SELECT pay_mon,fullname,
			count(payment_id) OVER (partition by pay_mon,fullname order by fullname) as pay_counterpermon,
		   sum(amount) OVER (partition by pay_mon,fullname order by fullname) as pay_amount,
		   sum(amount) over (partition by fullname order by fullname) as running_total
			FROM t1
			order by 5 desc,2,1),
	t3 as (SELECT fullname,running_total
		  FROM t2
		  group by 1,2
		  order by 2 desc
		  limit 10)

SELECT t2.*
FROM t2
JOIN t3
ON t2.fullname = (t3.fullname)
group by 1,2,3,4,5
order by 5 desc,2,1

/*Question 3
Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly payments during 2007. Please go ahead and write a query to compare the payment amounts in each successive month. Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments.
*/


with t1 as (SELECT date_trunc('month', p.payment_date) as pay_mon,
				c.first_name || ' ' || c.last_name as fullname,
				p.customer_id,
				p.amount,
				p.payment_id
			
			FROM payment as p
			JOIN customer as c
			ON p.customer_id = c.customer_id),	
	t2 as (SELECT pay_mon,fullname,
			count(payment_id) OVER (partition by pay_mon,fullname order by fullname) as pay_counterpermon,
		   sum(amount) OVER (partition by pay_mon,fullname order by fullname) as pay_amount,
		   sum(amount) over (partition by fullname order by fullname) as running_total
			FROM t1
			order by 5 desc,2,1),
	t3 as (SELECT fullname,running_total
		  FROM t2
		  group by 1,2
		  order by 2 desc
		  limit 10),
	--- Top 10 Whales
	t4 as (SELECT t2.*
			FROM t2
			JOIN t3
			ON t2.fullname = (t3.fullname)
			group by 1,2,3,4,5
			order by 5 desc,2,1)
			
SELECT *,
		pay_amount-COALESCE(LAG(pay_amount) OVER (partition by fullname order by fullname,pay_mon),0) as spend_change
FROM t4
order by spend_change desc


/* Distribution of rentals */
SELECT count(r.*), f.title
FROM rental as r
JOIN inventory as i
ON i.inventory_id = r.inventory_id
JOIN film as f
ON i.film_id = f.film_id
GROUP by f.title
order by 1 desc
