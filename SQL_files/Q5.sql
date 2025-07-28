-- Total Revenue by Product Category

SELECT 
    pc.category_name,
    ROUND(SUM(s.total_price), 0) AS total_revenue
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
JOIN categories AS pc ON p.category_id = pc.category_id
GROUP BY pc.category_name
ORDER BY total_revenue DESC;


-- Top 5 Cities by Sales Revenue

SELECT 
    ci.city_name,
    ROUND(SUM(s.total_price), 0) AS total_revenue
FROM sales As s
JOIN customers AS cu ON s.customer_id = cu.customer_id
JOIN cities AS ci ON cu.city_id = ci.city_id
GROUP BY city_name
ORDER BY total_revenue DESC
limit 5;


