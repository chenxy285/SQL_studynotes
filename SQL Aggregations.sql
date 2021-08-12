
-- NULL

-- NULL is not a value but a property of data.
-- We dont use '= NULL', but use 'IS NULL'.

--------------------------------------------------------------------------------

-- COUNT

/*
The COUNT function is returning a count of all the rows that contain some
non-null data. It's very unusual to have a row that is entirely null. So the
result produced by COUNT(*) is typically equal to the number of rows in the
table.
*/

-- Example: COUNT the number of rows in a table
SELECT COUNT(*) AS order_count
FROM orders
WHERE occurred_at BETWEEN '2016-12-01' AND '2017-01-01';

-- COUNT & NULLs

/*
The COUNT function can also be used to count the number of non-null records in
an individual column.

COUNT does not consider rows that have NULL values.
*/

-- Example:
SELECT COUNT(id) AS account_id_count
FROM accounts;

--------------------------------------------------------------------------------

-- SUM

/*
Unlike COUNT, you can only use SUM on numeric columns. However, SUM will ignore
NULL values.
*/

--Example:
SELECT SUM(standard_qty) AS standard,
       SUM(gloss_qty) AS gloss,
       SUM(poster_qty) AS poster_qty
       FROM orders;

/*
An important thing to remember: aggregators only aggregate vertically - the
values of a column. If you want to perform a calculation across rows, you would
do this with simple arithmetic.
*/
-- Example：calculation across rows
SELECT year,
       month,
       west,
       south,
       west + south AS south_plus_west
FROM tutorial.us_housing_units;


-- Questions；

/*
Find the total amount of poster_qty paper ordered in the orders table.
*/
SELECT SUM(poster_qty) AS total_poster_sales
FROM orders;

/*
Find the total amount of standard_qty paper ordered in the orders table.
*/
SELECT SUM(standard_qty) AS total_standard_sales
FROM orders;

/*
Find the total dollar amount of sales using the total_amt_usd in the orders
table.
*/
SELECT SUM(total_amt_usd) AS total_dollar_sales
FROM orders;

/*
Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each
order in the orders table. This should give a dollar amount for each order in
the table.
*/
SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;


/*
Find the standard_amt_usd per unit of standard_qty paper. Your solution should
use both an aggregation and a mathematical operator.
*/
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

--------------------------------------------------------------------------------

-- MIN & MAX

/*
Functionally, MIN and MAX are similar to COUNT in that they can be used on
non-numerical columns. Depending on the column type, MIN will return the lowest
number, earliest date, or non-numerical value as early in the alphabet as
possible. As you might suspect, MAX does the opposite—it returns the highest
number, the latest date, or the non-numerical value closest alphabetically
to “Z.”
*/

-- Example:
SELECT MIN(standard_qty) AS standard_min
       MIN(gloss_qty) AS gloss_min,
       MAX(poster_qty) AS poster_max
FROM orders;

--------------------------------------------------------------------------------

-- AVG

/*
 is the sum of all of the values in the column divided by the number of values
 in a column. This aggregate function again ignores the NULL values in both the
 numerator and the denominator.

 If you want to count NULLs as zero, you will need to use SUM and COUNT.
*/

-- Example:
SELECT AVG(standard_qty) AS standard_avg,
       AVG(gloss_qty) AS gloss_avg,
       AVG(poster_qty) AS poster_avg
FROM orders;


-- Questions:

/*
When was the earliest order ever placed? You only need to return the date.
*/
SELECT MIN(occurred_at) AS earliest_order_date
FROM orders;

/*
Try performing the same query as in question 1 without using an aggregation
function.
*/
SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

/*
When did the most recent (latest) web_event occur?
*/
SELECT MAX(occurred_at)
FROM web_events;

/*
Try to perform the result of the previous query without using an aggregation
function.
*/
SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

/*
Find the mean (AVERAGE) amount spent per order on each paper type, as well as
the mean amount of each paper type purchased per order. Your final answer should
have 6 values - one for each paper type for the average number of sales, as well
as the average amount.
*/
SELECT AVG(standard_qty) AS average_standard_amount,
       AVG(gloss_qty) AS average_gloss_amount,
       AVG(poster_qty) AS average_poster_amount,
       AVG(standard_amt_usd) AS average_standard_usd,
       AVG(gloss_amt_usd) AS average_gloss_usd,
       AVG(poster_amt_usd) AS average_poster_usd
