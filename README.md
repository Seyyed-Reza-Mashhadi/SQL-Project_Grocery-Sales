# 🧩 About Project 
This project showcases my SQL skills through the design, population, and analysis of a relational database built to simulate a real-world grocery sales environment. The dataset, obtained from Kaggle, spans four months of transactional and operational data, including customers, products, employees, cities, and countries.

🔗 Dataset Source: [Grocery Sales Dataset on Kaggle](https://www.kaggle.com/datasets/155a87ba8d7e92c5896ddc7f3ca3e3fa9c799207ed8dbf9a1cedf2e2e03e3c14)

# 💡Objectives

| Objective | Description                                                                 |
|-----------|-----------------------------------------------------------------------------|
| **Q1**        | Analyze sales trends by month, total revenue, transaction count, and date range. |
| **Q2**        | Identify top/bottom products by revenue and demand.  |
| **Q3**        | Segment customers by spend; find top buyers and calculate Average Order Value and basket size. |
| **Q4**        | Evaluate sales staff by total/weekly revenue, share, and experience.       |
| **Q5**        | Analyze regional performance by city and category revenue.                        |

# 🛠️ Database Creation
## 🗃️ Database Creation 
Created an empty PostgreSQL database named "grocery" using:
```sql
CREATE DATABASE grocery;
```
## 📐Schema Design,  & Table Creation  
The database schema was designed using appropriate data types, primary keys, and foreign keys to maintain referential integrity. Tables include sales, products, categories, customers, employees, cities and countries. 

Example snippet:
```sql
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    employee_id INT,
    customer_id INT,
    product_id INT,
    quantity INT,
    discount DECIMAL(5, 2),
    total_price DECIMAL(10, 2),
    sale_date TIMESTAMP,
    transaction_number TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
  );
```
- **🔗 Related SQL File:** [**Create_Tables.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Create_Tables.sql)
## 📥 Importing Data 
All tables were populated with real CSV data using PostgreSQL's efficient COPY command.

```text
BEGIN;
COPY countries (country_id, country_name, country_code)
FROM 'C:/.../countries.csv' 
WITH (FORMAT csv, HEADER true);
...
COMMIT;
```

Wapping the commands in BEGIN...COMMIT block is to ensure transactional integrity.

# 💻 Building Queries For Project Objectives
The analysis phase focused on answering real business questions using SQL queries. The focus is on SQL but simple illustrations are also provided for visualizing the query outputs in some cases.
## 📈 Q1: Analyze sales trends by month, total revenue, transaction count, and date range.
Before getting started with different tasks related to revenue, the total price column should be calculated as it is empty. Based on columns available in sales, and product tables, the values are calculated and inserted into table via the query below
```sql
UPDATE sales
SET total_price = ROUND(products.price * sales.quantity * (1 - COALESCE(sales.discount, 0)), 2)
FROM products
WHERE sales.product_id = products.product_id;
```
Here is examples of queries related to this objective (full query can be find in this file):
``` sql
-- Monthly revenue calculation
SELECT 
    TO_CHAR(sale_date, 'Month') AS month_name,
    ROUND(SUM(total_price), 0) AS monthly_revenue
FROM sales
WHERE sale_date IS NOT NULL
GROUP BY TO_CHAR(sale_date, 'Month'), EXTRACT(MONTH FROM sale_date)
ORDER BY EXTRACT(MONTH FROM sale_date);
```
Key outcomes:
  - Period: 2018/01/01 to 2018/05/09 (about 4 months)
  - Number of transactions: 6,758,125 
  - Total Revenue: 4,332,478,963 $ 
  - The highest monthly revenue is related to March (1,032,208,708 $).
  - The Confections category generates the highest revenue among all product categories.

<p align="center">
  <img src="https://github.com/user-attachments/assets/c0ef8527-6a49-4987-9351-0a7814ca6c3b" width="600">
</p>
  
🔗 Related SQL File: [**Q1.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q1.sql)
 
## 🔍 Q2: Identify top/bottom products by revenue and demand
The example query below shows how the top 10 highest-demand products are characterized based on the number of sold products.
```sql
-- Top 10 Highest-demand Products
SELECT 
    products.product_name,
    Count(sales.product_id) AS n_sold_items   -- number of sold items
FROM products
LEFT JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY n_sold_items DESC  
LIMIT 10;
```
Key outcomes:
  - As reported in figure below, the highest-demanded product was "Longos - Chicken Wings", and the lowest-demand product was "Spice - Peppercorn Melange".
  - The top products in terms of generated revenue was "Bread - Calabrese Baguette". On the other hand, the lowest revenue is related to "Bread Crumbs - Japense Style". 


<p align="center">
  <img src="https://github.com/user-attachments/assets/04802fac-d1fb-4ff0-8ae7-c49de44054b5" width="700">
</p>

🔗 Related SQL File: [**Q2.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q2.sql)


## 🛒 Q3: Segment customers by spend; find top buyers and calculate Average Order Value and basket size
The customers are classified based on their total expenditure. For this purpose, the total spending of each customer is calculated, and then based on 25% and 75% percentile thresholds, costumers are placed into three buckets or groups including low spenders, mid-tier spenders, and high-value customers.
```sql
WITH per_customer AS (
    SELECT 
        c.customer_id,
        ROUND(SUM(s.total_price), 0) AS total_revenue  -- rounded for better representation of outcomes
    FROM customers AS c
    LEFT JOIN sales AS s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id
),
quartiles AS (
    SELECT 
        percentile_cont(ARRAY[0.25, 0.75]) 
        WITHIN GROUP (ORDER BY total_revenue) AS q
    FROM per_customer
)
SELECT
    pc.customer_id,
    pc.total_revenue,
    CASE
        WHEN pc.total_revenue <= q[1] THEN 'Low Spenders'         -- min < x <= Q25
        WHEN pc.total_revenue <= q[2] THEN 'Mid-Tier Spenders'    -- Q25 < x <= Q75
        ELSE 'High-Value Customers'                               -- Q75 < x <= max
    END AS customer_class 
FROM per_customer pc
CROSS JOIN quartiles
ORDER BY pc.total_revenue DESC;
```
Key outcomes:
  - Average Order Value (AOV): 641.08 $
  - Average bucket size: 13
  - Customers are classified based on their total spending into three groups.
  - Top ten customers with highest purchases are characterized. 


<p align="center">
  <img src="https://github.com/user-attachments/assets/a0114d57-8506-46ed-b879-bbbdb5159724" width="550">
</p>

🔗 Related SQL File: [**Q3.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q3.sql)


## 🧑‍💼 Q4: Evaluate sales staff by total/weekly revenue, share, and experience.
This query extracts the top three employees ranked by their average daily revenue, using distinct workdays for accuracy.

```sql
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
```

Key outcomes:
  - The top three employees based on average daily revenue are identified. However, the differences in revenue among them are minimal when considering their total sales values or their weekly revenue contributions.
  - Neither the employee’s age nor their job experience shows a significant correlation with revenue generation (look at the illustrated figure below). This suggests that factors other than seniority or experience—such as individual sales skill, motivation, or customer interaction quality—may play a more critical role in sales performance.

<p align="center">
  <img src="https://github.com/user-attachments/assets/0b0d61b0-9f18-4ee6-9ae4-b86409652ef9" width="325">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/a9ca2026-36a3-4713-add8-4fb3b4185c67" width="525">
</p>



🔗 Related SQL Files: [**Q4_part1.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q4_part1.sql), [**Q4_part2.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q4_part2.sql), [**Q4_part3.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q4_part3.sql)


## 🌍 Q5: Analyze regional performance by city and category revenue.
Below, shows a query to obtain the list of top five cities...

```sql
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
```

Key outcomes:
  - The dataset contains sales data exclusively from the United States. The inclusion of a countries table likely reflects a forward-thinking design choice by the database architect, anticipating future expansion.
  - The top five cities by total sales revenue, in descending order, are: Tucson, Jackson, Sacramento, Fort Wayne, and Indianapolis.

<p align="center">
  <img src="https://github.com/user-attachments/assets/859b9097-e363-4067-84d9-ec0e91207b92" width="275">
</p>
  - The Confections category generates the highest revenue among all product categories.

🔗 Related SQL File: [**Q5.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q5.sql)

#  📌 Strategic Recommendations / Futher Steps 
correlation of age and experience maybe ?

 Add visual dashboards (e.g., via Power BI or Tableau)

 Implement stored procedures for monthly reports

 Add more advanced analytics: e.g., customer lifetime value or employee conversion rates








