 <h1 align="center">Grocery Sales Dataset Queries</h1> 
 
## 🧩 About Project 
This project presents a relational PostgreSQL database designed to analyze a grocery sales dataset sourced from Kaggle. The dataset captures real-world transactional activity and models key entities including sales, customers, products, employees, and geographic regions across 128 days. Through a series of business-driven SQL queries, the project explores core analytical questions related to revenue trends, product performance, customer segmentation, employee effectiveness, and regional sales distribution.

🔗 **Dataset Source:** [Grocery Sales Dataset on Kaggle](https://www.kaggle.com/datasets/155a87ba8d7e92c5896ddc7f3ca3e3fa9c799207ed8dbf9a1cedf2e2e03e3c14)

## 💡Objectives

| Objective | Updated Description                                                                 |
|-----------|--------------------------------------------------------------------------------------|
| **Q1**    | Track sales performance over time, including monthly revenue, transaction count, and date range. |
| **Q2**    | Identify high- and low-performing products based on sales volume and revenue contribution. |
| **Q3**    | Classify customers by spending behavior and calculate AOV and average basket size.     |
| **Q4**    | Evaluate employee performance using revenue metrics and examine correlations with experience or age. |
| **Q5**    | Analyze regional sales across cities and countries to identify top-performing markets. |


## 🛠️ Database Setup & Data Preparation
### 🗃️ Step 1: Creating the PostgreSQL Database 
Created an empty PostgreSQL database named "grocery" using:
```sql
CREATE DATABASE grocery;
```
### 📐 Step 2: Designing the Schema & Creating Tables
The database schema was designed using appropriate data types, primary keys, and foreign keys to maintain referential integrity. Tables include sales, products, categories, customers, employees, cities, and countries.

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
  - ⚠️ **Attention:**
    It is important to note that the schema was modeled based on the structure defined in the original Kaggle dataset description, which follows a normalized, multi-table design with separate tables for entities like cities and countries. This design introduces some indirect relationships in the database (e.g., customers and employees both connecting to countries through cities), which can lead to ambiguity in analytical contexts if not handled carefully. I addressed this challenge in a separate project ([link to my Power BI project]), where I resolved the ambiguity through targeted ETL steps. For this SQL project, I intentionally preserved the original schema to reflect how real-world data is often delivered. This approach provided a solid foundation for practicing SQL join logic, referential integrity, and relational data modeling.

- **🔗 Related SQL File:** [**Create_Tables.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Create_Tables.sql)
### 📥 Step 3: Importing CSV Data into Tables
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

## 💻 Analytical Queries & Key Insights
The analysis phase focused on answering real business questions using SQL queries. The focus is on SQL but simple illustrations are also provided for visualizing the query outputs in some cases.
### 📈 Q1: Analyze Sales Performance Over Time
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
  - Timeframe: 2018/01/01 to 2018/05/09 
  - Transactions: ~6.7M | Revenue: $4.33B
  - March was the peak revenue month ($1.03B)
  - Confections was the top-earning product category

<p align="center">
  <img src="https://github.com/user-attachments/assets/c0ef8527-6a49-4987-9351-0a7814ca6c3b" width="600">
</p>
  
🔗 Related SQL File: [**Q1.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q1.sql)
 
### 🔍 Q2: Analyze Product Performance by Volume and Revenue
The example query below shows how the top 10 highest-demand products are characterized based on the number of sold products.
```sql
-- Top 10 Highest-demand Products
SELECT 
    products.product_name,
    Count(sales.product_id) AS n_sold_items 
FROM products
LEFT JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY n_sold_items DESC  
LIMIT 10;
```
Key outcomes:
  - Top-selling product: Longos - Chicken Wings
  - Highest revenue: Bread - Calabrese Baguette
  - Lowest performers: Peppercorn Melange (by volume), Japanese Bread Crumbs (by revenue)

<p align="center">
  <img src="https://github.com/user-attachments/assets/04802fac-d1fb-4ff0-8ae7-c49de44054b5" width="700">
</p>

🔗 Related SQL File: [**Q2.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q2.sql)


### 🛒 Q3: Segment Customers and Analyze Order Metrics
The customers are classified based on their total expenditure. For this purpose, the total spending of each customer is calculated, and then based on 25% and 75% percentile thresholds, customers are placed into three buckets or groups including low spenders, mid-tier spenders, and high-value customers.
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
  - AOV: $641 | Avg. basket size: 13 items
  - Customers segmented into three classes: 
      - Low Spenders: Customers with total purchases below approximately $22.3K (25th percentile)
      - Mid-Tier Spenders: Customers whose spending falls between approximately $22.3K and $63.8K (25th to 75th percentile)
      - High-Value Customers: Customers spending above approximately $63.8K (75th percentile), representing the top spenders driving significant revenue.
  - Top 10 customers ranked by total purchases


<p align="center">
  <img src="https://github.com/user-attachments/assets/a0114d57-8506-46ed-b879-bbbdb5159724" width="550">
</p>

🔗 Related SQL File: [**Q3.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q3.sql)


### 🧑‍💼 Q4: Evaluate Sales Staff Performance and Experience Impact
This query extracts the top three employees ranked by their average daily revenue, using distinct workdays for accuracy.

```sql
SELECT 
CONCAT(employees.first_name, ' ', employees.middle_initial, ' ', employees.last_name) AS full_name,
Round((SUM(total_price)/Count(distinct sales.sale_date::Date)),0) AS average_daily_revenue  -- based on the distinct number of work days 
FROM sales
RIGHT JOIN employees ON sales.employee_id = employees.employee_id
GROUP BY first_name, middle_initial, last_name
ORDER BY average_daily_revenue DESC
LIMIT 3;
```

Key outcomes:
  - Top 3 employees ranked by average daily revenue
  - Small revenue differences relative to total generated revenue, showing relatively similar performance of all employees
  - Age and experience show little effect on revenue, implying performance depends more on sales abilities and customer rapport than seniority

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/0b0d61b0-9f18-4ee6-9ae4-b86409652ef9" width="350"/></td>
    <td><img src="https://github.com/user-attachments/assets/a9ca2026-36a3-4713-add8-4fb3b4185c67" width="450"/></td>
  </tr>
</table>



🔗 Related SQL Files: [**Q4_part1.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q4_part1.sql), [**Q4_part2.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q4_part2.sql), [**Q4_part3.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q4_part3.sql)


### 🌍 Q5: Assess Regional Sales Performance Across Cities and Countries
The following query retrieves the top five cities by total revenue.

```sql
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
  - All sales occurred in the U.S.; countries table allows for future expansion
  - Top cities by revenue: Tucson, Jackson, Sacramento, Fort Wayne, Indianapolis

<p align="center">
  <img src="https://github.com/user-attachments/assets/859b9097-e363-4067-84d9-ec0e91207b92" width="250">
</p>
  - The Confections category generates the highest revenue among all product categories.

🔗 Related SQL File: [**Q5.sql**](https://github.com/Seyyed-Reza-Mashhadi/SQL-Project_Grocery-Sales/blob/main/SQL_files/Q5.sql)


## 📌 Conclusion & Strategic Recommendations

This project highlights the analytical value of well-structured SQL queries in uncovering actionable insights from transactional data. Over 6.7 million sales records were processed to reveal key trends:

- **Revenue peaked in March**, with the **Confections** category emerging as the most profitable.
- **"Longos - Chicken Wings"** led in unit sales, while **"Bread - Calabrese Baguette"** generated the highest revenue.
- Customers could be segmented effectively into spend-based tiers. This segmentation could be used to design tier-specific promotions—offering loyalty rewards to high-value customers or bundled discounts to mid-tier spenders to boost retention and upselling.
- The **average order value (AOV)** was **$641**, with an **average basket size** of **13 items**—indicating solid cross-selling performance and potential for further bundling strategies.
- Sales staff performance showed **minimal correlation with age or experience**, suggesting that **training programs should focus more on sales techniques and soft skills** rather than tenure.
- Cities like **Tucson and Jackson** emerged as top-performing markets. To sustain growth in these regions, operations teams should prioritize **inventory optimization, timely deliveries, and personalized local offers** to ensure customer satisfaction and avoid fulfillment delays.


## 🔁 Related Project

- 📊 [Power BI Dashboard – Grocery Sales](https://github.com/Seyyed-Reza-Mashhadi/PowerBI-Project_Grocery-Sales): An interactive dashboard that visually explores key trends from this SQL project — including sales performance, product demand, customer spending metrics, employee highlights, and regional insights.








