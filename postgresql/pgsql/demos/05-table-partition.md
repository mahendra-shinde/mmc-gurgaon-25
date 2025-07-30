# Table Partitioning Demo: Range Partitioning by hire_date

This demo shows how to create a partitioned table in PostgreSQL, add partitions, insert sample data, and query the partitions.

## 1. Create the Parent Table (Partitioned Table)

```sql
CREATE TABLE employees (
    employee_id SERIAL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    --- Composite primary key from TWO columns employee_id and hire_date
    PRIMARY KEY (employee_id, hire_date)
) PARTITION BY RANGE (hire_date);
```

## 2. Create Partitions

```sql
CREATE TABLE employees_2020 PARTITION OF employees
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE employees_2021 PARTITION OF employees
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
```

## 3. Insert Sample Records

```sql
INSERT INTO employees (first_name, last_name, hire_date) VALUES
  ('Alice', 'Smith', '2020-03-15'),
  ('Bob', 'Johnson', '2020-11-20'),
  ('Carol', 'Williams', '2021-02-10'),
  ('David', 'Brown', '2021-12-05');
```

## 4. Query All Records

```sql
SELECT * FROM employees;
```

## 5. Query Records from a Specific Partition (Optional)

You can query a specific partition directly (not recommended for most use cases):

```sql
SELECT * FROM employees_2020;
SELECT * FROM employees_2021;
```

## 6. Query Records by Date Range

```sql
-- Fetch employees hired in 2020
SELECT * FROM employees WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01';

-- Fetch employees hired in 2021
SELECT * FROM employees WHERE hire_date >= '2021-01-01' AND hire_date < '2022-01-01';
```

---

**Instructions:**
1. Run each SQL block in your PostgreSQL client (e.g., `psql` or PgAdmin) in order.
2. After inserting records, try the queries to see how data is distributed across partitions.
