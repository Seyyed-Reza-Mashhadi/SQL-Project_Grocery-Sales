-- top 10 products with highest created revenue

SELECT 
    products.product_name,
    ROUND(SUM(sales.total_price), 2) AS total_revenue
FROM products
LEFT JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY total_revenue DESC  
LIMIT 10;

-- top 10 products with lowest created revenue

SELECT 
    products.product_name,
    ROUND(SUM(sales.total_price), 2) AS total_revenue
FROM products
LEFT JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY total_revenue ASC  
LIMIT 10;



-- top 10 most demanded products

SELECT 
    products.product_name,
    Count(sales.product_id) AS n_sold_items   -- number of sold items
FROM products
LEFT JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY n_sold_items DESC  
LIMIT 10;

-- top 10 least demanded products
SELECT 
    products.product_name,
    Count(sales.product_id) AS n_sold_items   -- number of sold items
FROM products
LEFT JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY n_sold_items ASC  
LIMIT 10;

-- Product categories ranking based on created revenue 
SELECT
    categories.category_name,
    ROUND(SUM(sales.total_price), 2) AS total_revenue
FROM categories
INNER JOIN products on products.category_id = categories.category_id
INNER JOIN sales ON products.product_id = sales.product_id
GROUP BY categories.category_name
ORDER BY total_revenue DESC  

