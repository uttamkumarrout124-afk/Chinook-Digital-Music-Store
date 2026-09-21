-- 1.	Does any table have missing values or duplicates? If yes how would you handle it ?

-- Missing values in Customer

SELECT
COUNT(*) AS TotalCustomers,
SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS MissingCompany,
SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS MissingState,
SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) AS MissingPostalCode,
SUM(CASE WHEN fax IS NULL THEN 1 ELSE 0 END) AS MissingFax
FROM customer;

-- Missing values in Track

SELECT
COUNT(*) AS TotalTracks,
SUM(CASE WHEN composer IS NULL THEN 1 ELSE 0 END) AS MissingComposer
FROM track;

-- Duplicate customers

SELECT
first_name,
last_name,
email,
COUNT(*) AS DuplicateCount
FROM customer
GROUP BY
first_name,
last_name,
email
HAVING COUNT(*) > 1;

-- Duplicate Invoice IDs

SELECT
invoice_id,
COUNT(*) AS DuplicateCount
FROM invoice
GROUP BY invoice_id
HAVING COUNT(*) > 1;

-- 2.Find the top-selling tracks and top artist in the USA and identify their most famous genres.

SELECT
t.name AS TrackName,
ar.name AS Artist,
g.name AS Genre,
SUM(il.quantity) AS UnitsSold,
ROUND(SUM(il.quantity * il.unit_price),2) AS Revenue
FROM invoice i
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN album al
ON t.album_id = al.album_id
JOIN artist ar
ON al.artist_id = ar.artist_id
JOIN genre g
ON t.genre_id = g.genre_id
WHERE i.billing_country='USA'
GROUP BY
TrackName,
 Artist,
 Genre
ORDER BY Revenue DESC
limit 30;

-- 3. What is the customer demographic breakdown (age, gender, location) of Chinook's customer base?--

-- Country-wise Customers
SELECT
    country,
    COUNT(*) AS Customers
FROM customer
GROUP BY country
ORDER BY Customers DESC;
-- State-wise Customers
SELECT
    country,
    state,
    COUNT(*) AS Customers
FROM customer
GROUP BY country, state
ORDER BY Customers DESC;
-- City-wise Customers
SELECT
    country,
    city,
    COUNT(*) AS Customers
FROM customer
GROUP BY country, city
ORDER BY Customers DESC;

-- 4. Calculate the total revenue and number of invoices for each country, state, and city:--


SELECT
billing_country,
billing_state,
billing_city,
COUNT(invoice_id) AS TotalInvoices,
ROUND(SUM(total),2) AS TotalRevenue
FROM invoice
GROUP BY
billing_country,
billing_state,
billing_city
ORDER BY TotalRevenue DESC;

-- 5.Find the top 5 customers by total revenue in each country --

WITH CustomerRevenue AS
(
SELECT
c.country,c.customer_id,
CONCAT(c.first_name,' ',c.last_name) AS CustomerName,
SUM(i.total) AS TotalRevenue
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
GROUP BY
c.country,c.customer_id,c.first_name,c.last_name
)
SELECT
country,customer_id,CustomerName,TotalRevenue,CustomerRank
FROM
(
SELECT *,
DENSE_RANK() OVER
(
PARTITION BY country
ORDER BY TotalRevenue DESC
) AS CustomerRank
FROM CustomerRevenue
) x
WHERE CustomerRank <= 5
ORDER BY country, CustomerRank;

-- 6.	Identify the top-selling track for each customer--

WITH CustomerTrackSales AS
(
SELECT
c.customer_id,
CONCAT(c.first_name,' ',c.last_name) AS CustomerName,
t.track_id,
t.name AS TrackName,
SUM(il.quantity) AS TotalPurchased
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
GROUP BY
c.customer_id,c.first_name,c.last_name,t.track_id,t.name
)
SELECT
customer_id,CustomerName,TrackName,TotalPurchased
FROM
(
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY customer_id
ORDER BY TotalPurchased DESC, track_id
) AS RankNo
FROM CustomerTrackSales
) RankedTracks
WHERE RankNo = 1
ORDER BY customer_id;

-- 7.	Are there any patterns or trends in customer purchasing behavior 
-- (e.g., frequency of purchases, preferred payment methods, average order value)?

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS CustomerName,
    COUNT(DISTINCT i.invoice_id) AS TotalInvoices,
    ROUND(AVG(i.total),2) AS AverageOrderValue,
    SUM(il.quantity) AS TotalTracksPurchased,
    ROUND(SUM(il.quantity) / COUNT(DISTINCT i.invoice_id),2) AS AvgBasketSize
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY TotalInvoices DESC;

