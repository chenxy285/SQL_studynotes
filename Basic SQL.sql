-- SELECT FROM LIMIT

SELECT occurred_at, account_id, channel
FROM web_events
LIMIT 15;

--------------------------------------------------------------------------------

-- ORDER BY

/*
The ORDER BY statement always comes in a query after the SELECT and FROM
statements, but before the LIMIT statement. If you are using the LIMIT
statement, it will always appear last. As you learn additional commands,
the order of these statements will matter more.
*/
SELECT *
FROM orders
ORDER BY occurred_at DESC
LIMIT 1000;

/*
Write a query to return the 10 earliest orders in the orders table.
Include the id, occurred_at, and total_amt_usd.
*/
SELECT id, occurred_at, total_amt_usd
FROM orders
LIMIT 10;

/*
Write a query to return the top 5 orders in terms of largest total_amt_usd.
Include the id, account_id, and total_amt_usd.
*/
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

/*
Write a query to return the lowest 20 orders in terms of smallest total_amt_usd.
Include the id, account_id, and total_amt_usd.
*/
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20;

-- order by multiple columns
/*
It can be ordered by multiple columns in the order of the column names.
Here is ordering the data by account_id ascendingly and by total_amt_usd
descendingly when the account_id is the same.
*/
SELECT account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC;

--------------------------------------------------------------------------------

--- WHERE

/*
Using the WHERE statement, we can display subsets of tables based on conditions
that must be met. You can also think of the WHERE command as filtering the data.
*/
SELECT *
FROM orders
WHERE account_id = 4251    # SELECT first, the ORDER
ORDER BY occurred_at
LIMIT 1000;

-- WHERE with non-numeric data
/*
We can use the = and != operators here. You need to be sure to use single quotes
(just be careful if you have quotes in the original text) with the text data,
not double quotes.
*/
SELECT *
FROM accounts
WHERE name = 'United Technologies';

--------------------------------------------------------------------------------

-- Derived columns

SELECT account_id,
       occurred_at,
       standard_qty,
       gloss_qty,
       poster_qty,
       gloss_qty + poster_qty AS nonstandard_qty
FROM orders;
-- mathematical operators: +; -; *; /
-- Use the AS keyword to name this new column.

--------------------------------------------------------------------------------

-- Introduction to Logical Operators

LIKE
/*
This allows you to perform operations similar to using WHERE and =,
but for cases when you might not know exactly what you are looking for.
*/

IN
/*
This allows you to perform operations similar to using WHERE and =,
but for more than one condition.
*/

NOT
/*
This is used with IN and LIKE to select all of the rows NOT LIKE or NOT IN a
certain condition.
*/

AND & BETWEEN
/*
These allow you to combine operations where all combined conditions must be
true.
*/

OR
/*
This allow you to combine operations where at least one of the combined
conditions must be true.
*/

--------------------------------------------------------------------------------

-- LIKE

/*
The LIKE operator is extremely useful for working with text. You will use LIKE
within a WHERE clause. The LIKE operator is frequently used with %.
The % tells us that we might want any number of characters leading up to a
particular set of characters or following a certain set of characters,
as we saw with the google syntax above. Remember you will need to use single
quotes for the text you pass to the LIKE operator, because of this lower and
uppercase letters are not the same within the string. Searching for 'T' is not
the same as searching for 't'. In other SQL environments
(outside the classroom), you can use either single or double quotes.
*/

-- Use the accounts table to find

-- All the companies whose names start with 'C'.
SELECT name
FROM accounts
WHERE name LIKE 'C%';

-- All companies whose names contain the string 'one' somewhere in the name.
SELECT name
FROM accounts
WHERE name LIKE '%one%';

-- All companies whose names end with 's'.
SELECT name
FROM accounts
WHERE name LIKE '%s';

--------------------------------------------------------------------------------

-- IN

/*
The IN operator is useful for working with both numeric and text columns.
This operator allows you to use an =, but for more than one item of that
particular column. We can check one, two or many column values for which we
want to pull data, but all within the same query.
In the upcoming concepts, you will see the OR operator that would also allow us
to perform these tasks, but the IN operator is a cleaner way to write these
queries.
*/

