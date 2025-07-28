
-- Top 3 Employees by Average Daily Revenue
SELECT 
CONCAT(employees.first_name, ' ', employees.middle_initial, ' ', employees.last_name) AS full_name,
-- average based on the distinct number of work days (rounded for better representation of outcomes)
Round((SUM(total_price)/Count(distinct sales.sale_date::Date)),0) AS average_daily_revenue
FROM sales
RIGHT JOIN employees ON sales.employee_id = employees.employee_id
GROUP BY first_name, middle_initial, last_name
ORDER BY average_daily_revenue DESC
LIMIT 3;


-- Bottom 3 Employees by Average Daily Revenue
SELECT 
CONCAT(employees.first_name, ' ', employees.middle_initial, ' ', employees.last_name) AS full_name,
-- average based on the distinct number of work days (rounded for better representation of outcomes)
Round((SUM(total_price)/Count(distinct sales.sale_date::Date)),0) AS average_daily_revenue
FROM sales
RIGHT JOIN employees ON sales.employee_id = employees.employee_id
GROUP BY first_name, middle_initial, last_name
ORDER BY average_daily_revenue ASC
LIMIT 3;
