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

