
-- Example:

SELECT channel,
       AVG(event_count) AS avg_event_count
FROM
(SELECT DATE_TRUNC('day',occurred_at)) AS day,
        channel,
        COUNT(*)  AS event_count
 FROM web_events_full
 GROUP BY 1,2
) sub -- alias of subqueries (must use alias here)
GROUP BY 1
ORDER BY 2 DESC;

- Questions:

/*
Find the number of events that occur for each day for each channel.
*/
SELECT DATE_TRUNC('day',occurred_at) AS date,
       channel,
       COUNT(*) AS num_events
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;

/*
Now create a subquery that simply provides all of the data from your first query.
*/
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel,
             COUNT(*) AS num_events
      FROM web_events
      GROUP BY 1,2
ORDER BY 1,2) sub;

/*
Now find the average number of events for each channel.
*/
SELECT channel, AVG(num_events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
            channel,
            COUNT(*) AS num_events
     FROM web_events
     GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 1,3 DESC;
-- 对每个channel每天events数的平均
-- Get a table that shows the average number of events a day for each channel.

--------------------------------------------------------------------------------

-- Subquery Formatting

-- Example: well formatted query
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2
      ORDER BY 3 DESC) sub;

/*
Additionally, if we have a GROUP BY, ORDER BY, WHERE, HAVING, or any other
statement following our subquery, we would then indent it at the same level as
our outer query.
*/
-- Example:
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2
      ORDER BY 3 DESC) sub
GROUP BY day, channel, events
ORDER BY 2 DESC;

--------------------------------------------------------------------------------

-- More on subqueries

/*
In the first subquery you wrote, you created a table that you could then query
again in the FROM statement. However, if you are only returning a single value,
you might use that value in a logical statement like WHERE, HAVING, or even
SELECT - the value could be nested within a CASE statement.
*/

-- Example:
SELECT *
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
      (WHERE DATE_TRUNC('month',MIN(occurred_at)) AS min_month
       FROM orders)
ORDER BY occurred_at;

/*
Note that you should not include an alias when you write a subquery in a
conditional statement. This is because the subquery is treated as an individual
value (or set of values in the IN case) rather than as a table.
*/

/*
Also, notice the query here compared a single value. If we returned an entire
column IN would need to be used to perform a logical argument. If we are
returning an entire table, then we must use an ALIAS for the table, and perform
additional logic on the entire table.
*/

-- Questions:

/*
Pull month level information about the first order ever placed in the orders
table.
*/
SELECT DATE_TRUNC('month',MIN(occurred_at)) AS min_month
FROM orders;

/*
Use the result of the previous query to find only the orders that took place in
the same month and year as the first order, and then pull the average for each
type of paper qty in this month.
*/
SELECT AVG(standard_qty) average_standard,
       AVG(gloss_qty) average_gloss,
       AVG(poster_qty) average_poster,
       SUM(total_amt_usd) total_spent -- total amount spent on the first month
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
      (SELECT DATE_TRUNC('month',MIN(occurred_at)) AS min_month
       FROM orders);


-- Questions:

/*
1. Provide the name of the sales_rep in each region with the largest amount of
total_amt_usd sales.
*/
SELECT t3.reps_name, t2.region, t2.max_sales
FROM(
    SELECT region, MAX(total_sales) max_sales
    FROM(
        SELECT sales_reps.name reps_name,
               region.name region,
               SUM(total_amt_usd) total_sales
        FROM sales_reps
        JOIN region
        ON region.id = sales_reps.region_id
        JOIN accounts
        ON sales_reps.id = accounts.sales_rep_id
        JOIN orders
        ON orders.account_id = accounts.id
        GROUP BY 1,2) t1
    GROUP BY 1) t2
JOIN(
    SELECT sales_reps.name reps_name,
           region.name region,
           SUM(total_amt_usd) total_sales
    FROM sales_reps
    JOIN region
    ON region.id = sales_reps.region_id
    JOIN accounts
    ON sales_reps.id = accounts.sales_rep_id
    JOIN orders
    ON orders.account_id = accounts.id
    GROUP BY 1,2) t3
ON t3.region = t2.region AND t3.total_sales = t2.max_sales;


