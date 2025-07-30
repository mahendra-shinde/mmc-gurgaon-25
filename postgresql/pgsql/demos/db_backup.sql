-- XYZ Bank: Sample Database Schema and Data

-- Branches Table
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- Customers Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    branch_id INT REFERENCES branches(branch_id)
);

-- Accounts Table
CREATE TABLE accounts (
    account_id NUMERIC PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    account_type VARCHAR(20) NOT NULL,
    balance NUMERIC(15,2) NOT NULL,
    opened_on DATE NOT NULL
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    amount NUMERIC(12,2) NOT NULL,
    transaction_type VARCHAR(10) NOT NULL, -- credit/debit
    transaction_date TIMESTAMP NOT NULL
);

INSERT INTO branches (branch_name, city) VALUES
('Central', 'Delhi'),
('North', 'Delhi'),
('South', 'Gurgaon'),
('East', 'Noida'),
('West', 'Faridabad');

-- Add 5 more branches for demo
INSERT INTO branches (branch_name, city) VALUES
('Sector 14', 'Gurgaon'),
('Connaught', 'Delhi'),
('Cyber City', 'Gurgaon'),
('Indirapuram', 'Ghaziabad'),
('Old Town', 'Noida');

INSERT INTO customers (first_name, last_name, email, phone, branch_id) VALUES
('Amit', 'Sharma', 'amit.sharma1@xyzbank.com', '9000000001', 1),
('Priya', 'Verma', 'priya.verma2@xyzbank.com', '9000000002', 2),
('Rahul', 'Singh', 'rahul.singh3@xyzbank.com', '9000000003', 3),
('Neha', 'Gupta', 'neha.gupta4@xyzbank.com', '9000000004', 4),
('Vikas', 'Jain', 'vikas.jain5@xyzbank.com', '9000000005', 5),
('User96', 'Last96', 'user96@xyzbank.com', '9000000096', 1),
('User97', 'Last97', 'user97@xyzbank.com', '9000000097', 2),
('User98', 'Last98', 'user98@xyzbank.com', '9000000098', 3),
('User99', 'Last99', 'user99@xyzbank.com', '9000000099', 4),
('User100', 'Last100', 'user100@xyzbank.com', '9000000100', 5);

-- Add 10 more customers for demo
INSERT INTO customers (first_name, last_name, email, phone, branch_id) VALUES
('Sonia', 'Mehra', 'sonia.mehra101@xyzbank.com', '9000000101', 6),
('Rohit', 'Kapoor', 'rohit.kapoor102@xyzbank.com', '9000000102', 7),
('Deepa', 'Joshi', 'deepa.joshi103@xyzbank.com', '9000000103', 8),
('Manoj', 'Bansal', 'manoj.bansal104@xyzbank.com', '9000000104', 9),
('Kiran', 'Patel', 'kiran.patel105@xyzbank.com', '9000000105', 10),
('Suresh', 'Rana', 'suresh.rana106@xyzbank.com', '9000000106', 1),
('Meena', 'Yadav', 'meena.yadav107@xyzbank.com', '9000000107', 2),
('Anil', 'Kumar', 'anil.kumar108@xyzbank.com', '9000000108', 3),
('Pooja', 'Sethi', 'pooja.sethi109@xyzbank.com', '9000000109', 4),
('Tarun', 'Malik', 'tarun.malik110@xyzbank.com', '9000000110', 5);

