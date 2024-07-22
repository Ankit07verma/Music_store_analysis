SELECT * FROM employee
SELECT * FROM invoice	
SELECT * FROM invoice_line
SELECT * FROM Customer
SELECT * FROM genre
SELECT * FROM Track
SELECT * FROM Invoice_line
SELECT * FROM Artist
	
--Q1. Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2. Which Countries have the most invoices?

SELECT COUNT(*) AS COUNT, Billing_country
FROM invoice
GROUP BY billing_country
ORDER by COUNT DESC;

--Q3. What are the top 3 values in total invoice?

SELECT *, total FROM invoice
ORDER BY total DESC
LIMIT 3;

--Q4. Which city has the best cutomers? we would like to throw a promotional Music festival in the city where we made the most money.
--write a query that returns one city that has the highest sum of invoices totals. Return both city name & sum of all invoice details.

SELECT sum(total) as SUM, billing_city
FROM invoice
	GROUP BY billing_city
ORDER BY SUM DESC
LIMIT 1;

--Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.Total) AS Total
FROM Customer
JOIN invoice ON
	 customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY Total DESC
LIMIT 1

--Q6. Write a query to return the email, first name, last name, genre, of all Rock music listeners. Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT first_name, last_name,email
FROM customer
JOIN Invoice ON
Invoice.invoice_id = customer.Customer_id
	JOIN Invoice_line ON
    Invoice_line.invoice_id = Invoice.invoice_id
	WHERE Track_id IN (SELECT track_id FROM Track
WHERE genre_id = '1')
ORDER BY email ASC;

--Q7. Let's invite the artists who have written the most rock music in our dataset. Write a query that return the artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS Number_of_songs 
FROM track
JOIN album on album.album_id = track.album_id
JOIN artist on artist.artist_id = album.artist_id
JOIN genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE 'ROCK'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--Q8. Return all the songs that have a song length longer then the average song length. Return the name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT Name, milliseconds
	FROM Track
	WHERE milliseconds>(
	SELECT cast(AVG(Milliseconds)as int) As Average_playback
FROM Track)
	ORDER BY Milliseconds DESC;

--Q9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

WITH Best_selling_artist as(
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN Track ON track.Track_id = invoice_line.track_id
	JOIN Album ON album.album_id = track.album_id
	JOIN Artist ON artist.artist_id = album.artist_id
    GROUP BY 1
	ORDER BY 3 DESC
    LIMIT 1
	)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
	FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id =i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa on bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Q10. We want to find out the most popular genre for each country. We determine the most popular genre as the genre with highest amount of purchases. Write a query that return each country along with the top genre. For the countries where the maximum number of purchases are shared return all genres.

WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY Customer.Country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
FROM Invoice_line
	JOIN Invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN Track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
	)
SELECT * FROM popular_genre WHERE RowNo <=1

--Q11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along witht the top customer and how much they spent. For countries where the top amount is shared, provide all customers who spent this amount 

WITH RECURSIVE
Customer_with_Country AS (
	SELECT customer.customer_id, first_name, Last_name, billing_country, SUM(total) AS total_spending
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 2,3 DESC),

	Country_max_spending AS(
	SELECT billing_country, MAX(Total_spending) AS max_spending
	FROM Customer_with_country
	GROUP BY billing_country)

	SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
	FROM customer_with_country cc 
	JOIN country_max_spending ms
	ON cc.billing_country = ms.billing_country
	where cc.total_spending = ms.max_spending
	ORDER BY 1;