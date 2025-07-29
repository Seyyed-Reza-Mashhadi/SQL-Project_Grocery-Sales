
-- Calculating the total sales

/* Calculating the total price in sales table (it is empty) based on
available data in products and sales tables */ 


UPDATE sales
SET total_price = ROUND(products.price * sales.quantity * (1 - COALESCE(sales.discount, 0)), 2)
FROM products
WHERE sales.product_id = products.product_id;

-- Number of total sales transactions

SELECT 
    COUNT(sale_id) AS n_transactions
FROM sales;

-- Calculating the first and last sale date

SELECT 
    MIN(sale_date::DATE) AS first_sale_date,
    MAX(sale_date::DATE) AS last_sale_date
FROM sales;


-- Calculating the total revenue

SELECT 
    SUM(total_price) AS total_revenue
FROM sales;


-- Monthly revenue calculation
SELECT 
    TO_CHAR(sale_date, 'Month') AS month_name,
    ROUND(SUM(total_price), 0) AS monthly_revenue
FROM sales
WHERE sale_date IS NOT NULL
GROUP BY TO_CHAR(sale_date, 'Month'), EXTRACT(MONTH FROM sale_date)
ORDER BY EXTRACT(MONTH FROM sale_date);


-- Total Revenue by Product Category

SELECT 
    pc.category_name,
    ROUND(SUM(s.total_price), 0) AS total_revenue
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
JOIN categories AS pc ON p.category_id = pc.category_id
GROUP BY pc.category_name
ORDER BY total_revenue DESC;

