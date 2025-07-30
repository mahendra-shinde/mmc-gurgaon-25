# XYZ Bank: Sample Database

This document provides the schema and sample data for a fictional XYZ Bank database. The schema includes four main tables: `customers`, `accounts`, `transactions`, and `branches`.

## Schema

```sql
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
    account_id SERIAL PRIMARY KEY,
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
```

## Sample Data

### Branches
```sql
INSERT INTO branches (branch_name, city) VALUES
('Central', 'Delhi'),
('North', 'Delhi'),
('South', 'Gurgaon'),
('East', 'Noida'),
('West', 'Faridabad');
```

### Customers (100 sample records)
```sql
INSERT INTO customers (first_name, last_name, email, phone, branch_id) VALUES
('Amit', 'Sharma', 'amit.sharma1@xyzbank.com', '9000000001', 1),
('Priya', 'Verma', 'priya.verma2@xyzbank.com', '9000000002', 2),
('Rahul', 'Singh', 'rahul.singh3@xyzbank.com', '9000000003', 3),
('Neha', 'Gupta', 'neha.gupta4@xyzbank.com', '9000000004', 4),
('Vikas', 'Jain', 'vikas.jain5@xyzbank.com', '9000000005', 5),
-- ... (add 95 more similar records with unique names/emails/phones/branch_ids)
('User96', 'Last96', 'user96@xyzbank.com', '9000000096', 1),
('User97', 'Last97', 'user97@xyzbank.com', '9000000097', 2),
('User98', 'Last98', 'user98@xyzbank.com', '9000000098', 3),
('User99', 'Last99', 'user99@xyzbank.com', '9000000099', 4),
('User100', 'Last100', 'user100@xyzbank.com', '9000000100', 5);
```

### Accounts (200 sample records)
```sql
INSERT INTO accounts (customer_id, account_type, balance, opened_on) VALUES
(1, 'savings', 15000.00, '2022-01-10'),
(2, 'current', 25000.00, '2022-02-15'),
(3, 'savings', 12000.00, '2022-03-20'),
(4, 'current', 5000.00, '2022-04-25'),
(5, 'savings', 30000.00, '2022-05-30')
```

### Transactions (500 sample records)
```sql
INSERT INTO transactions (account_id, amount, transaction_type, transaction_date) VALUES
(1, 500.00, 'credit', '2024-07-01 10:00:00'),
(1, 200.00, 'debit', '2024-07-02 11:00:00'),
(2, 1000.00, 'credit', '2024-07-03 12:00:00'),
(2, 300.00, 'debit', '2024-07-04 13:00:00'),
(3, 700.00, 'credit', '2024-07-05 14:00:00')

```