FROM orders;


/*
What is the MEDIAN total_usd spent on all orders?
*/
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1 -- SUBQUERY
ORDER BY total_amt_usd DESC
LIMIT 2
/*
Since there are 6912 orders - we want the average of the 3457 and 3456 order
amounts when ordered.
*/

--------------------------------------------------------------------------------

-- GROUP BY

/*
GROUP BY can be used to aggregate data within subsets of the data. For example,
grouping for different accounts, different regions, or different sales
representatives.
*/

/*
Any column in the SELECT statement that is not within an aggregator must be in
the GROUP BY clause.
*/

/*
The GROUP BY always goes between WHERE and ORDER BY.
*/

/*
 it is worth noting that SQL evaluates the aggregations before the LIMIT clause.
 If you don’t group by any columns, you’ll get a 1-row result—no problem there.
 If you group by a column with enough unique values that it exceeds the LIMIT
 number, the aggregates will be calculated, and then some rows will simply be
 omitted from the results.
*/

-- Example:
SELECT account_id,
       SUM(standard_qty) AS standard_sum,
       SUM(gloss_qty) AS gloss_sum,
       SUM(poster_qty) AS poster_sum,
FROM orders
GROUP BY account_id
ORDER BY account_id;


-- Questions:

/*
Which account (by name) placed the earliest order? Your solution should have the
account name and the date of the order.
*/
select accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
ORDER BY orders.occurred_at
LIMIT 1;

/*
Find the total sales in usd for each account. You should include two columns -
the total sales for each company's orders in usd and the company name.
*/
SELECT accounts.name AS company_name,
       SUM(orders.total_amt_usd) AS total_sales
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
ORDER BY accounts.name;

/*
Via what channel did the most recent (latest) web_event occur, which account was
associated with this web_event? Your query should return only three values -
the date, channel, and account name.
*/
SELECT web_events.channel, web_events.occurred_at,accounts.name
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
ORDER BY web_events.occurred_at DESC
LIMIT 1;

/*
Find the total number of times each type of channel from the web_events was used.
Your final table should have two columns - the channel and the number of times
the channel was used.
*/
SELECT channel, COUNT(channel) -- or COUNT(*)
FROM web_events
GROUP BY channel
ORDER BY channel;

/*
Who was the primary contact associated with the earliest web_event?
*/
SELECT web_events.occurred_at, accounts.primary_poc
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
ORDER BY web_events.occurred_at
LIMIT 1;

/*
What was the smallest order placed by each account in terms of total usd.
Provide only two columns - the account name and the total usd. Order from
smallest dollar amounts to largest.
*/
SELECT accounts.name, MIN(orders.total_amt_usd) AS smallest_order_usd
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
ORDER BY smallest_order_usd;

/*
Find the number of sales reps in each region. Your final table should have two
columns - the region and the number of sales_reps. Order from fewest reps to
most reps.
*/
SELECT region.name, COUNT(sales_reps.name) AS number_of_sales_reps -- or COUNT(*)
FROM region
JOIN sales_reps
ON region.id = sales_reps.region_id
GROUP BY region.name
ORDER BY number_of_sales_reps;


-- GROUP BY multiple columns

/*
The order of column names in your GROUP BY clause doesn’t matter—the results
will be the same regardless.
*/

/*
As with ORDER BY, you can substitute numbers for column names in the GROUP BY
clause. It’s generally recommended to do this only when you’re grouping many
columns, or if something else is causing the text in the GROUP BY clause to be
excessively long.
*/

/*
any column that is not within an aggregation must show up in your GROUP BY
statement.
*/

-- Example:
SELECT account_id,
       channel,
       COUNT(id) AS web_events
FROM web_events_full
GROUP BY account_id, channel -- order doesn't matter
ORDER BY account_id, channel -- order matters


-- Questions:

/*
For each account, determine the average amount of each type of paper they
purchased across their orders. Your result should have four columns - one for
the account name and one for the average quantity purchased for each of the
paper types for each account.
*/
SELECT accounts.name,
       AVG(orders.standard_qty) standard_mean,
       AVG(orders.gloss_qty) gloss_mean,
       AVG(orders.poster_qty) poster_mean
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name;

/*
For each account, determine the average amount spent per order on each paper
type. Your result should have four columns - one for the account name and one
for the average amount spent on each paper type.
*/
SELECT accounts.name,
       AVG(orders.standard_amt_usd) standard_mean_usd,
       AVG(orders.gloss_amt_usd) gloss_mean_usd,
       AVG(orders.poster_amt_usd) poster_mean_usd
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name;

/*
Determine the number of times a particular channel was used in the web_events
table for each sales rep. Your final table should have three columns - the name
of the sales rep, the channel, and the number of occurrences. Order your table
with the highest number of occurrences first.
*/
SELECT sales_reps.name, web_events.channel, COUNT(web_events.channel) -- or COUNT(*)
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id
JOIN web_events
ON web_events.account_id = accounts.id
GROUP BY sales_reps.name, web_events.channel
ORDER BY count DESC;

/*
Determine the number of times a particular channel was used in the web_events
table for each region. Your final table should have three columns - the region
name, the channel, and the number of occurrences. Order your table with the
highest number of occurrences first.
*/
SELECT region.name, web_events.channel, COUNT(web_events.channel) -- or COUNT(*)
FROM region
JOIN sales_reps
ON sales_reps.region_id = region.id
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id
JOIN web_events
ON web_events.account_id = accounts.id
GROUP BY region.name, web_events.channel
ORDER BY count DESC;

--------------------------------------------------------------------------------

-- DISTINCT

/*
DISTINCT is always used in SELECT statements, and it provides the unique rows
for all columns written in the SELECT statement. Therefore, you only use
DISTINCT once in any particular SELECT statement.
*/

-- Example:
-- You could write
SELECT DISTINCT column1, column2, column3
FROM table1;
-- which would return the unique (or DISTINCT) rows across all three columns.
-- You would not write
SELECT DISTINCT column1, DISTINCT column2, DISTINCT column3
FROM table1;

/*
It’s worth noting that using DISTINCT, particularly in aggregations, can slow
your queries down quite a bit.
*/


-- Questions

/*
Use DISTINCT to test if there are any accounts associated with more than one
region.
*/
SELECT a.id AS "account id", -- use "" here (alias)
       r.id AS "region id",
       a.name AS "account name",
       r.name AS "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;
-- and
SELECT DISTINCT a.id, a.name
FROM accounts a;
/*
The above two queries have the same number of resulting rows (351), so we know
that every account is associated with only one region. If each account was
associated with more than one region, the first query should have returned more
rows than the second query.
*/



/*
Have any sales reps worked on more than one account?
*/
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;
-- and
SELECT DISTINCT id, name
FROM sales_reps;
/*
Actually all of the sales reps have worked on more than one account. The fewest
number of accounts any sales rep works on is 3. There are 50 sales reps, and
they all have more than one account. Using DISTINCT in the second query assures
that all of the sales reps are accounted for in the first query.
*/

--------------------------------------------------------------------------------

-- HAVING

/*
HAVING is the “clean” way to filter a query that has been aggregated, but this
is also commonly done using a subquery. Essentially, any time you want to
perform a WHERE on an element of your query that was created by an aggregate,
you need to use HAVING instead.
*/

-- Example:
SELECT account_id,
       SUM(total_amt_usd) AS sum_total_amt_usd
       FROM orders
       GROUP BY 1 -- group by the 1st column regardless of what it's called
       HAVING SUM(total_amt_usd) >= 250000
       ORDER BY 2 DESC -- order by the 2nd column regardless of what it's called

-- WHERE & HAVING
-- WHERE appears after the FROM, JOIN,and ON, but before GROUP BY
-- HAVING appears after the GROUP BY, but before the ORDER BY
-- HAVING is like WHERE, but it works on logical statements involving aggregations.


-- Questions:

/*
How many of the sales reps have more than 5 accounts that they manage?
*/
SELECT sales_reps.name "sales reps", COUNT(accounts.name) num_accounts
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id
GROUP BY sales_reps.name
HAVING COUNT(accounts.name) > 5; -- cannot use alias here -- 34
-- or
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;
-- or (using a subquery)
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.id, s.name, COUNT(*) num_accounts
     FROM accounts a
     JOIN sales_reps s
     ON s.id = a.sales_rep_id
     GROUP BY s.id, s.name
     HAVING COUNT(*) > 5
     ORDER BY num_accounts) AS Table1;

/*
How many accounts have more than 20 orders?
*/
SELECT accounts.name, COUNT(orders.id) num_orders
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
HAVING COUNT(orders.id) > 20;
-- or
SELECT sales_reps.name "sales reps", COUNT(accounts.name) num_accounts
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id
GROUP BY sales_reps.name
HAVING COUNT(accounts.name) > 5;

/*
Which account has the most orders?
*/
SELECT accounts.name, COUNT(orders.id) num_orders
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
HAVING COUNT(orders.id) > 20
ORDER BY num_orders DESC
LIMIT 1;


/*
Which accounts spent more than 30,000 usd total across all orders?
*/
SELECT accounts.name account, SUM(orders.total_amt_usd) total_usd
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
HAVING SUM(orders.total_amt_usd) > 30000;

/*
Which accounts spent less than 1,000 usd total across all orders?
*/
SELECT accounts.name account, SUM(orders.total_amt_usd) total_usd
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
HAVING SUM(orders.total_amt_usd) < 1000;

/*
Which account has spent the most with us?
*/
SELECT accounts.name account, SUM(orders.total_amt_usd) total_usd
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
ORDER BY total_usd DESC
LIMIT 1;

/*
Which account has spent the least with us?
*/
SELECT accounts.name account, SUM(orders.total_amt_usd) total_usd
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY accounts.name
ORDER BY total_usd
LIMIT 1;

/*
Which accounts used facebook as a channel to contact customers more than 6
times?
*/
SELECT accounts.name account, COUNT(web_events.channel) facebook_count
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
WHERE web_events.channel = 'facebook'
GROUP BY accounts.name
HAVING COUNT(web_events.channel) > 6;
-- or
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

/*
Which account used facebook most as a channel?
*/
SELECT accounts.name account, COUNT(web_events.channel) facebook_count
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
WHERE web_events.channel = 'facebook'
GROUP BY accounts.name
ORDER BY facebook_count DESC
LIMIT 1; -- Gilead Sciences
-- or
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 1;
/*
This query above only works if there are no ties for the account that used
facebook the most. It is a best practice to use a larger limit number first such
as 3 or 5 to see if there are ties before using LIMIT 1.
*/

/*
Which channel was most frequently used by most accounts?
*/
SELECT web_events.channel,COUNT(accounts.name) num_accounts
FROM web_events
JOIN accounts
ON accounts.id = web_events.account_id
GROUP BY web_events.channel
ORDER BY num_accounts DESC;
LIMIT 10;
-- or
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;

--------------------------------------------------------------------------------

-- DATE Functions
-- Date is stored as YYYY-MM-DD in SQL


-- DATE_TRUNC
-- https://mode.com/blog/date-trunc-sql-timestamp-function-count-on/

/*
DATE_TRUNC allows you to truncate your date to a particular part of your
date-time column. Common trunctions are day, month, and year.
*/

-- Example:
SELECT DATE_TRUNC('day',occurred_at) AS day,
       SUM(standard_qty) AS standard_qty_sum
FROM demo.orders
GROUP BY DATE_TRUNC('day',occurred_at)
ORDER BY DATE_TRUNC('day',occurred_at)
-- 2013-12-04 07：08:49 → 2013-12-04 00:00:00


-- DATE_PART

/*
DATE_PART can be useful for pulling a specific portion of a date, but notice
pulling month or day of the week (dow) means that you are no longer keeping the
years in order. Rather you are grouping for certain components regardless of
which year they belonged in.
*/

-- Example:
SELECT DATE_PART("dow",occurred_at) AS day_of_week, -- dow: day of week
       account_id,
       occurred_at,
       total
FROM orders
-- DATE_PART ("dow",occurred_at) returns values from 0 to 6 (0-Sunday, 6-Saturday)