-- Each customer gets at least 4 accounts (for 10 customers: 1-10)
INSERT INTO accounts (account_id, customer_id, account_type, balance, opened_on) VALUES
-- Accounts for customer 1
(10001, 1, 'savings', 15000.00, '2022-01-10'),
(10002, 1, 'current', 12000.00, '2022-02-10'),
(10003, 1, 'savings', 18000.00, '2022-03-10'),
(10004, 1, 'current', 9000.00, '2022-04-10'),
-- Accounts for customer 2
(10005, 2, 'savings', 25000.00, '2022-01-15'),
(10006, 2, 'current', 11000.00, '2022-02-15'),
(10007, 2, 'savings', 17000.00, '2022-03-15'),
(10008, 2, 'current', 8000.00, '2022-04-15'),
-- Accounts for customer 3
(10009, 3, 'savings', 12000.00, '2022-01-20'),
(10010, 3, 'current', 13000.00, '2022-02-20'),
(10011, 3, 'savings', 14000.00, '2022-03-20'),
(10012, 3, 'current', 7000.00, '2022-04-20'),
-- Accounts for customer 4
(10013, 4, 'savings', 5000.00, '2022-01-25'),
(10014, 4, 'current', 6000.00, '2022-02-25'),
(10015, 4, 'savings', 7000.00, '2022-03-25'),
(10016, 4, 'current', 8000.00, '2022-04-25'),
-- Accounts for customer 5
(10017, 5, 'savings', 30000.00, '2022-01-30'),
(10018, 5, 'current', 20000.00, '2022-02-28'),
(10019, 5, 'savings', 25000.00, '2022-03-30'),
(10020, 5, 'current', 15000.00, '2022-04-30'),
-- Accounts for customer 6
(10021, 6, 'savings', 18000.00, '2022-06-10'),
(10022, 6, 'current', 17000.00, '2022-07-10'),
(10023, 6, 'savings', 16000.00, '2022-08-10'),
(10024, 6, 'current', 15000.00, '2022-09-10'),
-- Accounts for customer 7
(10025, 7, 'savings', 22000.00, '2022-07-15'),
(10026, 7, 'current', 21000.00, '2022-08-15'),
(10027, 7, 'savings', 20000.00, '2022-09-15'),
(10028, 7, 'current', 19000.00, '2022-10-15'),
-- Accounts for customer 8
(10029, 8, 'savings', 9000.00, '2022-08-20'),
(10030, 8, 'current', 8000.00, '2022-09-20'),
(10031, 8, 'savings', 7000.00, '2022-10-20'),
(10032, 8, 'current', 6000.00, '2022-11-20'),
-- Accounts for customer 9
(10033, 9, 'savings', 27000.00, '2022-09-25'),
(10034, 9, 'current', 26000.00, '2022-10-25'),
(10035, 9, 'savings', 25000.00, '2022-11-25'),
(10036, 9, 'current', 24000.00, '2022-12-25'),
-- Accounts for customer 10
(10037, 10, 'savings', 35000.00, '2022-10-30'),
(10038, 10, 'current', 34000.00, '2022-11-30'),
(10039, 10, 'savings', 33000.00, '2022-12-30'),
(10040, 10, 'current', 32000.00, '2023-01-30');


INSERT INTO transactions (account_id, amount, transaction_type, transaction_date) VALUES

-- Transactions for all savings accounts (10-20 per account)
-- For demo, only savings accounts (account_id: 10001, 10003, 10005, 10007, 10009, 10011, 10013, 10015, 10017, 10019, 10021, 10023, 10025, 10027, 10029, 10031, 10033, 10035, 10037, 10039)
-- Each account gets 12 transactions (6 credit, 6 debit)
-- Dates are distributed over 2024

(10001, 1000.00, 'credit', '2024-01-05 10:00:00'),
(10001, 500.00, 'debit', '2024-01-10 11:00:00'),
(10001, 1200.00, 'credit', '2024-01-15 12:00:00'),
(10001, 700.00, 'debit', '2024-01-20 13:00:00'),
(10001, 800.00, 'credit', '2024-01-25 14:00:00'),
(10001, 600.00, 'debit', '2024-01-30 15:00:00'),
(10001, 900.00, 'credit', '2024-02-05 10:00:00'),
(10001, 400.00, 'debit', '2024-02-10 11:00:00'),
(10001, 1100.00, 'credit', '2024-02-15 12:00:00'),
(10001, 300.00, 'debit', '2024-02-20 13:00:00'),
(10001, 950.00, 'credit', '2024-02-25 14:00:00'),
(10001, 350.00, 'debit', '2024-02-28 15:00:00'),

