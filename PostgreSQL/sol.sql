--Create a list of all the different (distinct) replacement costs of the films.

select distinct replacement_cost from film
order by replacement_cost;

/* Write a query that gives an overview of how many films have replacements costs 
in the following cost ranges
    low: 9.99 - 19.99

    medium: 20.00 - 24.99

    high: 25.00 - 29.99 */
	
select count(*),
case 
when replacement_cost between 9.99 and 19.99
then 'low_cost'
when replacement_cost between 19.99 and 24.99 then 'meddium'
when replacement_cost between 24.99 and 29.99 then 'high'
end cost
from film
group by cost;

/*Create a list of the film titles including their title,
 length and category name ordered descendingly by the length.
  Filter the results to only the movies 
in the category 'Drama' or 'Sports'.*/

select title,length,name
from film f inner join film_category fc
on f.film_id=fc.film_id
inner join category c on fc.category_id=c.category_id
where name in('Drama','Sports')
order by length desc;

/*Create an overview of how many movies (titles) 
there are in each category (name). */

select name,count(*)
from film f inner join film_category fc
on f.film_id=fc.film_id
inner join category c on fc.category_id=c.category_id
group by name 
order by 2 desc;

/*Create an overview of the actors first and last names and 
in  how many movies they appear.*/

select first_name,last_name,count(*)
from film_actor fa inner join actor a
on fa.actor_id= a.actor_id
group by first_name,last_name
order by count(*) desc;

/*Create an overview of the addresses that are not 
associated to any customer.*/

select * from customer c right join address a 
on c.address_id=a.address_id
where customer_id is null;

/*Create an overview of the cities and how much sales 
(sum of amount) have occured there.*/

select sum(amount),city from payment p  join customer c on 
p.customer_id=c.customer_id join address a 
on a.address_id=c.address_id join city ci on
a.city_id=ci.city_id 
group by city
order by 1 desc;

/* Create an overview of the revenue (sum of amount) grouped by
a column in the format "country, city".*/

select sum(amount),country||','||city
from payment p  join customer c on 
p.customer_id=c.customer_id join address a 
on a.address_id=c.address_id join city ci on
a.city_id=ci.city_id join country co
on ci.country_id=co.country_id
group by city,country
order by 1 ;

/*Create a list with the average of the sales amount
each staff_id has per customer.*/

select staff_id,round(avg(sum),2)
from (select staff_id,sum(amount) as sum
from payment
 group by customer_id,staff_id) sub
 group by staff_id;
 
/*Create a query that shows average daily 
revenue of all Sundays.*/

select avg(sum)
from (select sum(amount) sum from payment
		where extract(dow from payment_date)=0
	 group by date(payment_date),
	  extract(dow from payment_date)) sub;
	  
/*Create a list of movies - with their length and their 
replacement cost - that are longer than the average length 
in each replacement cost group.*/

select title,length,f1.replacement_cost
from film f1
where length>(select avg(length)
			 from film f2
			 where f1.replacement_cost=f2.replacement_cost)
order by length;

/*Create a list that shows how much the average customer 
spent in total (customer life-time value) grouped by the 
different districts.*/

select round(avg(sum),2),district from 
(select customer_id,sum(amount) sum
							   from payment
							   group by customer_id) b
join customer c on c.customer_id=b.customer_id
join address a on a.address_id=c.address_id
group by district
order by 1 desc;

/*  Create a list that shows all payments including the payment_id, 
amount and the film category (name) plus the total amount 
that was made in this category. Order the results ascendingly
by the category (name) and as second order criterion by the
payment_id ascendingly*/

select amount,name,payment_id,
(select sum(amount)from payment p 
join rental r on r.rental_id=p.rental_id
join inventory i on i.inventory_id=r.inventory_id
join film_category fc on fc.film_id=i.film_id
join category c on c.category_id=fc.category_id
where c1.name=c.name)
from payment p 
join rental r on r.rental_id=p.rental_id
join inventory i on i.inventory_id=r.inventory_id
join film_category fc on fc.film_id=i.film_id
join category c1 on c1.category_id=fc.category_id
order by name,payment_id;

/* Create a list with the top overall revenue of
a film title (sum of amount per title) for each 
category (name).*/

select title,name,sum(amount) from payment p 
join rental r on r.rental_id=p.rental_id
join inventory i on i.inventory_id=r.inventory_id
join film f on f.film_id=i.film_id
join film_category fc on fc.film_id=i.film_id
join category c1 on c1.category_id=fc.category_id
group by name,title
having
sum(amount)=(select max(am)from
			 (select sum(amount) am from payment p 
join rental r on r.rental_id=p.rental_id
join inventory i on i.inventory_id=r.inventory_id
join film f on f.film_id=i.film_id
join film_category fc on fc.film_id=i.film_id
join category c on c.category_id=fc.category_id
where c.name=c1.name
group by name,title )sub)
