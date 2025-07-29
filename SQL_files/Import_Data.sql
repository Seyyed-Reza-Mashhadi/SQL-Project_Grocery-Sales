
"This code was pasted into the PGAdmin PSQL query editor to execute the data import from CSV files into the respective tables in the database. 
The paths to the CSV files are specified, and the `COPY` command is used to load the data into each table."

"
BEGIN;
COPY countries (country_id, country_name, country_code) FROM 'C:/My_Projects/Grocery/csv_files/countries.csv' WITH (FORMAT csv, HEADER true);
COPY categories (category_id, category_name) FROM 'C:/My_Projects/Grocery/csv_files/categories.csv' WITH (FORMAT csv, HEADER true);
COPY cities (city_id, city_name, zip_code, country_id) FROM 'C:/My_Projects/Grocery/csv_files/cities.csv' WITH (FORMAT csv, HEADER true);
COPY customers (customer_id, first_name, middle_initial, last_name, city_id, address) FROM 'C:/My_Projects/Grocery/csv_files/customers.csv' WITH (FORMAT csv, HEADER true);
COPY employees (employee_id, first_name, middle_initial, last_name, birth_date, gender, city_id, hire_date) FROM 'C:/My_Projects/Grocery/csv_files/employees.csv' WITH (FORMAT csv, HEADER true);
COPY products (product_id, product_name, price, category_id, class, modified_date, resistant, is_allergic, vitality_days) FROM 'C:/My_Projects/Grocery/csv_files/products.csv' WITH (FORMAT csv, HEADER true);
COPY sales_data (sale_id, employee_id, customer_id, product_id, quantity, discount, total_price, sale_date, transaction_number) FROM 'C:/My_Projects/Grocery/csv_files/sales.csv' WITH (FORMAT csv, HEADER true);
COMMIT;

"