/*
Use the accounts table to find the account name, primary_poc, and sales_rep_id
for Walmart, Target, and Nordstrom.
*/
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart','Target','Nordstrom');

/*
Use the web_events table to find all information regarding individuals who were
contacted via the channel of organic or adwords.
*/
SELECT *
FROM web_events
WHERE channel IN ('organic','adwords');

--------------------------------------------------------------------------------

-- NOT

/*
The NOT operator is an extremely useful operator for working with the previous
two operators we introduced: IN and LIKE. By specifying NOT LIKE or NOT IN,
we can grab all of the rows that do not meet a particular criteria.
*/

/*
Use the accounts table to find the account name, primary poc, and sales rep id
for all stores except Walmart, Target, and Nordstrom.
*/
SELECT name, primary_poc,sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart','Target','Nordstrom');

/*
Use the web_events table to find all information regarding individuals who were
contacted via any method except using organic or adwords methods.
*/
SELECT *
FROM web_events
WHERE channel NOT IN ('organic','adwords');

-- Use the accounts table to find:

-- All the companies whose names do not start with 'C'.
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%';

-- All companies whose names do not contain the string 'one' somewhere in the
-- name.
SELECT name
FROM accounts
WHERE name NOT LIKE '%one%';

-- All companies whose names do not end with 's'.
SELECT name
FROM accounts
WHERE name NOT LIKE '%s';


--------------------------------------------------------------------------------

-- AND

/*
The AND operator is used within a WHERE statement to consider more than one
logical clause at a time. Each time you link a new statement with an AND, you
will need to specify the column you are interested in looking at. You may link
as many statements as you would like to consider at the same time. This operator
works with all of the operations we have seen so far including arithmetic
operators (+, *, -, /). LIKE, IN, and NOT logic can also be linked together
using the AND operator.
*/

-- BETWEEN

/*
Sometimes we can make a cleaner statement using BETWEEN than we can using AND.
Particularly this is true when we are using the same column for different parts
of our AND statement.
*/

-- Instead of writing
WHERE column >= 6 AND column <= 10
-- We can write
WHERE column BETWEEN 6 AND 10

/*
Write a query that returns all the orders where the standard_qty is over 1000,
the poster_qty is 0, and the gloss_qty is 0.
*/
SELECT *
FROM orders
WHERE standard_qty>1000 AND poster_qty = 0 AND gloss_qty = 0;

/*
Using the accounts table, find all the companies whose names do not start with
'C' and end with 's'.
*/
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s';

/*
When you use the BETWEEN operator in SQL, do the results include the values of
your endpoints, or not? Figure out the answer to this important question by
writing a query that displays the order date and gloss_qty data for all orders
where gloss_qty is between 24 and 29. Then look at your output to see if the
BETWEEN operator included the begin and end values or not.
*/
SELECT occurred_at, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;
-- The results include the values of the endpoints.

/*
Use the web_events table to find all information regarding individuals who were
contacted via the organic or adwords channels, and started their account at any
point in 2016, sorted from newest to oldest.
*/
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords')
AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;
/*
 While BETWEEN is generally inclusive of endpoints, it assumes the time is at
 00:00:00 (i.e. midnight) for dates. This is the reason why we set the
 right-side endpoint of the period at '2017-01-01'.
*/

--------------------------------------------------------------------------------

-- OR

/*
This operator works with all of the operations we have seen so far including
arithmetic operators (+, *, -, /), LIKE, IN, NOT, AND, and BETWEEN logic can all
be linked together using the OR operator.
*/

/*
We frequently might need to use parentheses to assure that logic we want to
perform is being executed correctly.
*/


/*
Find list of orders ids where either gloss_qty or poster_qty is greater than
4000. Only include the id field in the resulting table.
*/
SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;


/*
Write a query that returns a list of orders where the standard_qty is zero and
either the gloss_qty or poster_qty is over 1000.
*/
SELECT *
FROM orders
WHERE standard_qty = 0
AND (gloss_qty > 1000 OR poster_qty > 1000);

/*
Find all the company names that start with a 'C' or 'W', and the primary contact
contains 'ana' or 'Ana', but it doesn't contain 'eana'.
*/
SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
AND primary_poc NOT LIKE '%eana%');

--------------------------------------------------------------------------------
