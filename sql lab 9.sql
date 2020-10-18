--------------------------------------------------------------------------
-- Instructions
-- We will be trying to predict if a customer will be renting a film this month based on their previous activity and other details. We will first construct a table with:
--    Customer ID
--    City
--    Most rented film category
--    Total films rented
--    Total money spent
--    How many films rented last month
-- and try to predict if he will be renting this month. 
-- Use date range (15/05/2005 - 30/05/2005) for last month and (15/06/2005 - 30/06/2005) for this month.

-- =====================================================
-- Megaquery
-- First we get the information about the customer 
select r.customer_id, c.first_name, c.last_name, a.address, ci.city from customer as c
join rental as r ON r.customer_id = c.customer_id 
join address as a ON a.address_id = c.address_id
join city as ci ON ci.city_id = a.city_id
group by r.customer_id
order by c.customer_id;

-- total films rented per customer
select r.customer_id, count(r.rental_id)
from rental as r
group by r.customer_id
order by r.customer_id;
-- the two previous queries together provides the customer info with the amount of movies rented.
select r.customer_id, c.first_name, c.last_name, a.address, ci.city, count(r.rental_id)  from customer as c
join rental as r ON r.customer_id = c.customer_id 
join address as a ON a.address_id = c.address_id
join city as ci ON ci.city_id = a.city_id
group by r.customer_id
order by c.customer_id;
-- money per customer
select r.customer_id, sum(p.amount) from rental as r
join payment as p on p.rental_id=r.rental_id
group by customer_id;
-- add money per customer to bigger query
drop table customer_data;
create table customer_data
select r.customer_id, c.first_name, c.last_name, a.address, ci.city, count(r.rental_id) as rentals, sum(p.amount) as amount_spent from customer as c
join rental as r ON r.customer_id = c.customer_id 
join address as a ON a.address_id = c.address_id
join city as ci ON ci.city_id = a.city_id
join payment as p on p.rental_id=r.rental_id
group by r.customer_id
order by c.customer_id;
select * from customer_data;
select c_d.customer_id, c_d.first_name, c_d.last_name,c_d.address,c_d.city, c_d.rentals, c_d. amount_spent,c_c.category_name from customer_data as c_d
join cust_cat as c_c on c_c.customer_num = c_d.customer_id;
-- DATES
-- lets show the data first for all the movies the customer rented in the last month
drop table previous_m;
create table previous_m
select customer_id, count(rental_id) as num_rental_train from rental
where (rental_date between "2005-05-15 00:00:00" and "2005-05-30 23:59:59")
group by customer_id
order by customer_id;

-- current month
drop table current_m;
create table current_m
select customer_id, count(rental_id) as num_rental_test from rental
where (rental_date between "2005-06-15 00:00:00" and "2005-06-30 23:59:59")
group by customer_id
order by customer_id;
select * from current_m;

select c_d.customer_id, c_d.first_name, c_d.last_name,c_d.address,c_d.city, c_d.rentals, c_d. amount_spent,c_c.category_name, p_m.num_rental_train AS movies_previous, c_m.num_rental_test as movies_current from customer_data as c_d
join cust_cat as c_c on c_c.customer_num = c_d.customer_id
join previous_m as p_m on p_m.customer_id = c_d.customer_id
join current_m as c_m on c_m.customer_id = c_d.customer_id;

-- table with customer id and cat name
DROP TABLE cust_cat;
-- CREATE TABLE cust_cat
SELECT customer_num, category_name FROM
(select c.customer_id as customer_num, cat.name AS category_name, count(r.rental_id) as 'number_of_rentals', row_number() over(partition by c.customer_id order by count(r.rental_id) desc) AS cat_rank from customer as c
join rental as r ON r.customer_id = c.customer_id 
join inventory as i on i.inventory_id = r.inventory_id
join film as f on f.film_id = i.film_id
join film_category as f_c on f_c.film_id = i.film_id
join category as cat on cat.category_id = f_c.category_id
group by r.customer_id,category_name
-- having number_of_rentals = max_movie 
order by customer_num, number_of_rentals DESC) AS list
WHERE cat_rank = 1;

select * from cust_cat;

SELECT customer_num, category_name FROM
(select c.customer_id as customer_num, cat.name AS category_name, count(r.rental_id) as 'number_of_rentals', row_number() over(partition by c.customer_id order by count(r.rental_id) desc) AS cat_rank from customer as c
join rental as r ON r.customer_id = c.customer_id 
join inventory as i on i.inventory_id = r.inventory_id
join film as f on f.film_id = i.film_id
join film_category as f_c on f_c.film_id = i.film_id
join category as cat on cat.category_id = f_c.category_id
group by r.customer_id,category_name
-- having number_of_rentals = max_movie 
order by customer_num, number_of_rentals DESC) AS list,
num_rental_train from (
select customer_id, count(rental_id) as num_rental_train from rental
where (rental_date between "2005-05-15 00:00:00" and "2005-05-30 23:59:59")
group by customer_id
order by customer_id) as n_rental_t
WHERE cat_rank = 1;

select customer_id, count(rental_id) as num_rental_train from rental
where (rental_date between "2005-05-15 00:00:00" and "2005-05-30 23:59:59")
group by customer_id
order by customer_id;

-- Anna Mariia
SELECT customer, category_name FROM
(SELECT rental.customer_id as customer, count(rental.rental_id) as total_rentals, film_category.category_id, category.name as category_name,
row_number() over (partition by rental.customer_id order by count(rental.rental_id) desc) as ranking_max_rented_category
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film_category ON inventory.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY rental.customer_id, film_category.category_id, category.name) AS table_popular_category
WHERE ranking_max_rented_category = 1
ORDER BY customer;



select * from category;
select * from test
where number_of_rentals = max_movie;

select * 
from test;
-- group by customer_id;
-----------------------------------------------
select r.customer_id, cat.name, count(r.rental_id) as 'number_of_rentals' from rental as r
join inventory as inv ON inv.inventory_id = r.inventory_id
join film as f ON f.film_id = inv.film_id
join film_category as f_c ON f_c.film_id = f.film_id
join category as cat ON cat.category_id = f_c.category_id
group by r.customer_id, cat.name
-- having 'number_of_rentals' = 
order by r.customer_id, number_of_rentals DESC;

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------


-- FIRST_VALUE(r.name) OVER (ORDER BY count(r.rental_id))
select r.customer_id, c.first_name, c.last_name, cat.name, count(r.rental_id) as 'number_of_rentals' from customer as c
join rental as r ON r.customer_id = c.customer_id 
join inventory as inv ON inv.inventory_id = r.inventory_id
join film as f ON f.film_id = inv.film_id
join film_category as f_c ON f_c.film_id = f.film_id
join category as cat ON cat.category_id = f_c.category_id
group by c.customer_id, cat.name
order by c.customer_id, number_of_rentals DESC;



select * from rental;

select customer_id, count(*)
from rental
group by customer_id;

select cat.name, count(f.film_id) as 'number_of_films_per_category' from film as f
join inventory as i ON i.film_id = f.film_id
join rental as r ON r.inventory_id = i.inventory_id
join customer as c on c.customer_id = r.customer_id
join film_category as f_c ON f_c.film_id = f.film_id
join category as cat ON cat.category_id = f_c.category_id
group by cat.name;

