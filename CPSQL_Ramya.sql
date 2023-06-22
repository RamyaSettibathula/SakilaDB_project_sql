use sakila;
show tables;
select * from actor;
-- Task 1 :- Display the fullnames of the actors available in the database.

SELECT CONCAT(first_name,'  ', last_name) as Actors_Full_names FROM actor;

-- Task 2i :- Display the number of times each first name appears in the database.

SELECT first_name, COUNT(first_name) AS First_name_count FROM actor GROUP BY first_name ORDER BY First_name_count DESC;

-- Task 2ii :- What is the count of actors that have unique first names in the database? Display the first names of all these actors.  

SELECT first_name AS unique_first_names, COUNT(first_name) AS name_count FROM actor GROUP BY first_name HAVING name_count = 1;

-- Task 3i :- Display the number of times each last name appears in the database. 

SELECT last_name, COUNT(last_name) AS Last_name_count FROM actor GROUP BY last_name ORDER BY last_name_count DESC;


-- Task 3ii :- Display all unique last names in the database.

SELECT last_name AS unique_last_names, COUNT(last_name) AS name_count FROM actor GROUP BY last_name HAVING name_count = 1;

-- Task 4i :- Display the list of records for the movies with the rating 'R'.

SELECT * FROM film WHERE rating = 'R';

-- Task 4ii :- Display the list of Records for the movies that are not rated 'R'

SELECT * FROM film WHERE rating != 'R';

-- Task 4iii :- Display the list of records for the movies that are suitable for audience below 13 years of age.

SELECT * FROM film WHERE rating = 'G';

-- Task 5i :- Display the list of records for the movies where the replacement cost is upto $11.

SELECT * FROM film WHERE replacement_cost < 11;

-- Task 5ii :- Display the list of records for the movies where the replacement cost is between $11 and $20.

SELECT * FROM film WHERE replacement_cost BETWEEN 11 AND  20;

-- Task 5iii :- Display the list of records for the all movies in descending order of their replacement costs.  

SELECT * FROM film ORDER BY replacement_cost DESC;

-- Task 6 :- Display the names of the top 3 movies with the greatest number of actors.

SELECT film.title, COUNT(film_actor.actor_id) AS actor_count
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id
ORDER BY actor_count DESC
LIMIT 3;

/* Task 7 :- 'Music of Queen' and 'Kris Kristofferson' have seen an unlikely resurgence. As 
an unintended consequence, films starting with the letters 'K' and 'Q' have also soared in
popularity. Display the movies starting with the letters 'K' and 'Q' */

SELECT title AS 'Movies start with K and Q'
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%'
ORDER BY title;

/* Task 8 :- The film 'Agent Truman' has been a great success. Display the names of all actors who
appered in this film */

SELECT actor.first_name, actor.last_name, film.title
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id 
JOIN actor on film_actor.actor_id = actor.actor_id
WHERE title = 'Agent Truman';

/* Task 9 :- Sales have been lagging among young families, so the management wants to promote 
family movies. Identify all the movies categorized as family films. */

SELECT film.title, category.name
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- another query using subquery

SELECT f.title FROM film as f WHERE f.film_id IN (
SELECT fc.film_id FROM film_category as fc WHERE fc.category_id = (
SELECT c.category_id FROM category as c WHERE c.name = 'Family'));

/*Task 10i :- Display the maximum, minimum and average rental rates of movies based on 
their ratings. The output must be sorted in descending order of the average rental rates. */

SELECT rating, MAX(rental_rate) AS max_rental_rate, MIN(rental_rate) AS min_rental_rate,
AVG(rental_rate) AS avg_rental_rate
FROM film
GROUP BY rating
ORDER BY avg_rental_rate DESC;

/* Task 10ii :- Display the movies in descending order of their rental frequencies, so the
management can maintain more copies of those movies */

SELECT film.title, COUNT(rental.rental_id) AS rental_frequency
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.film_id
ORDER BY rental_frequency DESC;

/* Task 11 :- In how many film categories, the difference between the average film replacement
cost and the average film rental rate is greater than $15?
Display the list of film categories identified above, along with the corresponding 
average film replacement cost and average film rental rate.*/

SELECT c.name AS Film_Categories FROM category AS c
JOIN film_category AS fc 
ON c.category_id = fc.category_id 
JOIN film AS f ON f.film_id = fc.film_id
GROUP BY c.name 
HAVING AVG(replacement_cost) - AVG(rental_rate) > 15;

SELECT category.name AS category_name, AVG(film.replacement_cost) AS avg_replacement_cost,
AVG(film.rental_rate) AS avg_rental_rate
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
HAVING (AVG(film.replacement_cost) - AVG(film.rental_rate)) > 15;

-- Task 12 :- Display the film categories in which the number of movies is greater than 70.

SELECT category.name as Category_name, count(film.title) as Number_Of_Movies 
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
HAVING Number_Of_Movies > 70 ;

-- another query using subquery

SELECT category.name FROM category WHERE category.category_id IN (
SELECT film_category.category_id FROM film_category GROUP BY film_category.category_id 
HAVING COUNT(film_category.film_id) > 70);

-- Extra Tasks;
-- In task 6 i got so many records with same count of actors so i create a view and in that i make dense rank 
create view Top_Movie as
select title, count(first_name) as Count_of_Actor, dense_rank() over(order by count(first_name) desc) as Rank_of_Movies
from film as f join film_actor as fa on f.film_id = fa.film_id 
join actor as a on a.actor_id = fa.actor_id group by title having Rank_of_Movies <= 3
order by count(first_name) desc ;

select * from Top_Movie where Rank_of_Movies <= 3;

-- finding genre of bucket brotherhood and rocketeer mother movies 

select film.title,category.name AS 'Genre',film.rating from film join film_category on
film.film_id = film_category.film_id join category
on film_category.category_id = category.category_id where film.title = 'BUCKET BROTHERHOOD' OR film.title ='ROCKETEER MOTHER';

-- counting the number of movies based on their category of replacement cost between 11 and 20.

select category.name,count(category.name) as 'count of movies' from film join film_category on film.film_id = film_category.film_id
 join category on film_category.category_id = category.category_id  where replacement_cost between 11 and 20 group by category.name
 order by count(category.name) desc;
 
 -- family category movies want to promote so in children category movies they promote then its easily reached to families so 
 -- i find children category movies.
 
 SELECT film.title,category.name from film join film_category on
film.film_id = film_category.film_id join category
on film_category.category_id = category.category_id 
where category.name = 'Children' ;
 
 
