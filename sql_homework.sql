use sakila;

/*1a*/
select first_name, last_name from actor;

/* 1b. Display the first and last name of each actor in a single column 
in upper case letters. Name the column Actor Name. */
select concat(first_name, ' ', last_name) as Actor_name from actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the 
first name, "Joe." What is one query would you use to obtain this information?*/
select actor_id, first_name, last_name from actor where first_name = "Joe";

/* 2b. Find all actors whose last name contain the letters GEN */
select * from actor where last_name like ('%GEN%');

/* 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order */
select last_name, first_name, actor_id from actor
where last_name like('%LI%')
order by last_name, first_name;

/* 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China */
select country_id, country from country
where country in('Afghanistan', 'Bangladesh','China');

/* 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
Hint: you will need to specify the data type */
alter table actor add middle_name varchar(50) after first_name;

/*3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs */
ALTER TABLE actor MODIFY middle_name BLOB;

/*3c. Now delete the middle_name column */
ALTER TABLE actor DROP middle_name;

/* 4a. List the last names of actors, as well as how many actors have that last name. */
select last_name, count(*) as count
from actor_info
group by last_name;

/*4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors */
select last_name, count(*) as count
from actor_info
group by last_name
having count > 1;

/* 4c. Oh, no! The actor Harpo WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.*/
UPDATE actor SET first_name = 'HARPO'
where actor_id = 172;

/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)*/
UPDATE actor 
	SET first_name = case when first_name = 'HARPO' then 'GROUCHO'
    ELSE 'MUCHO GROUCHO'
    END
    where actor_id = 172;
    
/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it? */
describe address;


/*5a - Use create table statement 

 
CREATE TABLE address (
  `address_id` smallint(5) NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  'address2' varchar(50) DEFAULT NULL,
  'district' varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
 `postal_code` varchar(10) DEFAULT NULL,
 `phone` varchar(20) NOT NULL,
 `location` geometry NOT NULL,
 `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`)
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8'
*/

/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address */
select first_name, last_name, address
from staff a
inner join address b
on a.address_id = b.address_id;

/* 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. */

select a.staff_id, first_name, last_name, sum(amount) as total_amount
	from staff a
    inner join payment b
    on a.staff_id = b.staff_id
    where
    cast(payment_date as date) between '2005-08-01' and '2005-08-31'
    group by 1,2,3;

/*6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/

select * from film_actor;

select b.title as film_title, count(a.actor_id) as number_of_actors
	from film_actor a
    inner join film b
    on a.film_id = b.film_id
    group by 1
    order by 1;


/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/

select count(a.film_id)  as Hunchback_Impossible_Count
from inventory a
where a.film_id IN
(
select film_id from film
where title LIKE "Hunchback Impossible"
);

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name: */

select * from payment;
select * from customer;

select a.last_name, a.first_name, sum(b.amount) as tot_amt
from customer a 
inner join payment b
on a.customer_id = b.customer_id
group by a.last_name, a.first_name
order by a.last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies
starting with the letters K and Q whose language is English. */

select * from film a where a.title LIKE "K%" or a.title LIKE "Q%" and a.language_id in 
(select language_id from language where language.name LIKE "English");

/* 7b. Use subqueries to display all actors who appear in the film Alone Trip. */

select * from film;
select * from film_actor;
select * from actor;

select a.first_name, a.last_name
from actor a
where a.actor_id IN
(select b.actor_id from film_actor b 
	where b.film_id IN
(select film_id from film where title LIKE  "Alone Trip"));

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/
select * from country;
select * from customer;
select * from address;
select * from city;

select a.first_name, a.last_name, a.email
from customer a
join address b
on a.address_id = b.address_id
join city c
on b.city_id = c.city_id
join country d
on c.country_id = d.country_id
where d.country = "Canada";

/*7d. Sales have been lagging among young families, and you wish to target all family 
movies for a promotion. Identify all movies categorized as famiy films.*/

select * from film; 
select * from film_category; 
select * from category;

select a.title, a.description from film a
join film_category b
on a.film_id = b.film_id
join category c
on b.category_id = c.category_id
where c.name = "Family";

/* 7e. Display the most frequently rented movies in descending order. */

select * from rental; -- rental_id and inventory_id
select * from inventory; -- inventory_id and film_id
select * from film; -- film_id and title, description


select a.title, count(a.title) as film_count
from film a
	,inventory b
	, rental c
where a.film_id = b.film_id 
and b.inventory_id = c.inventory_id
group by 1
order by film_count desc;

/* 7f. Write a query to display how much business, in dollars, each store brought in. */

select * from store;
select * from inventory;
select * from rental;
select * from payment;

select a.store_id, sum(b.amount) as total_revenue 
from store a
	,payment b
	,staff c
where a.store_id = c.store_id 
and c.staff_id = b.staff_id
group by 1;

-- 7g. Write a query to display for each store its store ID, city, and country.

select * from store; 
select * from address; 
select * from city;
select * from country;

select a.store_id
	,c.city
    ,d.country 
from store a
	,address b
    ,city c
    ,country d
where 
a.address_id = b.address_id
and b.city_id = c.city_id 
and c.country_id = d.country_id;

/*7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */

select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;

select e.name, sum(a.amount) as gross_revenue
from payment a
	, rental b
    , inventory c
    , film_category d
    , category e
where a.rental_id = b.rental_id 
and b.inventory_id = c.inventory_id 
and c.film_id = d.film_id 
and d.category_id = e.category_id
group by 1 order by gross_revenue desc limit 5;

/*8a. In your new role as an executive, you would like to have an easy 
way of viewing the Top five genres by gross revenue. Use the solution 
from the problem above to create a view. If you haven't solved 7h, 
you can substitute another query to create a view.*/

/*DROP VIEW top_gross_revenue_genres;*/

create view  top_gross_revenue_genres as
(select e.name, sum(a.amount) as gross_revenue
from payment a
	, rental b
    , inventory c
    , film_category d
    , category e
where a.rental_id = b.rental_id 
and b.inventory_id = c.inventory_id 
and c.film_id = d.film_id 
and d.category_id = e.category_id
group by 1);

/*8b. How would you display the view that you created in 8a, Display the view*/

select * from top_gross_revenue_genres order by gross_revenue desc limit 5;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it. */

DROP VIEW top_gross_revenue_genres;


