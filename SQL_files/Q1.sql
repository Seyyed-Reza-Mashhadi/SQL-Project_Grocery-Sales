-- Calculating the total sales

/* Calculating the total price in sales table (it is empty) based on
available data in products and sales tables */ 

UPDATE sales
SET total_price = ROUND(products.price * sales.quantity * (1 - COALESCE(sales.discount, 0)), 2)
FROM products
WHERE sales.product_id = products.product_id;


-- number of total sales transactions

SELECT 
    Count(sale_id) AS n_transactions
FROM sales;

-- calculating the first and last sale date
SELECT 
min(sale_date::Date) AS first_sale_date,
max(sale_date::Date) AS last_sale_date
FROM sales;

-- calculating the total revenue
SELECT 
    SUM(total_price) AS total_revenue
FROM sales;

-- calculating the monthly revenue

SELECT 
    TO_CHAR(sale_date, 'Month') AS month,
    Round(SUM(total_price),0) AS monthly_revenue
FROM sales
WHERE sale_date is not NULL  -- date is not available for some transactions
GROUP BY month;


WITH monthly_sales AS(
    SELECT 
    TO_CHAR(sale_date, 'Month') AS month,
    Round(SUM(total_price),0) AS monthly_revenue
    WHERE sale_date is not NULL  -- date is not available for some transactions
    )
SELECT 
    products.product_id,
    products.product_name,
    monthly_sales.month,
    monthly_sales.monthly_revenue
left JOIN monthly_sales on products.product_id = sales.product_id
GROUP BY month_name;


 