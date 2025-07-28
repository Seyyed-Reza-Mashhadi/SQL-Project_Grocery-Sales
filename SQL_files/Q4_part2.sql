-- Summary: Median Weekly Revenue and Median Weekly Revenue Share per Employee

WITH weekly_revenue AS (
    SELECT 
        e.employee_id,
        CONCAT(e.first_name, ' ', e.middle_initial, ' ', e.last_name) AS full_name,
        EXTRACT(WEEK FROM s.sale_date::DATE)::int AS week,
        ROUND(SUM(s.total_price), 0) AS weekly_revenue
    FROM employees e
    JOIN sales s ON s.employee_id = e.employee_id
    WHERE s.sale_date IS NOT NULL
    GROUP BY e.employee_id, full_name, week
),
weekly_share AS (
    SELECT 
        employee_id,
        full_name,
        week,
        weekly_revenue,
        ROUND(100.0 * weekly_revenue / SUM(weekly_revenue) OVER (PARTITION BY week), 2) AS revenue_share_percent
    FROM weekly_revenue
)

SELECT 
    full_name,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY weekly_revenue) AS median_weekly_revenue,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue_share_percent) AS median_weekly_revenue_share
FROM weekly_share
GROUP BY full_name
ORDER BY median_weekly_revenue DESC;




-- Detailed: Weekly Revenue and Weekly Revenue Share per Employee

WITH weekly_revenue AS (
    SELECT 
        e.employee_id,
        CONCAT(e.first_name, ' ', e.middle_initial, ' ', e.last_name) AS full_name,
        EXTRACT(WEEK FROM s.sale_date::DATE)::int AS week,
        ROUND(SUM(s.total_price), 0) AS weekly_revenue
    FROM employees e
    JOIN sales s ON s.employee_id = e.employee_id
    WHERE s.sale_date IS NOT NULL
    GROUP BY e.employee_id, full_name, week
)

SELECT 
    employee_id,
    full_name,
    week,
    weekly_revenue,
    ROUND(100.0 * weekly_revenue / SUM(weekly_revenue) OVER (PARTITION BY week), 2) AS revenue_share_percent
FROM weekly_revenue
ORDER BY employee_id, week;
