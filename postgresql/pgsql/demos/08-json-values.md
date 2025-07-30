
# Demo: Using JSON Type Values in PostgreSQL

PostgreSQL provides robust support for storing and querying JSON data. This demo shows how to use the `json` and `jsonb` data types in a table, insert data, and query JSON fields.

## 1. Create a Table with JSON/JSONB Columns

```sql
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    ename varchar(20) NOT NULL,
    info JSONB
);
```

## 2. Insert JSON Data

```sql
INSERT INTO employees (ename, info) VALUES
('Alice', '{"age": 30, "skills": ["SQL", "Python"], "address": {"city": "Delhi", "zip": "110001"}}'),
('Bob', '{"age": 25, "skills": ["Java", "C++"], "address": {"city": "Gurgaon", "zip": "122001"}}');
```

## 3. Query JSON Data

### a) Get all employees with their info
```sql
SELECT id, ename, info FROM employees;
```

### b) Get employees where city is 'Delhi'
```sql
SELECT ename, info->'address'->>'city' AS city
FROM employees
WHERE info->'address'->>'city' = 'Delhi';
```

### c) Get employees who know Python
```sql
SELECT ename
FROM employees
WHERE info->'skills' ? 'Python';
```

### d) Show all employees with their skills
```sql
SELECT ename, info->'skills' AS skills
FROM employees;
```

## 4. Update JSON Data

```sql
UPDATE employees
SET info = jsonb_set(info, '{age}', '31')
WHERE ename = 'Alice';
```

## 5. Indexing JSONB Data

```sql
CREATE INDEX idx_employees_info ON employees USING GIN (info);
```

## 6. Delete Table (Cleanup)

```sql
DROP TABLE employees;
```