-- 8.	What is the customer churn rate?
WITH LatestInvoice AS (
    SELECT MAX(invoice_date) AS MaxInvoiceDate
    FROM invoice
),
CustomerLastPurchase AS (
    SELECT
        customer_id,
        MAX(invoice_date) AS LastPurchase
    FROM invoice
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS TotalCustomers,
    SUM(
        CASE
            WHEN LastPurchase < DATE_SUB((SELECT MaxInvoiceDate FROM LatestInvoice), INTERVAL 3 MONTH)
            THEN 1 ELSE 0
        END
    ) AS ChurnedCustomers,
    ROUND(
        SUM(
            CASE
                WHEN LastPurchase < DATE_SUB((SELECT MaxInvoiceDate FROM LatestInvoice), INTERVAL 3 MONTH)
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM CustomerLastPurchase;


-- 9.	Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.

WITH GenreSales AS (
    SELECT
        g.genre_id, g.name AS Genre, ar.name AS Artist,
        SUM(il.quantity * il.unit_price) AS Revenue
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    WHERE i.billing_country = 'USA'
    GROUP BY
        g.genre_id,g.name,ar.artist_id,ar.name
)

SELECT
    Genre,
    Artist,
    Revenue,
ROUND(Revenue * 100 /SUM(Revenue) OVER (),2) AS SalesPercentage
FROM GenreSales
ORDER BY Revenue DESC;

-- 10.	Find customers who have purchased tracks from at least 3 different genres

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS CustomerName,
    COUNT(DISTINCT g.genre_id) AS GenresPurchased
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN genre g
    ON t.genre_id = g.genre_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(DISTINCT g.genre_id) >= 3
ORDER BY GenresPurchased DESC;

-- 11.	Rank genres based on their sales performance in the USA

WITH GenreRevenue AS (
    SELECT
        g.genre_id,
        g.name AS Genre,
        SUM(il.quantity * il.unit_price) AS Revenue
    FROM invoice i
    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id
    JOIN track t
        ON il.track_id = t.track_id
    JOIN genre g
        ON t.genre_id = g.genre_id
    WHERE i.billing_country = 'USA'
    GROUP BY
        g.genre_id,
        g.name
)

SELECT
    Genre,
    Revenue,
    DENSE_RANK() OVER (ORDER BY Revenue DESC) AS GenreRank
FROM GenreRevenue
ORDER BY GenreRank;

-- 12.	Identify customers who have not made a purchase in the last 3 months

WITH LatestInvoice AS (
    SELECT MAX(invoice_date) AS MaxInvoiceDate
    FROM invoice
)

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS CustomerName,
    MAX(i.invoice_date) AS LastPurchaseDate
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING MAX(i.invoice_date) <
       DATE_SUB((SELECT MaxInvoiceDate FROM LatestInvoice), INTERVAL 3 MONTH)
ORDER BY LastPurchaseDate;

-- Subjective Questions --
-- 1. Recommend the three albums that should be prioritized for advertising in the USA based on genre sales anlysis.
SELECT
    al.album_id,
    al.title AS Album,
    ar.name AS Artist,
    ROUND(SUM(il.quantity * il.unit_price),2) AS Revenue
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY
    al.album_id,
    al.title,
    ar.name
ORDER BY Revenue DESC
LIMIT 3;

-- 2.	Determine the top-selling genres in countries other than the USA and identify any commonalities or differences.

WITH GenreSales AS (
    SELECT
        i.billing_country,
        g.name AS Genre,
        SUM(il.quantity * il.unit_price) AS Revenue
    FROM invoice i
    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id
    JOIN track t
        ON il.track_id = t.track_id
    JOIN genre g
        ON t.genre_id = g.genre_id
    WHERE i.billing_country <> 'USA'
    GROUP BY
        i.billing_country,
        g.name
)

SELECT
    billing_country,
    Genre,
    Revenue,
    DENSE_RANK() OVER (
        PARTITION BY billing_country
        ORDER BY Revenue DESC
    ) AS GenreRank
FROM GenreSales
ORDER BY billing_country, GenreRank;

-- 3.	Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ from those of new customers? 
-- What insights can these patterns provide about customer loyalty and retention strategies?

WITH CustomerSummary AS (
    SELECT
        c.customer_id,
        MIN(i.invoice_date) AS FirstPurchase,
        COUNT(DISTINCT i.invoice_id) AS PurchaseFrequency,
        SUM(i.total) AS TotalSpent,
        SUM(il.quantity) AS TracksPurchased
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id
)
SELECT
    customer_id,
    FirstPurchase,
    PurchaseFrequency,
    ROUND(TotalSpent,2) AS TotalSpent,
    TracksPurchased,
    ROUND(TracksPurchased / PurchaseFrequency,2) AS AvgBasketSize
FROM CustomerSummary
ORDER BY FirstPurchase;

-- 4.	Product Affinity Analysis: Which music genres, artists, or albums are frequently purchased together by customers?
-- How can this information guide product recommendations and cross-selling initiatives?

SELECT
    t1.name AS Track1,
    t2.name AS Track2,
    COUNT(*) AS PurchasedTogether
FROM invoice_line il1
JOIN invoice_line il2
    ON il1.invoice_id = il2.invoice_id
   AND il1.track_id < il2.track_id
JOIN track t1
    ON il1.track_id = t1.track_id
JOIN track t2
    ON il2.track_id = t2.track_id
GROUP BY
    t1.name,
    t2.name
ORDER BY PurchasedTogether DESC
LIMIT 20;

-- 5.	Regional Market Analysis: Do customer purchasing behaviors and churn rates vary across different geographic regions or store locations? 
-- How might these correlate with local demographic or economic factors?

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS Customers,
    COUNT(DISTINCT i.invoice_id) AS Invoices,
    ROUND(SUM(i.total),2) AS Revenue,
    ROUND(AVG(i.total),2) AS AvgInvoiceValue
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY Revenue DESC;

-- 6.	Customer Risk Profiling: Based on customer profiles (age, gender, location, purchase history), 
-- which customer segments are more likely to churn or pose a higher risk of reduced spending? What factors contribute to this risk?

WITH CustomerRisk AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name,' ',c.last_name) AS CustomerName,
        c.country,
        MAX(i.invoice_date) AS LastPurchase,
        SUM(i.total) AS TotalSpent
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country
)

SELECT
    CustomerName,
    Country,
    LastPurchase,
    ROUND(TotalSpent,2) AS TotalSpent
FROM CustomerRisk
ORDER BY LastPurchase ASC, TotalSpent ASC;

-- 7.Customer Lifetime Value Modeling: How can you leverage customer data (tenure, purchase history, engagement) to predict the lifetime value of different customer segments? 
-- This could inform targeted marketing and loyalty program strategies. 
-- Can you observe any common characteristics or purchase patterns among customers who have stopped purchasing?

WITH CustomerCLV AS
(
SELECT
c.customer_id,
CONCAT(c.first_name,' ',c.last_name) AS CustomerName,
MIN(i.invoice_date) AS FirstPurchase,
MAX(i.invoice_date) AS LastPurchase,
COUNT(i.invoice_id) AS TotalInvoices,
ROUND(SUM(i.total),2) AS TotalRevenue,
ROUND(AVG(i.total),2) AS AvgOrderValue
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
GROUP BY
c.customer_id,
c.first_name,
c.last_name
)
SELECT *,
CASE
WHEN TotalRevenue>=40 THEN 'High Value'
WHEN TotalRevenue>=20 THEN 'Medium Value'
ELSE 'Low Value'
END AS CustomerSegment
FROM CustomerCLV
ORDER BY TotalRevenue DESC;

-- 10.	How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album?

ALTER TABLE album
ADD COLUMN ReleaseYear INTEGER;

-- 11.	Chinook is interested in understanding the purchasing behavior of customers based on their geographical location. 
-- They want to know the average total amount spent by customers from each country, 
-- along with the number of customers and the average number of tracks purchased per customer. 
-- Write an SQL query to provide this information.

WITH CustomerSummary AS
(
SELECT
c.customer_id,
c.country,
SUM(i.total) AS TotalSpent,
SUM(il.quantity) AS TracksPurchased
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
JOIN invoice_line il
ON i.invoice_id=il.invoice_id
GROUP BY
c.customer_id,
c.country
)
SELECT
country,
COUNT(customer_id) AS NumberOfCustomers,
ROUND(AVG(TotalSpent),2) AS AvgCustomerSpend,
ROUND(AVG(TracksPurchased),2) AS AvgTracksPurchased
FROM CustomerSummary
GROUP BY country
ORDER BY AvgCustomerSpend DESC;
