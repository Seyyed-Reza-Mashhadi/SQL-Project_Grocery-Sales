
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(20) NOT NULL,
    country_code VARCHAR(2) NOT NULL
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(20) NOT NULL
);

CREATE TABLE cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(25) NOT NULL, 
    zip_code VARCHAR(10) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_initial VARCHAR(1) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    city_id INT,
    address TEXT,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_initial VARCHAR(1) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(1),
    city_id INT,
    hire_date DATE NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT,
    class VARCHAR(6) NOT NULL,    
    modified_date TIMESTAMP NOT NULL,
    resistant VARCHAR(7) NOT NULL,
    is_allergic VARCHAR(7) NOT NULL,
    vitality_days INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

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
