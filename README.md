# Music_Store_Analysis-Sql_Project

## Project Overview

This project aims to analyze the music store's business performance to identify key factors affecting sales. By examining sales data, customer feedback, market trends, and inventory dynamics, we seek to uncover opportunities for improvement. The insights gained will inform targeted strategies to enhance revenue and better serve our customers.

## Research Question

1. Which year has the highest and the lowest sales and how many total invoices and customers are there in those year?

2. Which country has the highest and the lowest sales and how many customers are there?

3. What are the top 3 cities in each country based on sales?

4. Which top 3 cities have the highest and the lowest sales overall?

5. What are the top 3 most popular genres in each country based on sales?

6. What are the top 3 most popular and least popular genres overall based on invoices?

7. Who are the top customers from each country?

8. Who are the top artists from each country based on total invoice?

9. What are the top 3 tracks of each artist based on total invoice?

## Data Sources

Music Store Data: The primary dataset used for this analysis is the [Music_Store.csv](https://shorturl.at/sEIUV ) file, containing detailed information about music store sales.

## Schema Diagram

![eer](https://github.com/user-attachments/assets/97c50af2-aee5-4d69-aded-f31afd5efe3d)


## Tools

Mysql
- Joins
- Subquery 
- CTE and Recursive CTE
- Window Functions

## Data Analysis

Include some inetresting code/feature worked with

```
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
```

```
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
```

## Suggestions

1. Rock and metal genres are more popular and generate higher sales than other music types. To capitalize on this opportunity, the client should focus on targeted promotions and collaborations with popular bands for exclusive releases. These strategies can effectively boost sales and strengthen the brand's presence in the market.

2. Denmark currently has the lowest customer base, resulting in minimal sales and invoices. To enhance sales performance, the client should consider organizing music events to showcase a diverse range of genres. These events can effectively attract new audiences, increase brand visibility, and create valuable opportunities for revenue growth.

3. The top three cities with the lowest sales are Edmonton (Canada), Copenhagen (Denmark), and Buenos Aires (Argentina). To boost revenue in these markets, the client can offer discounts and promote top artists
like AC/DC and Aerosmith through events and targeted advertisements. This approach can attract more customers, increase engagement, and ultimately drive higher sales in these cities.

## About me

### Hi, I'm Ashish!

An aspiring data analyst....

