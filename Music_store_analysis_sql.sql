Create database Music_store;

use Music_store;

show tables;

-- Q1: Which year has the highest and the lowest sales  and how many total invoices and customers are there in those year?

select year(invoice_date) as year,count(i.invoice_id) as total_invoices,round(sum(il.unit_price * il.quantity),2) as Total_sales,count(distinct c.customer_id) as number_of_customers
from customer as c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
group by 1
order by Total_sales desc
limit 1;

-- Year 2019 has the highest sales, invoices and the number of customers are 54.

select year(invoice_date) as year,count(i.invoice_id) as total_invoices,round(sum(il.unit_price * il.quantity),2) as Total_sales,count(distinct c.customer_id) as number_of_customers  
from customer as c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
group by 1
order by Total_sales asc
limit 1;

-- Year 2020 has the lowest sales, invoices and number of customers are 58.


-- Q2: Which country has the highest and the lowest sales and how many customers are there ?

select c.country,count(i.invoice_id) as total_invoices,round(sum(il.unit_price * il.quantity),2) as total_sales,count(distinct c.customer_id) as number_of_customers  
from customer as c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
group by 1
order by 3 desc
limit 1;

-- Usa has the highest sales, invoices and the number of customers are 13.

select c.country,count(i.invoice_id) as total_invoices,round(sum(il.unit_price * il.quantity),2) as total_sales,count(distinct c.customer_id) as number_of_customers  
from customer as c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
group by 1
order by 3 asc
limit 1;

-- Denmark has the lowest sales and invoices and number of customer is 1.


-- Q3: What are the top 3 cities in each country based on sales ?

with top_3_cities as 
(
    select c.country,c.city,round(sum(il.unit_price * il.quantity),2) as total_sales,
	row_number() over(partition by c.country order by sum(il.quantity*il.unit_price) desc) as row_num from customer as c
	join invoice i on c.customer_id=i.customer_id
	join invoice_line il on i.invoice_id=il.invoice_id
	group by 1,2
) 
select * from top_3_cities
where row_num <=3
order by 1 asc,3 desc;


-- Q4: Which top 3 cities have the highest and the lowest sales overall ?

select i.billing_country,i.billing_city,round(sum(il.unit_price * il.quantity),2) as total_sales 
from invoice as i
join invoice_line il on i.invoice_id=il.invoice_id
group by 1,2
order by 3 desc
limit 3;

-- Top 3 cities with the highest sales are Prague(Czech Republic), Mountain View(USA) and London(United Kingdom)

select i.billing_country,i.billing_city,round(sum(il.unit_price * il.quantity),2) as total_sales 
from invoice as i
join invoice_line il on i.invoice_id=il.invoice_id
group by 1,2
order by 3 asc
limit 3;

-- Top 3 cities with the lowest sales are Edmonton(Canada), Copenhagen(Denmark) and Buenos Aires(Argentina)


-- Q5: What are the top 3 most popular genre in each country based on sales ?

with top_3_genre as
(
    select c.country,g.name,round(sum(il.unit_price * il.quantity),2) as total_sales,
	row_number() over(partition by c.country order by sum(il.quantity*il.unit_price) desc) as row_num from customer as c
	join invoice i on c.customer_id=i.customer_id
	join invoice_line il on i.invoice_id=il.invoice_id
	join track t on t.track_id=il.track_id
	join genre g on g.genre_id = t.genre_id 
	group by 1,2
)
select country,name,Total_sales,Row_num from top_3_genre
where row_num <=3
group by 1,2
order by 1 asc,3 desc;

-- Top 3 genre in most of the country are ROCK, METAL AND BLUES 


-- Q6: What are the top 3 most popular and least popular genre overall based on invoices ?

select g.name,count(i.invoice_id) as Total_invoices 
from customer as c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id = t.genre_id 
group by 1
order by 2 desc
limit 3;

-- ROCK, METAL AND BLUES have the highest number of invoices

select g.name,count(i.invoice_id) as Total_invoices 
from customer as c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id = t.genre_id 
group by 1
order by 2 asc
limit 3;

-- Reggae, Alternative & Punk AND Latin have the lowest number of invoices


-- Q7: Who are the top customers from each country ?

with top_customer as 
(
	Select c.country,c.customer_id,c.first_name,c.last_name,round(sum(il.unit_price*il.quantity),2) as purchase,
	dense_rank() over(partition by c.country order by sum(il.unit_price*il.quantity) desc) as dr from customer c
	join invoice i on c.customer_id=i.customer_id
	join invoice_line il on i.invoice_id=il.invoice_id
	group by 1,2,3,4
	order by 1 asc,5 desc
)
Select * from top_customer
where dr<=1 ;

-- Alternative to find top customer with recursive cte

with recursive 
	all_customers as(
		Select c.country,c.customer_id,c.first_name,c.last_name,round(sum(il.unit_price*il.quantity),2) as purchase from customer as c
		join invoice i on c.customer_id=i.customer_id
		join invoice_line il on i.invoice_id=il.invoice_id
		group by 1,2,3,4
		order by 1 asc,5 desc
	),

top_customer as (select country,max(purchase) as purchase 
from all_customers 
group by 1
order by 1 asc,2 desc)

select ac.* from all_customers as ac,
top_customer as tc
where ac.country=tc.country and ac.purchase=tc.purchase;


-- Q8: Who are the top artists from each country based on total invoice ?

with top_artist as 
(
	Select c.country,ar.artist_id,ar.name,count(i.invoice_id) as total_invoice,
	dense_rank() over(partition by c.country order by sum(il.unit_price*il.quantity) desc) as dr from customer c
	join invoice i on c.customer_id=i.customer_id
	join invoice_line il on i.invoice_id=il.invoice_id
	join track t on t.track_id=il.track_id
	join album al on al.album_id=t.album_id
	join artist ar on al.artist_id=ar.artist_id
	group by 1,2,3
	order by 1 asc,4 desc
)
Select * from top_artist
where dr<=1
order by 4 desc ;

-- Alternative to find top artists with recursive cte

with recursive 
	all_artists as(
		Select c.country,ar.artist_id,ar.name,count(i.invoice_id) as total_invoice from customer as c
		join invoice i on c.customer_id=i.customer_id
		join invoice_line il on i.invoice_id=il.invoice_id
		join track t on t.track_id=il.track_id
		join album al on al.album_id=t.album_id
		join artist ar on al.artist_id=ar.artist_id
		group by 1,2,3
		order by 1 asc,4 desc
	),

top_artist as (select country,max(total_invoice) as total_invoice 
from all_artists
group by 1)

select aa.* from all_artists as aa,
top_artist as ta
where ta.country=aa.country and ta.total_invoice=aa.total_invoice
order by 4 desc ;


-- Q9: What are the top 3 tracks of each artist based on total invoice  ?

with top_tracks as 
(
	Select  ar.artist_id,ar.name,t.track_id,t.track_name,count(il.invoice_id) as total_invoice,
    row_number() over(partition by ar.artist_id order by sum(il.unit_price*il.quantity) desc) as rn from invoice_line as il
	join track t on t.track_id=il.track_id
	join album al on al.album_id=t.album_id
	join artist ar on al.artist_id=ar.artist_id
	group by 1,2,3,4
	order by 1 asc,5 desc
)
Select * from top_tracks
where rn<=3 ;

Select * from track;
alter table track
change  name track_name varchar(100); -- had to change the name of coulumn in track table due to getting duplicate column name error