-- Complete name of top 10 core customers based on their total purchase 

SELECT
    c.customer_id,
    CONCAT(first_name, ' ', middle_initial, ' ', last_name) AS full_name,
    Round(SUM(s.total_price), 0) AS total_purchase   -- rounded for better representation of outcomes
FROM customers AS c
LEFT JOIN sales AS s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, first_name, middle_initial, last_name
ORDER BY total_purchase DESC
LIMIT 10;

/* Classifying customers based on their total spendings. The total spendings are calculated for each customer, 
   and the Q0.25 and Q0.75 quartiles are used to classify customers into three segments: Occasional customers,
   active customers, and core customers. */

WITH per_customer AS (
  SELECT 
      c.customer_id,
      Round(SUM(s.total_price), 0) AS total_revenue  -- rounded for better representation of outcomes
  FROM customers AS c
  LEFT JOIN sales AS s ON c.customer_id = s.customer_id
  GROUP BY c.customer_id
),
quartiles AS (
  SELECT 
    (percentile_cont(ARRAY[0.25, 0.75]) 
       WITHIN GROUP (ORDER BY total_revenue)) AS q
  FROM per_customer
)
SELECT
    pc.customer_id,
    pc.total_revenue,
    CASE
        WHEN pc.total_revenue <= q[1] THEN 'Occasional Customers'   -- min < x <= Q25
        WHEN pc.total_revenue <= q[2] THEN 'Active Customers'     -- Q25 < x <= Q75
        ELSE 'Core Customers'                                     -- Q75 < x <= max
    END AS customer_class 
FROM per_customer pc
CROSS JOIN quartiles
ORDER BY pc.total_revenue DESC;


-- Average order value (AOV) calculation 

SELECT
round(sum(sales.total_price)/count(DISTINCT sales.sale_id),2) AS AOV
FROM sales;


-- Average basket size (items per order) calculation

SELECT
round(sum(sales.quantity)/count(DISTINCT sales.sale_id),0) AS avg_basket_size
FROM sales;


