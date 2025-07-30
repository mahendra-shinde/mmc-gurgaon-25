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
INSERT INTO accounts (account_id, customer_id, account_type, balance, opened_on) VALUES
(1,1, 'savings', 15000.00, '2022-01-10'),
(2,2, 'current', 25000.00, '2022-02-15'),
(3,3, 'savings', 12000.00, '2022-03-20'),
(4,4, 'current', 5000.00, '2022-04-25'),
(5,5, 'savings', 30000.00, '2022-05-30');
```

### Transactions (500 sample records)
```sql
INSERT INTO transactions (account_id, amount, transaction_type, transaction_date) VALUES
(1, 500.00, 'credit', '2024-07-01 10:00:00'),
(1, 200.00, 'debit', '2024-07-02 11:00:00'),
(2, 1000.00, 'credit', '2024-07-03 12:00:00'),
(2, 300.00, 'debit', '2024-07-04 13:00:00'),
(3, 700.00, 'credit', '2024-07-05 14:00:00');

```

## Backup the database

To backup the entire `xyz_bank` database using the PostgreSQL command-line utility, follow these steps:

### 1. Open Terminal or Command Prompt

Ensure you have access to the machine where PostgreSQL is installed.

### 2. Run the `pg_dump` Command

Use the following command to create a backup file (`xyz_bank_backup.sql`):

```sh
pg_dump -U <username> -h <host> -p <port> -F p -d xyz_bank -f xyz_bank_backup.sql
```

- Replace `<username>` with your PostgreSQL username.
- Replace `<host>` with the database server address (use `localhost` if running locally).
- Replace `<port>` with the PostgreSQL port (default is `5432`).

**Example:**

```sh
pg_dump -U postgres -h localhost -p 5432 -F p -d xyz_bank -f xyz_bank_backup.sql
```

### 3. Enter Password

When prompted, enter your PostgreSQL password.

### 4. Verify the Backup

Check that `xyz_bank_backup.sql` has been created in your current directory.

**Note:**  
- The `-F p` option specifies a plain SQL script output.
- You can use other formats (`-F c` for custom, `-F t` for tar) as needed.
- For a full cluster backup (all databases), use `pg_dumpall`.

## Backup the database as a TAR archive

To backup the entire `xyz_bank` database as a TAR archive, use the following command:

> DO NOT run this command inside `psql`. Run this command in Linux Shell directly.

```sh
pg_dump -U <username> -h <host> -p <port> -F t -d xyz_bank -f xyz_bank_backup
```

- Replace `<username>` with your PostgreSQL username.
- Replace `<host>` with the database server address (use `localhost` if running locally).
- Replace `<port>` with the PostgreSQL port (default is `5432`).

**Example:**

```sh
pg_dump -U postgres -h localhost -p 5432 -F t -d xyz_bank -f xyz_bank_backup
```

This will create a backup file named `xyz_bank_backup` in your current directory in TAR format, which is suitable for restoring with `pg_restore`.
---

## Restore the TAR Backup to a New Database

To restore the TAR archive backup (`xyz_bank_backup`) into a new database (e.g., `xyz_bank2`), follow these steps:

### 1. Create the New Database

First, create the new database using `create database` in psql:

```sh
sudo -u postgres pgsql
create database xyz_bank2;
\l              # list all databases, once list is printed on screen press 'q' to quit
\q              # Quit the PSQL client
```

### 2. Restore the Backup Using `pg_restore`

Run the following command to restore the TAR archive into `xyz_bank2`:

> DO NOT run this command inside `psql`. Run this command in Linux Shell directly.

```sh
pg_restore -U <username> -h <host> -p <port> -d xyz_bank2 -F t xyz_bank_backup
```

- Replace `<username>`, `<host>`, and `<port>` as appropriate.
- `xyz_bank_backup` is the TAR file created earlier.

**Example:**

```sh
pg_restore -U postgres -h localhost -p 5432 -d xyz_bank2 -F t xyz_bank_backup
```

This will restore all tables and data from the TAR archive into the new `xyz_bank2` database.

> Note: Make sure you are in right directory / path. file "xyz_bank_backup" must be in present directory for `db_restore` command to work!


### 3. Verify the restoration

```sh
sudo -u postgres psql xyz_bank2
## List of Tables
\dt
## Quit PSQL
\q
```