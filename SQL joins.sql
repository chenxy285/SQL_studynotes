-- INNER JOIN / JOIN

/*
The whole purpose of JOIN statements is to allow us to pull data from more than
one table at a time.

We use ON clause to specify a JOIN condition which is a logical statement to
combine the table in FROM and JOIN statements.
*/


-- Example:
SELECT orders.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;
/*
As we've learned, the SELECT clause indicates which column(s) of data you'd like
to see in the output (For Example, orders.* gives us all the columns in orders
table in the output). The FROM clause indicates the first table from which we're
pulling data, and the JOIN indicates the second table. The ON clause specifies
the column on which you'd like to merge the two tables together.

Above, we are only pulling data from the orders table since in the SELECT
statement we only reference columns from the orders table.
*/


-- Additional Information
/*
The table name is always before the period.
The column you want from that table is always after the period.
*/

/*
For example, if we want to pull only the account name and the dates in which
that account placed an order, but none of the other columns
*/
SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

/*
Alternatively, the below query pulls all the columns from both the accounts and
orders table.
*/
SELECT *
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;


/*
Try pulling all the data from the accounts table, and all the data from the
orders table.
*/
SELECT *
FROM accounts
JOIN orders
ON orders.account_id = accounts.id;
-- You can specify the order of the columns after SELECT ccommand
-- If you use * after SELECT command, you can specify the order using FROM JOIN

/*
Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and
the website and the primary_poc from the accounts table.
*/
SELECT orders.standard_qty, orders.gloss_qty, orders.poster_qty,
accounts.website, accounts.primary_poc
FROM accounts
JOIN orders
ON orders.account_id = accounts.id;

--------------------------------------------------------------------------------

-- Entity Relationship Diagrams (ERD)

/*
an entity relationship diagram (ERD) is a common way to view data in a database.
It is also a key element to understanding how we can pull data from multiple
tables.
https://classroom.udacity.com/courses/ud198/lessons/8f23fc69-7c88-4a94-97a4-d5f6
ef51cf7b/concepts/57f82755-506c-4fb5-af0f-312b52ed340e
*/


--------------------------------------------------------------------------------

-- Primary Key (PK)
/*
The PK here stands for primary key.

The primary key is a single column that must exist in each table of a database
and it is a column that has a unique value for every row.

It is common that the primary key is the first column in our tables in most
databases.
*/

-- Foreign Key (FK)
/*
A foreign key is a column in one table that is a primary key in a different
table.

Each of the foreign key is linked to the primary key of another table.

A table can have multiple foreign keys.
*/

-- Primary - Foreign Key link
/*
In the above image you can see that:
https://classroom.udacity.com/courses/ud198/lessons/8f23fc69-7c88-4a94-97a4-d5f6
ef51cf7b/concepts/049377d5-471c-4695-9233-e44c956cef9c
1) The region_id is the foreign key.
2) The region_id is linked to id - this is the primary-foreign key link that
   connects these two tables.
3) The crow's foot shows that the FK can actually appear in many rows in the
   sales_reps table.
4) While the single line is telling us that the PK shows that id appears only once
   per row in this table.
*/

--------------------------------------------------------------------------------

-- JOIN more than two tables

/*
https://classroom.udacity.com/courses/ud198/lessons/8f23fc69-7c88-4a94-97a4-d5f6
ef51cf7b/concepts/6bcadea2-78dd-4aa5-a9f1-f84be429067b
*/

SELECT web_events.channel, accounts.name, orders.total
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id;
/*
Alternatively, we can create a SELECT statement that could pull specific columns
from any of the three tables. Again, our JOIN holds a table, and ON is a link
for our PK to equal the FK.
*/

--------------------------------------------------------------------------------

-- Alias

-- Example 1:
FROM tablename AS t1
JOIN tablename2 AS t2
-- and
SELECT col1 + col2 AS total, col3

/*
Frequently, you might also see these statements without the AS statement. Each
of the above could be written in the following way instead, and they would still
produce the exact same results:
*/
FROM tablename t1
JOIN tablename2 t2
-- and
SELECT col1 + col2 total, col3


-- Aliases for Columns in Resulting Table

/*
While aliasing tables is the most common use case. It can also be used to alias
the columns selected to have the resulting table reflect a more readable name.
*/
Select t1.column1 aliasname, t2.column2 aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2
/*
The alias name fields will be what shows up in the returned table instead of
t1.column1 and t2.column2.
*/

-- Questions:

/*
1. Provide a table for all web_events associated with account name of Walmart.
There should be three columns. Be sure to include the primary_poc, time of the
event, and the channel for each event. Additionally, you might choose to add a
fourth column to assure only Walmart events were chosen.
*/

SELECT accounts.name,accounts.primary_poc,web_events.occurred_at, web_events.channel
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
WHERE name = 'Walmart';

-- Alias
SELECT a.name,a.primary_poc,w.occurred_at, w.channel
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE name = 'Walmart';

/*
2. Provide a table that provides the region for each sales_rep along with their
associated accounts. Your final table should include three columns: the region
name, the sales rep name, and the account name. Sort the accounts alphabetically
(A-Z) according to account name.
*/

SELECT r.name region, s.name sales_rep,a.name accounts
-- need to specify column name here
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
ORDER BY a.name;

