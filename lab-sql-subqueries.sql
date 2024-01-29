-- Challenge
-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
-- Bringing the film_id of the requested movie
SELECT film_id FROM film WHERE title = 'Hunchback Impossible';

SELECT film_id, COUNT(inventory_id) FROM inventory
GROUP BY film_id;

SELECT COUNT(inventory_id) AS nb_of_copies FROM inventory
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT * FROM film;

SELECT title FROM film 
WHERE length > (SELECT AVG(length) FROM film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT 
    CONCAT(first_name, ' ', last_name) AS actor_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'))
ORDER BY actor_name;

-- Bonus:
-- 4.Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT 
    title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_category
        WHERE
            category_id IN (SELECT 
                    category_id
                FROM
                    category
                WHERE
                    name = 'Family'));

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT 
    city_id
FROM
    city ct
        JOIN
    country co USING (country_id)
WHERE
    co.country = 'Canada';

SELECT 
    CONCAT(first_name, ' ', last_name) AS name, email
FROM
    customer
WHERE
    address_id IN (SELECT 
            address_id
        FROM
            address
        WHERE
            city_id IN (SELECT 
                    city_id
                FROM
                    city ct
                        JOIN
                    country co USING (country_id)
                WHERE
                    co.country = 'Canada'));

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id 
-- to find the different films that he or she starred in.

SELECT f.title as title FROM film f
JOIN film_actor fa USING (film_id)
WHERE fa.actor_id = 
(SELECT actor_id FROM actor a
JOIN film_actor fa USING (actor_id)
GROUP BY a.actor_id , a.first_name , a.last_name
HAVING COUNT(fa.film_id) = (SELECT 
        MAX(actor_film_count)
    FROM
        (SELECT 
            COUNT(fa.film_id) AS actor_film_count
        FROM
            actor a
        JOIN film_actor fa USING (actor_id)
        GROUP BY a.actor_id) AS sub1))
GROUP BY film_id;

-- 7. Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, 
-- i.e., the customer who has made the largest sum of payments.
 
 SELECT 
    f.title
FROM
    film f
        JOIN
    inventory i USING (film_id)
        JOIN
    rental r USING (inventory_id)
WHERE
    r.customer_id = (SELECT 
            customer_id
        FROM
            payment p
        WHERE
            customer_id IN (SELECT 
                    customer_id
                FROM
                    (SELECT 
                        customer_id, SUM(amount) AS total_payed
                    FROM
                        payment
                    GROUP BY customer_id
                    ORDER BY total_payed DESC
                    LIMIT 1) sub1)
        GROUP BY customer_id);

-- 8. Retrieve the client_id and the total_amount_spent of those clients 
-- who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.

SELECT customer_id, SUM(amount) AS total_amount_spent from payment
GROUP BY customer_id
HAVING total_amount_spent >
(SELECT AVG(total_amount_spent) FROM 
(SELECT SUM(amount) AS total_amount_spent from payment
GROUP BY customer_id)sub1)
ORDER BY total_amount_spent ASC;


SELECT AVG(total_amount_spent) FROM 
(SELECT SUM(amount) AS total_amount_spent from payment
GROUP BY customer_id)sub1;





