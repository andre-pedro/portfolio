-- Step 1: Create the database
CREATE DATABASE SecondHandGameStore;
USE SecondHandGameStore;

-- Step 2: Create the necessary tables

-- Customers table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    registration_date DATE DEFAULT CURRENT_DATE
);

-- Employees table
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2),
    hire_date DATE DEFAULT CURRENT_DATE
);

-- Games table
CREATE TABLE Games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    genre VARCHAR(50),
    release_year YEAR,
    purchase_price DECIMAL(10, 2) DEFAULT 0,
    selling_price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0
);

-- Purchases table (games purchased from customers)
CREATE TABLE Purchases (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    game_id INT NOT NULL,
    purchase_date DATE DEFAULT CURRENT_DATE,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
);

-- Sales table (games sold to customers)
CREATE TABLE Sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    game_id INT NOT NULL,
    sale_date DATE DEFAULT CURRENT_DATE,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
);

-- Step 3: Populate the tables with sample data

-- Insert sample customers
INSERT INTO Customers (name, email, phone) VALUES
('João Silva', '*****@*****.com', '000000000'),
('Maria Sousa', '*****@*****.com', '000000000'),
('Ana Oliveira', '*****@*****.com', '000000000'),
('Diogo Lima', '*****@*****.com', '000000000');

-- Insert sample employees
INSERT INTO Employees (name, role, salary) VALUES
('Emília Costa', 'Sales Representative', 2500.00),
('Miguel Santos', 'Store Manager', 4000.00),
('Sara Rocha', 'Cashier', 2000.00);

-- Insert sample games
INSERT INTO Games (title, platform, genre, release_year, purchase_price, selling_price, stock) VALUES
('The Witcher 3', 'PC', 'RPG', 2015, 20.00, 40.00, 10),
('Grand Theft Auto V', 'PlayStation 4', 'Action/Adventure', 2013, 15.00, 35.00, 8),
('Halo Infinite', 'Xbox Series X', 'FPS', 2021, 30.00, 60.00, 5),
('Minecraft', 'PC', 'Sandbox', 2011, 10.00, 25.00, 15);

-- Insert sample purchases
INSERT INTO Purchases (customer_id, employee_id, game_id, price, quantity) VALUES
(1, 1, 1, 20.00, 1),
(2, 2, 2, 15.00, 1),
(3, 3, 3, 30.00, 2);

-- Insert sample sales
INSERT INTO Sales (customer_id, employee_id, game_id, price, quantity) VALUES
(4, 1, 1, 40.00, 1),
(3, 2, 2, 35.00, 1),
(2, 3, 3, 60.00, 1);

-- Step 4: Showcase SQL skills

-- 1. Joins: Sales report with customer, employee, and game details
SELECT 
    s.sale_id,
    c.name AS customer_name,
    e.name AS employee_name,
    g.title AS game_title,
    s.price,
    s.quantity,
    s.sale_date
FROM 
    Sales s
    INNER JOIN Customers c ON s.customer_id = c.customer_id
    INNER JOIN Employees e ON s.employee_id = e.employee_id
    INNER JOIN Games g ON s.game_id = g.game_id;

-- 2. Window Functions: Ranking customers by total spending
SELECT 
    c.name AS customer_name,
    SUM(s.price * s.quantity) AS total_spent,
    RANK() OVER (ORDER BY SUM(s.price * s.quantity) DESC) AS spending_rank
FROM 
    Sales s
    INNER JOIN Customers c ON s.customer_id = c.customer_id
GROUP BY c.name;

-- 3. Aggregate Functions: General sales statistics
SELECT 
    COUNT(*) AS total_sales,
    SUM(price * quantity) AS total_revenue,
    AVG(price) AS average_price,
    MAX(price) AS max_price,
    MIN(price) AS min_price
FROM Sales;

-- 4. Creating Views: View for low-stock games
CREATE VIEW LowStockGames AS
SELECT 
    title,
    stock
FROM 
    Games
WHERE 
    stock < 5;

-- Query the view
SELECT * FROM LowStockGames;

-- 5. Converting Data Types: Formatting employee salaries and hire dates
SELECT 
    name,
    CAST(salary AS CHAR) AS salary_text,
    DATE_FORMAT(hire_date, '%d/%m/%Y') AS formatted_hire_date
FROM Employees;
