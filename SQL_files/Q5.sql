
-- Number of orders in different countries

SELECT 
    co.country_name,
    COUNT(s.sale_id) AS number_of_orders
FROM sales AS s
JOIN customers AS cu ON s.customer_id = cu.customer_id
JOIN cities AS ci ON cu.city_id = ci.city_id
JOIN countries AS co ON ci.country_id = co.country_id
GROUP BY co.country_name
ORDER BY number_of_orders DESC;


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