/*
2. For the region with the largest (sum) of sales total_amt_usd, how many
total (count) orders were placed?
*/
SELECT t3.count_orders, t2.max_sales, t3.region
FROM (
    SELECT MAX(total_sales) max_sales
    FROM(
        SELECT region.name region,
               SUM(orders.total_amt_usd) total_sales,
               COUNT(orders.total) count_orders
        FROM region
        JOIN sales_reps
        ON region.id = sales_reps.region_id
        JOIN accounts
        ON accounts.sales_rep_id = sales_reps.id
        JOIN orders
        ON accounts.id = orders.account_id
        GROUP BY 1
        ) t1
    )t2
JOIN (
      SELECT region.name region,
             SUM(orders.total_amt_usd) total_sales,
             COUNT(orders.total) count_orders
      FROM region
      JOIN sales_reps
      ON region.id = sales_reps.region_id
      JOIN accounts
      ON accounts.sales_rep_id = sales_reps.id
      JOIN orders
      ON accounts.id = orders.account_id
      GROUP BY 1
     ) t3
ON t3.total_sales = t2.max_sales;

-- or

SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);

/*
3. How many accounts had more total purchases than the account name which has
bought the most standard_qty paper throughout their lifetime as a customer?
*/
SELECT COUNT(*)
FROM (
      SELECT accounts.name
      FROM accounts
      JOIN orders
      ON accounts.id = orders.account_id
      GROUP BY 1
      HAVING SUM(orders.total) >
             (SELECT total
             FROM ( SELECT accounts.name account,
                    SUM(orders.standard_qty) total_standard,
                    SUM (orders.total) total
                    FROM accounts
                    JOIN orders
                    ON accounts.id = orders.account_id
                    GROUP BY 1
                    ORDER BY 2 DESC
                    LIMIT 1) t1
             )
      ) t3;

/*
4. For the customer that spent the most (in total over their lifetime as a
customer) total_amt_usd, how many web_events did they have for each channel?
*/
SELECT accounts.name, web_events.channel, COUNT(*)
FROM web_events
JOIN accounts
ON accounts.id = web_events.account_id
WHERE accounts.name =
      (SELECT account
       FROM (
             SELECT accounts.name account, SUM(orders.total_amt_usd) total_spent
             FROM accounts
             JOIN orders
             ON accounts.id = orders.account_id
             GROUP BY 1
             ORDER BY 2 DESC
             LIMIT 1
           ) t1
      )
GROUP BY 1,2
ORDER BY COUNT(*) DESC ;

/*
5. What is the lifetime average amount spent in terms of total_amt_usd for the top
10 total spending accounts?
*/

SELECT AVG(total_spent) average_amount
FROM(
    SELECT accounts.name, SUM(orders.total_amt_usd) total_spent
    FROM accounts
    JOIN orders
    ON accounts.id = orders.account_id
    GROUP BY 1
    ORDER BY total_spent DESC
    LIMIT 10 ) t1;

/*
6. What is the lifetime average amount spent in terms of total_amt_usd, including
only the companies that spent more per order, on average, than the average of
all orders.
*/
SELECT AVG(account_avg_amount)
FROM (
      SELECT accounts.name, AVG(orders.total_amt_usd) account_avg_amount
      FROM accounts
      JOIN orders
      ON accounts.id = orders.account_id
      GROUP BY 1
      HAVING AVG(orders.total_amt_usd) > (
             SELECT AVG(orders.total_amt_usd) avg_all
             FROM orders )
     ) t1;

--------------------------------------------------------------------------------

-- Subqueries using WITH

/*
The WITH statement is often called a Common Table Expression or CTE. Though
these expressions serve the exact same purpose as subqueries, they are more
common in practice, as they tend to be cleaner for a future reader to follow the
logic.
*/

-- Example:

WITH events AS (
            SELECT DATE_TRUNC('day',occurred_at) AS day,
                   channel,
                   COUNT(*) AS avg_event_count
            FROM erb_events_full
            GROUP BY 1,2)
SELECT channel
       AVG(events_count) AS avg_event_count
FROM events
GROUP BY 1
ORDER BY 2 DESC;


-- If we need to create a second table to pull from:

