/*Music store data analysis project (help the store to understand its business growth by answer in simple questions)*/

--Q1: Who is the senior most employee based on job title?

select * from employee

order by levels desc
limit 1

--Q2: Which countries have most invoices?

select * from invoice
select COUNT(*) as c,billing_country
from invoice
group by billing_country
order by c desc

--Q:3 What are the top 3 values of total invoice?

select * from invoice

select total from invoice
order by total desc
limit 3

/*Q4: Which city has the best customers ? We would like to throw a promotional music festival
   in the city we made the most money.Write a query that return one city that has the highest 
   sum of invoice totals.*/
   
 select * from invoice
 
 select SUM(total) as invoice_total,billing_city
 from invoice
 group by billing_city
 order by invoice_total desc
 
 /*Q5: Who is the best cusotmer? The customer who has spent the most money will be declared
    the best customer . Write the query that returns the person who has spent the most
	money.*/
	
select * from customer	

select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
limit 1

 /*Q6: Write query to return the email,first name, last name, & genre of all rock music listeners.
     Return your list order alphabatically by email starting with A.*/
	 
select * from customer

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
    SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)

/*Q7:let invite the artist who have written the most rock music in our dataset.
write a query that returns the artist name and total track count of the top 10 
rock bands.*/

select artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10
 /*Q8: return all the tracks names that have a song length longer than the average
   song length. Return the name and milliseconds for each track . Order by the song 
   with the longest songs listed first*/

select name,milliseconds from track
where milliseconds>(
select avg (milliseconds)as avg_track_length
from track)
order by milliseconds desc;

 
 /*Q9: find how much amount spent by each cusotmer on artist.write a query to return 
   customer name, artist name and total spent.*/
--we can use CTE(common table expression ) help to create temporary table for perform different operations
WITH best_selling_artist as (
	select artist.artist_id as artist_id,artist.name as artist_name,
    sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
    from invoice_line
    join track on track.track_id = invoice_line.track_id
    join album on album.album_id = track.album_id
    join artist on artist.artist_id = album.artist_id
    group by 1
    order by 3 desc  
	limit 1
)

select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


/*Q10: Write a query that determine the customer that has spent the most
on music for each country . write a query that returns the country along
with the top customer and how much they spent .for countries where the top 
amount spent is shared, provide all customers who spent this amount*/

WITH Customer_with_country as (
          select customer.customer_id,first_name,last_name,billing_country,sum(total)as total_spending,
	      row_number() over (partition by billing_country order by sum (total)desc) as RowNo
	      from invoice
	      join customer on customer.customer_id = invoice.customer_id
	      group by 1,2,3,4
	      order by 4 asc,5 desc)
select * from Customer_with_country where RowNo <= 1;