(10003, 1500.00, 'credit', '2024-03-05 10:00:00'),
(10003, 800.00, 'debit', '2024-03-10 11:00:00'),
(10003, 1300.00, 'credit', '2024-03-15 12:00:00'),
(10003, 900.00, 'debit', '2024-03-20 13:00:00'),
(10003, 1000.00, 'credit', '2024-03-25 14:00:00'),
(10003, 700.00, 'debit', '2024-03-30 15:00:00'),
(10003, 1200.00, 'credit', '2024-04-05 10:00:00'),
(10003, 600.00, 'debit', '2024-04-10 11:00:00'),
(10003, 1100.00, 'credit', '2024-04-15 12:00:00'),
(10003, 500.00, 'debit', '2024-04-20 13:00:00'),
(10003, 950.00, 'credit', '2024-04-25 14:00:00'),
(10003, 450.00, 'debit', '2024-04-28 15:00:00'),

(10005, 2000.00, 'credit', '2024-05-05 10:00:00'),
(10005, 1000.00, 'debit', '2024-05-10 11:00:00'),
(10005, 1700.00, 'credit', '2024-05-15 12:00:00'),
(10005, 900.00, 'debit', '2024-05-20 13:00:00'),
(10005, 1200.00, 'credit', '2024-05-25 14:00:00'),
(10005, 800.00, 'debit', '2024-05-30 15:00:00'),
(10005, 1400.00, 'credit', '2024-06-05 10:00:00'),
(10005, 700.00, 'debit', '2024-06-10 11:00:00'),
(10005, 1300.00, 'credit', '2024-06-15 12:00:00'),
(10005, 600.00, 'debit', '2024-06-20 13:00:00'),
(10005, 1250.00, 'credit', '2024-06-25 14:00:00'),
(10005, 550.00, 'debit', '2024-06-28 15:00:00'),

(10007, 1100.00, 'credit', '2024-07-05 10:00:00'),
(10007, 600.00, 'debit', '2024-07-10 11:00:00'),
(10007, 1200.00, 'credit', '2024-07-15 12:00:00'),
(10007, 700.00, 'debit', '2024-07-20 13:00:00'),
(10007, 900.00, 'credit', '2024-07-25 14:00:00'),
(10007, 500.00, 'debit', '2024-07-30 15:00:00'),
(10007, 1000.00, 'credit', '2024-08-05 10:00:00'),
(10007, 400.00, 'debit', '2024-08-10 11:00:00'),
(10007, 950.00, 'credit', '2024-08-15 12:00:00'),
(10007, 350.00, 'debit', '2024-08-20 13:00:00'),
(10007, 1050.00, 'credit', '2024-08-25 14:00:00'),
(10007, 450.00, 'debit', '2024-08-28 15:00:00'),

(10009, 1300.00, 'credit', '2024-09-05 10:00:00'),
(10009, 700.00, 'debit', '2024-09-10 11:00:00'),
(10009, 1400.00, 'credit', '2024-09-15 12:00:00'),
(10009, 800.00, 'debit', '2024-09-20 13:00:00'),
(10009, 1000.00, 'credit', '2024-09-25 14:00:00'),
(10009, 600.00, 'debit', '2024-09-30 15:00:00'),
(10009, 1200.00, 'credit', '2024-10-05 10:00:00'),
(10009, 500.00, 'debit', '2024-10-10 11:00:00'),
(10009, 1100.00, 'credit', '2024-10-15 12:00:00'),
(10009, 400.00, 'debit', '2024-10-20 13:00:00'),
(10009, 950.00, 'credit', '2024-10-25 14:00:00'),
(10009, 350.00, 'debit', '2024-10-28 15:00:00'),

(10011, 1200.00, 'credit', '2024-11-05 10:00:00'),
(10011, 600.00, 'debit', '2024-11-10 11:00:00'),
(10011, 1300.00, 'credit', '2024-11-15 12:00:00'),
(10011, 700.00, 'debit', '2024-11-20 13:00:00'),
(10011, 900.00, 'credit', '2024-11-25 14:00:00'),
(10011, 500.00, 'debit', '2024-11-30 15:00:00'),
(10011, 1000.00, 'credit', '2024-12-05 10:00:00'),
(10011, 400.00, 'debit', '2024-12-10 11:00:00'),
(10011, 950.00, 'credit', '2024-12-15 12:00:00'),
(10011, 350.00, 'debit', '2024-12-20 13:00:00'),
(10011, 1050.00, 'credit', '2024-12-25 14:00:00'),
(10011, 450.00, 'debit', '2024-12-28 15:00:00'),



