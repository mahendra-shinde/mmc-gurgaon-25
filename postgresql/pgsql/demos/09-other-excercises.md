
# XYZ Bank: SQL Exercises

Below are some SQL exercises based on the XYZ Bank sample database schema. These cover basic SELECTs, JOINs, GROUP BY/ORDER BY, subtotals, and DML operations.

---

## 1. Fetch Records

**a.** List all customers with their email and phone number.
```sql
SELECT first_name, last_name, email, phone FROM customers;
```

**b.** Show all accounts with a balance greater than 20,000.
```sql
SELECT account_id, customer_id, balance FROM accounts WHERE balance > 20000;
```

**c.** Fetch all transactions for account_id = 1, ordered by date (latest first).
```sql
SELECT * FROM transactions WHERE account_id = 1 ORDER BY transaction_date DESC;
```

---

## 2. Join Operations

**a.** List all customers along with their branch name and city.
```sql
SELECT c.first_name, c.last_name, b.branch_name, b.city
FROM customers c
JOIN branches b ON c.branch_id = b.branch_id;
```

**b.** Show all accounts with the customer name and account type.
```sql
SELECT a.account_id, c.first_name, c.last_name, a.account_type, a.balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id;
```

**c.** List all transactions with the account type and customer name.
```sql
SELECT t.transaction_id, t.amount, t.transaction_type, a.account_type, c.first_name, c.last_name
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id;
```

---

## 3. Group and Order

**a.** Find the total number of accounts per branch.
```sql
SELECT b.branch_name, COUNT(a.account_id) AS total_accounts
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches b ON c.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY total_accounts DESC;
```

**b.** Show the total balance per account type.
```sql
SELECT account_type, SUM(balance) AS total_balance
FROM accounts
GROUP BY account_type;
```

**c.** List the top 5 customers with the highest account balances.
```sql
SELECT c.first_name, c.last_name, a.balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY a.balance DESC
LIMIT 5;
```

---

## 4. Subtotals (Aggregates)

**a.** For each branch, show the total number of customers and the average account balance.
```sql
SELECT b.branch_name, COUNT(DISTINCT c.customer_id) AS num_customers, AVG(a.balance) AS avg_balance
FROM branches b
LEFT JOIN customers c ON b.branch_id = c.branch_id
LEFT JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY b.branch_name;
```

**b.** For each customer, show the total credited and debited amount.
```sql
SELECT c.first_name, c.last_name,
       SUM(CASE WHEN t.transaction_type = 'credit' THEN t.amount ELSE 0 END) AS total_credited,
       SUM(CASE WHEN t.transaction_type = 'debit' THEN t.amount ELSE 0 END) AS total_debited
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.first_name, c.last_name;
```

---

## 5. DML Operations

**a.** Insert a new customer and a new account for them.
```sql
INSERT INTO customers (first_name, last_name, email, phone, branch_id)
VALUES ('Sonia', 'Mehra', 'sonia.mehra@xyzbank.com', '9000000101', 2);

-- Suppose the new customer_id is 101
INSERT INTO accounts (account_id, customer_id, account_type, balance, opened_on)
VALUES (201, 101, 'savings', 10000.00, CURRENT_DATE);
```

**b.** Update the balance of account_id = 1 by adding 5000.
```sql
UPDATE accounts SET balance = balance + 5000 WHERE account_id = 1;
```

**c.** Delete all transactions before 2024-01-01.
```sql
DELETE FROM transactions WHERE transaction_date < '2024-01-01';
```
