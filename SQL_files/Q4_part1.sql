-- Employee Total Revenue with Age and Job Experience
-- Calculates total sales revenue per employee
-- Adds employee age (in years) and job experience (in months) at first recorded sale date
-- Provides insight into how age and experience relate to revenue generation

WITH first_sales AS (
    SELECT 
    employee_id, 
    MIN(sale_date::DATE) AS first_sale_date
    FROM sales
    GROUP BY employee_id
),
employee_info AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.middle_initial, ' ', e.last_name) AS full_name,
        fs.first_sale_date,
        EXTRACT(YEAR FROM AGE(fs.first_sale_date, e.birth_date)) AS age_years,
        EXTRACT(YEAR FROM AGE(fs.first_sale_date, e.hire_date)) * 12 + 
        EXTRACT(MONTH FROM AGE(fs.first_sale_date, e.hire_date)) AS experience_months
    FROM employees AS e
    LEFT JOIN first_sales AS fs ON fs.employee_id = e.employee_id
)

SELECT
    ei.full_name,
    ei.age_years,
    ei.experience_months,
    ROUND(COALESCE(SUM(s.total_price),0), 0) AS total_revenue
FROM employee_info AS ei
LEFT JOIN sales s ON s.employee_id = ei.employee_id
GROUP BY ei.full_name, ei.age_years, ei.experience_months
ORDER BY total_revenue DESC;
