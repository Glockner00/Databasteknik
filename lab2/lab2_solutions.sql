/*
* Axel Glöckner - axegl999
* Olle Håkansson - ollha403
*/

/* Source relevant files*/
SOURCE company_schema.sql;
SOURCE company_data.sql;

/* Task 1: List all employees. */
SELECT * FROM jbemployee;

/* Task 2 : List all the names of the deparments in alphabetical order.*/
SELECT name FROM jbdept ORDER BY name;

/* Task 3 : What parts are not in store? */
SELECT * FROM jbparts WHERE qoh = 0;

/*Task 4 : List all employees with a salary between 9k(included)-10k(included)*/
SELECT * FROM jbemployee WHERE salary BETWEEN 9000 AND 10000;

/*Tasl 5 : List all employees and their age when they started. */
SELECT name, (startyear - birthyear) AS start_age FROM jbemployee;

/*Task 6 : List all employees whose lastname ends with son*/
SELECT * FROM jbemployee WHERE name LIKE '%son';

/* Task 7 : Which items have been deliverd by fischer price.*/
SELECT * FROM jbitem WHERE supplier IN (SELECT id FROM jbsupplier WHERE name = 'Fisher-Price');

/* Task 8 : Same as Task 7 without a subquery */
SELECT * FROM jbitem WHERE supplier = 89;

/* Task 9 : List all cities that have a supplier in them*/
SELECT DISTINCT name FROM jbcity WHERE id IN(SELECT city FROM jbsupplier);

/* Task 10 : What is the name and color of the parts heavier than a card reader?*/
SELECT name, color FROM jbparts WHERE weight > (SELECT weight FROM jbparts WHERE name = "card reader");

/* Task 11 : Formulate the same query as above, but without a subquery. Again, the
query must not contain the weight of the card reader as a constant.*/
SELECT p1.name, p1.color FROM jbparts p1 JOIN jbparts p2 on p2.name = 'card reader' WHERE p1.weight > p2.weight;

/* Task 12 : What is the average weight of all black parts? */
SELECT AVG(weight) AS avg_weight FROM jbparts WHERE color = 'black';

/* Task 13 : For every supplier in Massachusetts (“Mass”), retrieve the name and the
total weight of all parts that the supplier has delivered? Do not forget to
take the quantity of delivered parts into account. Note that one row
should be returned for each supplier.*/
SELECT s.name, SUM(p.weight * sp.quan) AS total_weight 
FROM jbsupplier s 
JOIN jbsupply sp ON s.id = sp.supplier
JOIN jbparts p ON sp.part = p.id
WHERE s.city IN (SELECT id FROM jbcity WHERE state = 'Mass')
GROUP BY s.name;

/* Task 14 : Create a new relation with the same attributes as the jbitems relation by
using the CREATE TABLE command where you define every attribute
explicitly (i.e., not as a copy of another table). Then, populate this new
relation with all items that cost less than the average price for all items.
Remember to define the primary key and foreign keys in your table! */
DROP TABLE IF EXISTS low_prices;
CREATE TABLE low_prices (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    dept INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    qoh INT NOT NULL,
    supplier INT NOT NULL,
    FOREIGN KEY (dept) REFERENCES jbdept(id),
    FOREIGN KEY (supplier) REFERENCES jbsupplier(id)
);

INSERT INTO low_prices
SELECT * FROM jbitem WHERE price < (SELECT AVG(price) FROM jbitem);
SELECT * FROM low_prices;

/* Task 15 : Create a view that contains the items that cost less than the average
price for items. */
DROP VIEW IF EXISTS low_price_items_view;
CREATE VIEW low_price_items_view AS
SELECT * FROM jbitem WHERE price < (SELECT AVG(price) FROM jbitem);

/* Task 16 : What is the difference between a table and a view? One is static and the
other is dynamic. Which is which and what do we mean by static
respectively dynamic? 

A table is static and a view is dynamic.
A view will automatically update when it is called upon each time. Meaning it doesn't save any of the values and requests it each time used.
When a table stores a new value it saves it and doesnt check if the original value updates or gets deleted.
*/


/* Task 17 : Create a view that calculates the total cost of each debit, by considering
price and quantity of each bought item. (To be used for charging
customer accounts). The view should contain the sale identifier (debit)
and the total cost. In the query that defines the view, capture the join
condition in the WHERE clause (i.e., do not capture the join in the
FROM clause by using keywords inner join, right join or left join).*/
DROP VIEW IF EXISTS total_cost_per_debit;
CREATE VIEW total_cost_per_debit AS
SELECT 
    s.debit, 
    SUM(i.price * s.quantity) AS total_cost
FROM 
    jbsale s, jbitem i
WHERE 
    s.item = i.id
GROUP BY 
    s.debit;
SELECT * FROM total_cost_per_debit;

/* Task 18 : <Right>Do the same as in the previous point, but now capture the join conditions
in the FROM clause by using only left, right or inner joins. Hence, the
WHERE clause must not contain any join condition in this case. Motivate
why you use type of join you do (left, right or inner), and why this is the
correct one (in contrast to the other types of joins). */
DROP VIEW IF EXISTS total_cost_per_debit_joined;
CREATE VIEW total_cost_per_debit_joined AS
SELECT
    s.debit,
    SUM(i.price * s.quantity) AS total_cost_joined
FROM
    jbsale s
INNER JOIN
    jbitem i ON s.item = i.id
GROUP BY
    s.debit;
SELECT * FROM total_cost_per_debit_joined;

/*
Motivation: We used inner join between jbsale and jbitem because we only want to unclide sales where there is a corresponding item entry in jbitem. Using a left or right join would include unmatched records which would lead to incomplete cost calculations.

*/

/* Task 19 : Remove all suppliers in Los Angeles from the jbsupplier table. This
will not work right away. Instead, you will receive an error with error
code 23000 which you will have to solve by deleting some other. */

-- (a)
SET SQL_SAFE_UPDATES = 0;
SELECT id FROM jbsupplier WHERE city = 'Los Angeles';
DELETE FROM jbitem WHERE supplier IN(SELECT id FROM jbsupplier WHERE city = 'Los Angeles');
DELETE FROM jbsupplier WHERE city = 'Los Angeles';
SET SQL_SAFE_UPDATES = 1;

/*(b) explaination: First we disabled SQL_SAFE_UPDATES to allow the DELETE operation. We then removed items linked to suppliers in LA to resovle referential issues. We then deleted the suppliers from jbsupplier and finally re-enabeĺed SQL_SAFE_UPDATES.*/ 

/* Task 20 : Drop and redefine jbsale_supply to include suppliers that have delivered items that have not been sold.*/

DROP VIEW IF EXISTS jbsale_supply;
CREATE VIEW jbsale_supply (supplier, item, quantity) AS
SELECT 
    jbsupplier.name AS supplier, 
    jbitem.name AS item, 
    COALESCE(jbsale.quantity, 0) AS quantity
FROM 
    jbsupplier
JOIN 
    jbitem ON jbsupplier.id = jbitem.supplier
LEFT JOIN 
    jbsale ON jbitem.id = jbsale.item;

SELECT supplier, SUM(quantity) AS sum
FROM 
    jbsale_supply
GROUP BY 
    supplier;