-- Example:
SELECT DATE_PART("dow",occurred_at) AS day_of_week,
       SUM(total) AS toatl_qty
FROM orders
GROUP BY 1
-- this 1 refers to the first of the columns included in the select statement
ORDER BY 2 DESC
-- this 2 refers to the second of the columns included in the select statement

-- Other DATE Functions:
-- https://www.postgresql.org/docs/9.1/functions-datetime.html


-- Questions:

/*
Find the sales in terms of total dollars for all orders in each year, ordered
from greatest to least. Do you notice any trends in the yearly sales totals?
*/
SELECT DATE_TRUNC('year',orders.occurred_at) AS year,
SUM(orders.total_amt_usd) AS total_sales
FROM orders
GROUP BY DATE_TRUNC('year',orders.occurred_at)
ORDER BY total_sales DESC;
-- or
SELECT DATE_PART('year',orders.occurred_at) AS year,
SUM(orders.total_amt_usd) AS total_sales
FROM orders
GROUP BY DATE_PART('year',orders.occurred_at)
ORDER BY total_sales DESC;

/*
Which month did Parch & Posey have the greatest sales in terms of total dollars?
Are all months evenly represented by the dataset?
*/
SELECT DATE_PART('month',orders.occurred_at) AS month,
       SUM(orders.total_amt_usd) AS total_sales
FROM orders
WHERE orders.occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY DATE_PART('month',orders.occurred_at)
ORDER BY total_sales DESC;
/*
If we look further at the monthly data, we see that for 2013 and 2017 there is
only one month of sales for each of these years (12 for 2013 and 1 for 2017).
In order for this to be 'fair', we should remove the sales from 2013 and 2017.
*/

/*
Which year did Parch & Posey have the greatest sales in terms of total number of
orders? Are all years evenly represented by the dataset?
*/
SELECT DATE_PART('year',orders.occurred_at) AS year,
       COUNT(*) AS total_number
FROM orders
GROUP BY 1
ORDER BY total_number DESC;
-- 2013 and 2017 are not evenly represented to the other years in the dataset.


/*
Which month did Parch & Posey have the greatest sales in terms of total number
of orders? Are all months evenly represented by the dataset?
*/
SELECT DATE_PART('month',orders.occurred_at) AS month,
       COUNT(orders.total) AS total_number
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY total_number DESC;


/*
In which month of which year did Walmart spend the most on gloss paper in terms
of dollars?
*/
SELECT DATE_TRUNC('month',orders.occurred_at) AS month,
       SUM(orders.gloss_amt_usd) AS gloss_sales
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
WHERE accounts.name = 'Walmart'
GROUP BY 1
ORDER BY gloss_sales DESC
LIMIT 3;

--------------------------------------------------------------------------------

-- CASE Statements

/*
The CASE statement always goes in the SELECT clause.
*/

/*
CASE must include the following components: WHEN, THEN, and END. ELSE is an
optional component to catch cases that didn’t meet any of the other previous
CASE conditions.
*/

/*
You can make any conditional statement using any conditional operator
(like WHERE) between WHEN and THEN. This includes stringing together multiple
conditional statements using AND and OR.
*/

/*
You can include multiple WHEN statements, as well as an ELSE statement again,
to deal with any unaddressed conditions.
*/

-- Example:

SELECT account_id,
       occurred_at,
       total,
       CASE WHEN total > 500 THEN 'Over 500'
            WHEN total < 500 AND total > 300 THEN '301 - 500'
            WHEN total > 100 AND total < 300 THEN '101 - 300'
            ELSE '100 or under' END AS total_group
FROM orders;

/*
Let's use a CASE statement. This way any time the standard_qty is zero, we will
return 0, and otherwise we will return the unit_price.
*/
SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;


-- CASE & Aggregations

SELECT CASE WHEN total > 500 THEN 'Over 500'
            ELSE '500 or under' END AS total_group,
            COUNT(*) AS order_count
FROM orders
GROUP BY 1;


-- Questions:

/*
Write a query to display for each order, the account ID, total amount of the
order, and the level of the order - ‘Large’ or ’Small’ - depending on if the
order is $3000 or more, or smaller than $3000.
*/
SELECT id,
       account_id,
       total_amt_usd,
       CASE WHEN total_amt_usd >= 3000 THEN 'Large'
       ELSE 'Small' END AS order_level
FROM orders;

/*
Write a query to display the number of orders in each of three categories,
based on the total number of items in each order. The three categories are:
'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
*/
SELECT CASE WHEN total < 1000 THEN 'Less than 1000'
            WHEN total < 2000 AND total >= 1000 THEN 'Between 1000 and 2000'
            ELSE 'At least 2000' END AS order_category,
       COUNT(*) AS num_orders
FROM orders
GROUP BY 1;

/*
We would like to understand 3 different levels of customers based on the amount
associated with their purchases. The top level includes anyone with a Lifetime
Value (total sales of all orders) greater than 200,000 usd. The second level is
between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd.
Provide a table that includes the level associated with each account. You should
provide the account name, the total sales of all orders for the customer, and
the level. Order with the top spending customers listed first.
*/
SELECT accounts.name, SUM(orders.total_amt_usd),
       CASE WHEN SUM(orders.total_amt_usd) > 200000 THEN 'Top level'
            WHEN SUM(orders.total_amt_usd) <= 200000 AND
                 SUM(orders.total_amt_usd) >= 100000 THEN 'Middle level'
            ELSE 'Low level' END AS level
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
GROUP BY 1
ORDER BY 2 DESC;
-- or
SELECT a.name, SUM(total_amt_usd) total_spent,
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY 2 DESC;

/*
We would now like to perform a similar calculation to the first, but we want to
obtain the total amount spent by customers only in 2016 and 2017. Keep the same
levels as in the previous question. Order with the top spending customers listed
first.
*/
SELECT accounts.name, SUM(orders.total_amt_usd) total_spent,
       CASE WHEN SUM(orders.total_amt_usd) > 200000 THEN 'Top level'
            WHEN SUM(orders.total_amt_usd) <= 200000 AND
                 SUM(orders.total_amt_usd) >= 100000 THEN 'Middle level'
            ELSE 'Low level' END AS level
FROM accounts
JOIN orders
ON orders.account_id = accounts.id
WHERE DATE_PART('year',orders.occurred_at) IN ('2016','2017')
GROUP BY 1
ORDER BY 2 DESC;
-- or
SELECT a.name, SUM(total_amt_usd) total_spent,
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31'
GROUP BY 1
ORDER BY 2 DESC;

/*
We would like to identify top performing sales reps, which are sales reps
associated with more than 200 orders. Create a table with the sales rep name,
the total number of orders, and a column with top or not depending on if they
have more than 200 orders. Place the top sales people first in your final table.
*/
SELECT sales_reps.name, COUNT(*) num_orders,
       CASE WHEN COUNT(*) > 200 THEN 'Top'
            ELSE 'Not top' END AS "Sales level"
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id
JOIN orders
ON accounts.id = orders.account_id
GROUP BY 1
ORDER BY 2 DESC;

/*
The previous didn't account for the middle, nor the dollar amount associated
with the sales. Management decides they want to see these characteristics
represented as well. We would like to identify top performing sales reps, which
are sales reps associated with more than 200 orders or more than 750000 in total
sales. The middle group has any rep with more than 150 orders or 500000 in sales.
Create a table with the sales rep name, the total number of orders, total sales
across all orders, and a column with top, middle, or low depending on this
criteria. Place the top sales people based on dollar amount of sales first in
your final table. You might see a few upset sales people by this criteria!
*/
SELECT sales_reps.name,
       COUNT(*) num_orders,
       SUM(orders.total_amt_usd) total_sales,
       CASE WHEN COUNT(*) > 200 OR SUM(orders.total_amt_usd) > 750000 THEN 'Top'
            WHEN (COUNT(*) > 150 AND COUNT(*) <= 200) OR
                 (SUM(orders.total_amt_usd) > 500000 AND
                 SUM(orders.total_amt_usd) <= 750000) THEN 'Middle'
            ELSE 'Low' END AS "Sales level"
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id
JOIN orders
ON accounts.id = orders.account_id
GROUP BY 1
ORDER BY 3 DESC;