/*
Provide the name for each region for every order, as well as the account name
and the unit price they paid (total_amt_usd/total) for the order. Your final
table should have 3 columns: region name, account name, and unit price.
A few accounts have 0 for total, so I divided by (total + 0.01) to assure not
dividing by zero.
*/
SELECT r.name region, a.name account, o.total_amt_usd/(total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON  o.account_id = a.id;
/*
If you have two or more columns in your SELECT that have the same name after the
table name such as accounts.name and sales_reps.name you will need to alias them.
Otherwise it will only show one of the columns. You can alias them like
accounts.name AS AcountName, sales_rep.name AS SalesRepName
*/

--------------------------------------------------------------------------------
--INNER JOIN:
/*
It only pulls rows only if they exist as a match across two tables.
*/

-- OUTER JOIN (LEFT JOIN & RIGHT JOIN & FULL OUTER JOIN):
/*
It allow us to pull rows that might only exist in one of the two tables.
This will introduce a new data type called NULL.
*/

-- LEFT JOIN
/*
It also return the rows in left table that cannot be matched in right table.
The rows cannot be matched will be empty in the columns from right table.
*/
-- Example:
FROM left table
LEFT JOIN right table
-- or
FROM left table
LEFT OUTER JOIN right table

-- RIGHT JOIN
/*
It also return the rows in right table that cannot be matched in left table.
The rows cannot be matched will be empty in the columns from left table.
*/
FROM right table
RIGHT JOIN left table
-- or
FROM right table
RIGHT OUTER JOIN left table

-- FULL OUTER JOIN
/*
This will return the inner join result set, as well as any unmatched rows from
either of the two tables being joined.
*/

-- LEFT JOIN & RIGHT JOIN are somewhat interchangeable
-- (by switching the tables after FROM and LEFT/RIGHT JOIN)
-- Usually people use LEFT JOIN to be consistent

--------------------------------------------------------------------------------

-- JOINS and Filtering

SELECT orders.*, accounts.*
FROM orders
LEFT JOIN accounts
ON orders.account_id = accounts.id
WHERE accounts.sales_rep_id = 321500;

SELECT orders.*, accounts.*
FROM orders
LEFT JOIN accounts
ON orders.account_id = accounts.id
AND accounts.sales_rep_id = 321500;
-- 相当于满足ON后面这两个条件的rows才会被join，假如使用的是JOIN，效果和使用WHERE一样
-- ON + AND 相当于JOIN前筛选，WHERE 相当于JOIN后筛选


-- Questions

-- Q1
/*
Provide a table that provides the region for each sales_rep along with their
associated accounts. This time only for the Midwest region. Your final table
should include three columns: the region name, the sales rep name, and the
account name. Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT r.name region, s.name sales_rep, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
AND r.name = 'Midwest'
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY  accounts;
-- or
SELECT r.name region, s.name sales_rep, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY  accounts;

-- Q2
/*
Provide a table that provides the region for each sales_rep along with their
associated accounts. This time only for accounts where the sales rep has a first
name starting with S and in the Midwest region. Your final table should include
three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT r.name region, s.name sales_rep, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
AND s.name LIKE 'S%'
ORDER BY accounts;
-- or
SELECT r.name region, s.name sales_rep, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id AND r.name = 'Midwest'
JOIN accounts a
ON a.sales_rep_id = s.id AND s.name LIKE 'S%'
ORDER BY accounts;

-- Q3
/*
Provide a table that provides the region for each sales_rep along with their
associated accounts. This time only for accounts where the sales rep has a last
name starting with K and in the Midwest region. Your final table should include
three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT r.name region, s.name sales_rep, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
AND s.name LIKE '% K%'
ORDER BY accounts;
-- or
SELECT r.name region, s.name sales_rep, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id AND r.name = 'Midwest'
JOIN accounts a
ON a.sales_rep_id = s.id AND s.name LIKE '% K%'
ORDER BY accounts;

-- Q4
/*
Provide the name for each region for every order, as well as the account name
and the unit price they paid (total_amt_usd/total) for the order. However,
you should only provide the results if the standard order quantity exceeds 100.
Your final table should have 3 columns: region name, account name, and unit
price. In order to avoid a division by zero error, adding .01 to the denominator
here is helpful total_amt_usd/(total+0.01).
*/
SELECT r.name region,
       a.name account,
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100;

-- Q5
/*
Provide the name for each region for every order, as well as the account name
and the unit price they paid (total_amt_usd/total) for the order. However, you
should only provide the results if the standard order quantity exceeds 100 and
the poster order quantity exceeds 50. Your final table should have 3 columns:
region name, account name, and unit price. Sort for the smallest unit price
first. In order to avoid a division by zero error, adding .01 to the denominator
here is helpful (total_amt_usd/(total+0.01).
*/
SELECT r.name region,
       a.name account,
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50 -- 不能使用alias？
ORDER BY unit_price;

-- Q6
/*
Provide the name for each region for every order, as well as the account name
and the unit price they paid (total_amt_usd/total) for the order. However,
you should only provide the results if the standard order quantity exceeds 100
and the poster order quantity exceeds 50. Your final table should have 3
columns: region name, account name, and unit price. Sort for the largest unit
price first. In order to avoid a division by zero error, adding .01 to the
denominator here is helpful (total_amt_usd/(total+0.01).
*/
SELECT r.name region,
       a.name account,
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC;

-- Q7
/*
What are the different channels used by account id 1001? Your final table should
have only 2 columns: account name and the different channels. You can try SELECT
DISTINCT to narrow down the results to only the unique values.
*/
SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';

-- Q8
/*
Find all the orders that occurred in 2015. Your final table should have
4 columns: occurred_at, account name, order total, and order total_amt_usd.
*/
SELECT o.occurred_at occurred_at,
       a.name account_name,
       o.total order_total,
       o.total_amt_usd order_total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY total_amt_usd;

--------------------------------------------------------------------------------