WITH table1 AS (
            SELECT *
            FROM web_events), -- comma
     table2 AS (
            SELECT *
            FROM accounts)
SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id

-- Questions:

/*
1. Provide the name of the sales_rep in each region with the largest amount of
total_amt_usd sales.
*/
WITH table1 AS (SELECT region.name region,
                       sales_reps.name reps_name,
                       SUM(orders.total_amt_usd) total_sales
                FROM region
                JOIN sales_reps
                ON region.id = sales_reps.region_id
                JOIN accounts
                ON accounts.sales_rep_id = sales_reps.id
                JOIN orders
                ON orders.account_id = accounts.id
                GROUP BY 1,2 ),

      table2 AS (SELECT region, MAX(total_sales) max_sales
      FROM table1
      GROUP BY 1 )

SELECT table1.region, table1.reps_name, table2.max_sales
FROM table1
JOIN table2
ON table1.region = table2.region AND table1.total_sales = table2.max_sales;

/*
2. For the region with the largest (sum) of sales total_amt_usd, how many
total (count) orders were placed?
*/
WITH table1 AS (SELECT region.name region, SUM(orders.total_amt_usd) total_sales
                FROM region
                JOIN sales_reps
                ON sales_reps.region_id = region.id
                JOIN accounts
                ON sales_reps.id = accounts.sales_rep_id
                JOIN orders
                ON orders.account_id = accounts.id
                GROUP BY 1),
      table2 AS (SELECT MAX(total_sales) max_sales
                 FROM table1)

SELECT region.name region, COUNT(*) count_orders, SUM(orders.total_amt_usd) total_sales
FROM  region
JOIN sales_reps
ON sales_reps.region_id = region.id
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id
JOIN orders
ON orders.account_id = accounts.id
GROUP BY 1
HAVING SUM(orders.total_amt_usd) = (SELECT max_sales
                                    FROM table2);

/*
3. How many accounts had more total purchases than the account name which has
bought the most standard_qty paper throughout their lifetime as a customer?
*/
WITH table1 AS (SELECT accounts.name account,
                SUM(orders.standard_qty) amount_standard,
                SUM(orders.total) total
                FROM accounts
                JOIN orders
                ON orders.account_id = accounts.id
                GROUP BY 1
                ORDER BY 2 DESC
                LIMIT 1), -- 找出amount_standard最大的行
     table2 AS (SELECT accounts.name
                FROM accounts -- 还是从原始数据集中提取（而不是嵌套上一个）
                JOIN orders
                ON orders.account_id = accounts.id
                GROUP BY 1 -- 找出符合要求的account
                HAVING SUM(orders.total) > (SELECT total FROM table1))
SELECT COUNT(*)
FROM table2;


/*
4. For the customer that spent the most (in total over their lifetime as a
customer) total_amt_usd, how many web_events did they have for each channel?
*/
WITH table1 AS (
            SELECT accounts.id account_id, accounts.name account, SUM(orders.total_amt_usd) total_spent
            FROM accounts
            JOIN orders
            ON orders.account_id = accounts.id
            GROUP BY 1,2
            ORDER BY 3 DESC
            LIMIT 1)

SELECT channel, COUNT(*)
FROM web_events
WHERE account_id = (SELECT account_id FROM table1)
GROUP BY 1

-- or

WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
5. What is the lifetime average amount spent in terms of total_amt_usd for the
top 10 total spending accounts?
*/
WITH table1 AS (
            SELECT accounts.name account,
                   SUM(orders.total_amt_usd) total_spent
            FROM accounts
            JOIN orders
            ON accounts.id = orders.account_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 10)
SELECT AVG(total_spent)
FROM table1;

/*
6. What is the lifetime average amount spent in terms of total_amt_usd, including
only the companies that spent more per order, on average, than the average of
all orders.
*/
WITH table1 AS (
          SELECT accounts.name account, AVG(orders.total_amt_usd) avg_perorder
          FROM accounts
          JOIN orders
          ON accounts.id = orders.account_id
          GROUP BY 1
          HAVING AVG(orders.total_amt_usd) > (
                 SELECT AVG(orders.total_amt_usd) avg_all FROM orders))

SELECT AVG(avg_perorder)
FROM table1;

-- or

WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;
