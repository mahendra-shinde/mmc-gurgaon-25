# PostgreSQL Advanced Learning Material

## Table of Contents
1. [Working with PostgreSQL](#working-with-postgresql)
2. [Concept of Standby Databases](#concept-of-standby-databases)
3. [DDL (Data Definition Language) & DML (Data Manipulation Language)](#ddl-dml)
4. [Indexes and Fragmentation Concepts](#indexes-fragmentation)
5. [Database Objects - Procedures, Functions, Views](#database-objects)
6. [Practical Labs and Exercises](#practical-labs)

---

## 1. Working with PostgreSQL {#working-with-postgresql}

### 1.1 Connecting to PostgreSQL

#### Command Line Connection
```bash
# Connect to local PostgreSQL instance
psql -U username -d database_name

# Connect to remote PostgreSQL instance
psql -h hostname -p 5432 -U username -d database_name

# Connect with specific options
psql -U postgres -h localhost -p 5432 -d mydb -W
```

#### Connection Parameters
- `-h`: Host (default: localhost)
- `-p`: Port (default: 5432)
- `-U`: Username
- `-d`: Database name
- `-W`: Prompt for password
- `-c`: Execute command and exit

### 1.2 Basic PostgreSQL Commands

#### Meta Commands (psql specific)
```sql
-- List all databases
\l

-- Connect to a database
\c database_name

-- List all tables in current database
\dt

-- Describe table structure
\d table_name

-- List all schemas
\dn

-- List all users and roles
\du

-- Show current database and user
\conninfo

-- Get help
\h SQL_COMMAND
\?

-- Exit psql
\q
```

#### Basic SQL Operations
```sql
-- Show current database
SELECT current_database();

-- Show current user
SELECT current_user;

-- Show PostgreSQL version
SELECT version();

-- Show current timestamp
SELECT now();

-- Show active connections
SELECT datname, usename, client_addr, state 
FROM pg_stat_activity 
WHERE state = 'active';
```

### 1.3 Database and Schema Management

#### Creating Databases
```sql
-- Create database with default settings
CREATE DATABASE mycompany;

-- Create database with specific settings
CREATE DATABASE mycompany
    WITH 
    OWNER = myuser
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = 100;

-- Drop database
DROP DATABASE IF EXISTS mycompany;
```

#### Schema Management
```sql
-- Create schema
CREATE SCHEMA hr AUTHORIZATION hr_admin;

-- Set search path
SET search_path TO hr, public;

-- Show current search path
SHOW search_path;

-- Drop schema
DROP SCHEMA hr CASCADE;
```

### 1.4 User and Role Management

#### Creating Users and Roles
```sql
-- Create role
CREATE ROLE developer;

-- Create user with login capability
CREATE USER john_doe WITH PASSWORD 'secure_password';

-- Create user with multiple options
CREATE USER jane_smith 
    WITH LOGIN 
    PASSWORD 'another_password'
    CREATEDB 
    VALID UNTIL '2025-12-31';

-- Grant role to user
GRANT developer TO john_doe;
```

#### Privilege Management
```sql
-- Grant database privileges
GRANT CONNECT ON DATABASE mycompany TO john_doe;
GRANT USAGE ON SCHEMA hr TO john_doe;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA hr TO john_doe;

-- Grant specific table privileges
GRANT SELECT, INSERT ON hr.employees TO john_doe;

-- Revoke privileges
REVOKE INSERT ON hr.employees FROM john_doe;

-- Check user privileges
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'employees';
```

---

## 2. Concept of Standby Databases {#concept-of-standby-databases}

### 2.1 Introduction to High Availability

PostgreSQL provides several mechanisms for high availability and disaster recovery:
- **Streaming Replication**: Real-time data replication
- **Log Shipping**: Archive-based replication
- **Synchronous Replication**: Zero data loss replication
- **Hot Standby**: Read-only queries on standby

### 2.2 Streaming Replication Architecture

```
┌─────────────────────────────────────┐
│           Primary Server            │
│  ┌─────────────────────────────────┐│
│  │         WAL Writer              ││
│  │    (Write-Ahead Log)            ││
│  └─────────────┬───────────────────┘│
└────────────────┼────────────────────┘
                 │ WAL Stream
                 ▼
┌─────────────────────────────────────┐
│          Standby Server             │
│  ┌─────────────────────────────────┐│
│  │       WAL Receiver              ││
│  │    (Applies WAL Records)        ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### 2.3 Setting Up Streaming Replication

#### Primary Server Configuration

**Step 1: Configure postgresql.conf**
```ini
# Replication settings
wal_level = replica
max_wal_senders = 3
wal_keep_segments = 32
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/archive/%f'

# Connection settings
listen_addresses = '*'
port = 5432
```

**Step 2: Configure pg_hba.conf**
```
# Replication connections
host replication replicator 192.168.1.0/24 md5
```

**Step 3: Create Replication User**
```sql
CREATE USER replicator WITH REPLICATION LOGIN PASSWORD 'repl_password';
```

#### Standby Server Setup

**Step 1: Create Base Backup**
```bash
# On standby server
pg_basebackup -h primary_server_ip -D /var/lib/postgresql/data \
    -U replicator -P -W -R
```

**Step 2: Configure recovery.conf (PostgreSQL < 12)**
```ini
# recovery.conf
standby_mode = 'on'
primary_conninfo = 'host=primary_server_ip port=5432 user=replicator password=repl_password'
recovery_target_timeline = 'latest'
```

**Step 3: Configure postgresql.conf (PostgreSQL >= 12)**
```ini
# postgresql.conf on standby
primary_conninfo = 'host=primary_server_ip port=5432 user=replicator password=repl_password'
primary_slot_name = 'standby_slot'
promote_trigger_file = '/tmp/postgresql.trigger'
```

### 2.4 Monitoring Replication

#### Check Replication Status on Primary
```sql
-- View replication slots
SELECT slot_name, active, restart_lsn FROM pg_replication_slots;

-- View WAL sender processes
SELECT client_addr, state, sync_state, sync_priority 
FROM pg_stat_replication;

-- Check WAL lag
SELECT client_addr, 
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), flush_lsn)) AS flush_lag,
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)) AS replay_lag
FROM pg_stat_replication;
```

#### Check Replication Status on Standby
```sql
-- Check if server is in recovery mode
SELECT pg_is_in_recovery();

-- Get last received WAL location
SELECT pg_last_wal_receive_lsn();

-- Get last replayed WAL location
SELECT pg_last_wal_replay_lsn();

-- Calculate replication lag
SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp())) AS lag_seconds;
```

### 2.5 Failover and Switchover

#### Manual Failover
```bash
# On standby server - promote to primary
pg_ctl promote -D /var/lib/postgresql/data

# Or create trigger file
touch /tmp/postgresql.trigger
```

#### Planned Switchover
```sql
-- On primary server - perform checkpoint
CHECKPOINT;

-- Stop primary server gracefully
pg_ctl stop -D /var/lib/postgresql/data -m fast

-- Promote standby
pg_ctl promote -D /var/lib/postgresql/data
```

### 2.6 Synchronous Replication

#### Configuration for Zero Data Loss
```ini
# On primary server
synchronous_standby_names = 'standby1,standby2'
synchronous_commit = on
```

```sql
-- Check synchronous replication status
SELECT application_name, sync_state 
FROM pg_stat_replication 
WHERE sync_state = 'sync';
```

---

## 3. DDL (Data Definition Language) & DML (Data Manipulation Language) {#ddl-dml}

### 3.1 Data Definition Language (DDL)

DDL commands are used to define and modify database structure.

#### 3.1.1 Table Operations

**Creating Tables**
```sql
-- Basic table creation
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE DEFAULT CURRENT_DATE,
    salary DECIMAL(10,2),
    department_id INTEGER
);

-- Table with constraints
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    budget DECIMAL(15,2) CHECK (budget > 0),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Table with foreign key
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INTEGER REFERENCES departments(id) ON DELETE CASCADE
);

-- Temporary table
CREATE TEMPORARY TABLE temp_data (
    id INTEGER,
    value TEXT
);
```

**Altering Tables**
```sql
-- Add column
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

-- Modify column
ALTER TABLE employees ALTER COLUMN salary TYPE DECIMAL(12,2);

-- Add constraint
ALTER TABLE employees ADD CONSTRAINT chk_salary CHECK (salary > 0);

-- Drop column
ALTER TABLE employees DROP COLUMN phone;

-- Rename table
ALTER TABLE employees RENAME TO staff;

-- Rename column
ALTER TABLE employees RENAME COLUMN first_name TO fname;
```

**Dropping Tables**
```sql
-- Drop table
DROP TABLE IF EXISTS employees;

-- Drop table with cascade
DROP TABLE departments CASCADE;
```

#### 3.1.2 Index Operations

**Creating Indexes**
```sql
-- Basic index
CREATE INDEX idx_employees_email ON employees(email);

-- Composite index
CREATE INDEX idx_employees_name ON employees(last_name, first_name);

-- Unique index
CREATE UNIQUE INDEX idx_employees_ssn ON employees(ssn);

-- Partial index
CREATE INDEX idx_active_employees ON employees(department_id) 
WHERE status = 'active';

-- Expression index
CREATE INDEX idx_employees_lower_email ON employees(lower(email));

-- B-tree index (default)
CREATE INDEX idx_employees_salary ON employees USING btree(salary);

-- Hash index
CREATE INDEX idx_employees_dept_hash ON employees USING hash(department_id);

-- GIN index for array/JSON data
CREATE INDEX idx_employees_skills ON employees USING gin(skills);
```

#### 3.1.3 View Operations

**Creating Views**
```sql
-- Simple view
CREATE VIEW active_employees AS
SELECT id, first_name, last_name, email
FROM employees
WHERE status = 'active';

-- Complex view with joins
CREATE VIEW employee_details AS
SELECT 
    e.id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    d.name AS department_name,
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.id;

-- Updatable view
CREATE VIEW high_earners AS
SELECT id, first_name, last_name, salary
FROM employees
WHERE salary > 50000
WITH CHECK OPTION;
```

#### 3.1.4 Constraint Operations

**Adding Constraints**
```sql
-- Primary key
ALTER TABLE employees ADD CONSTRAINT pk_employees PRIMARY KEY (id);

-- Foreign key
ALTER TABLE employees 
ADD CONSTRAINT fk_employees_department 
FOREIGN KEY (department_id) REFERENCES departments(id);

-- Check constraint
ALTER TABLE employees 
ADD CONSTRAINT chk_salary_positive 
CHECK (salary > 0);

-- Unique constraint
ALTER TABLE employees 
ADD CONSTRAINT uk_employees_email 
UNIQUE (email);

-- Not null constraint
ALTER TABLE employees ALTER COLUMN email SET NOT NULL;
```

### 3.2 Data Manipulation Language (DML)

DML commands are used to manipulate data within tables.

#### 3.2.1 INSERT Operations

**Basic Insert**
```sql
-- Insert single row
INSERT INTO employees (first_name, last_name, email, salary)
VALUES ('John', 'Doe', 'john.doe@company.com', 75000);

-- Insert multiple rows
INSERT INTO employees (first_name, last_name, email, salary)
VALUES 
    ('Jane', 'Smith', 'jane.smith@company.com', 80000),
    ('Bob', 'Johnson', 'bob.johnson@company.com', 65000),
    ('Alice', 'Brown', 'alice.brown@company.com', 70000);

-- Insert with subquery
INSERT INTO employees (first_name, last_name, email)
SELECT first_name, last_name, email 
FROM temp_employees 
WHERE status = 'approved';

-- Insert and return data
INSERT INTO employees (first_name, last_name, email)
VALUES ('Mike', 'Wilson', 'mike.wilson@company.com')
RETURNING id, first_name, last_name;
```

#### 3.2.2 UPDATE Operations

**Basic Update**
```sql
-- Update single row
UPDATE employees 
SET salary = 85000 
WHERE id = 1;

-- Update multiple columns
UPDATE employees 
SET 
    salary = salary * 1.1,
    last_updated = NOW()
WHERE department_id = 2;

-- Update with join
UPDATE employees 
SET salary = salary * 1.05
FROM departments d
WHERE employees.department_id = d.id 
AND d.name = 'Engineering';

-- Conditional update
UPDATE employees 
SET salary = CASE 
    WHEN years_experience > 5 THEN salary * 1.15
    WHEN years_experience > 2 THEN salary * 1.10
    ELSE salary * 1.05
END;

-- Update and return
UPDATE employees 
SET salary = 90000 
WHERE id = 1
RETURNING id, first_name, salary;
```

#### 3.2.3 DELETE Operations

**Basic Delete**
```sql
-- Delete specific rows
DELETE FROM employees 
WHERE status = 'terminated';

-- Delete with join
DELETE FROM employees 
USING departments d
WHERE employees.department_id = d.id 
AND d.name = 'Marketing';

-- Delete and return
DELETE FROM employees 
WHERE salary < 30000
RETURNING id, first_name, last_name;

-- Truncate table (faster for large tables)
TRUNCATE TABLE temp_data;
```

#### 3.2.4 SELECT Operations (Advanced)

**Complex Queries**
```sql
-- Window functions
SELECT 
    first_name,
    last_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as salary_rank,
    AVG(salary) OVER (PARTITION BY department_id) as dept_avg_salary
FROM employees;

-- Common Table Expressions (CTE)
WITH high_earners AS (
    SELECT * FROM employees WHERE salary > 80000
),
department_stats AS (
    SELECT 
        department_id,
        COUNT(*) as emp_count,
        AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT h.first_name, h.last_name, ds.avg_salary
FROM high_earners h
JOIN department_stats ds ON h.department_id = ds.department_id;

-- Recursive CTE
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: top-level managers
    SELECT id, first_name, last_name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT e.id, e.first_name, e.last_name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT * FROM employee_hierarchy ORDER BY level, last_name;
```

---

## 4. Indexes and Fragmentation Concepts {#indexes-fragmentation}

### 4.1 Understanding Indexes

#### 4.1.1 Index Types in PostgreSQL

**B-tree Indexes (Default)**
```sql
-- Most common index type, good for equality and range queries
CREATE INDEX idx_employees_salary ON employees(salary);

-- Supports ordering
SELECT * FROM employees ORDER BY salary; -- Can use index
```

**Hash Indexes**
```sql
-- Good for equality comparisons only
CREATE INDEX idx_employees_dept_hash ON employees USING hash(department_id);

-- Good for: SELECT * FROM employees WHERE department_id = 5;
-- Not good for: SELECT * FROM employees WHERE department_id > 5;
```

**GIN Indexes (Generalized Inverted Index)**
```sql
-- Excellent for array, JSONB, and full-text search
CREATE INDEX idx_employees_skills ON employees USING gin(skills);
CREATE INDEX idx_employees_data ON employees USING gin(employee_data);

-- Example usage
SELECT * FROM employees WHERE skills @> ARRAY['PostgreSQL'];
SELECT * FROM employees WHERE employee_data @> '{"department": "IT"}';
```

**GiST Indexes (Generalized Search Tree)**
```sql
-- Good for geometric data, full-text search
CREATE INDEX idx_locations ON offices USING gist(location);

-- Example with PostGIS
SELECT * FROM offices WHERE ST_DWithin(location, ST_Point(-74, 40.7), 1000);
```

#### 4.1.2 Index Performance Analysis

**Analyzing Index Usage**
```sql
-- Check index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_tup_read DESC;

-- Find unused indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_size_pretty(pg_relation_size(indexrelid::regclass)) DESC;

-- Check index size
SELECT 
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid::regclass)) as index_size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid::regclass) DESC;
```

**Query Execution Plans**
```sql
-- Basic explain
EXPLAIN SELECT * FROM employees WHERE salary > 50000;

-- Detailed execution plan
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM employees WHERE salary > 50000;

-- JSON format for programmatic analysis
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) 
SELECT * FROM employees WHERE salary > 50000;
```

#### 4.1.3 Index Maintenance

**Rebuilding Indexes**
```sql
-- Rebuild single index
REINDEX INDEX idx_employees_salary;

-- Rebuild all indexes on a table
REINDEX TABLE employees;

-- Rebuild all indexes in a database
REINDEX DATABASE company_db;

-- Concurrent reindex (non-blocking)
REINDEX INDEX CONCURRENTLY idx_employees_salary;
```

### 4.2 Fragmentation Concepts

#### 4.2.1 Understanding Fragmentation

PostgreSQL doesn't suffer from the same fragmentation issues as some other databases, but it has similar concepts:

**Bloat**: Dead tuples that haven't been cleaned up
**Page-level fragmentation**: Partially filled pages
**Index bloat**: Unused space in index pages

#### 4.2.2 Monitoring Bloat

**Table Bloat Query**
```sql
SELECT 
    schemaname,
    tablename,
    n_dead_tup,
    n_live_tup,
    ROUND(n_dead_tup::float / NULLIF(n_live_tup + n_dead_tup, 0) * 100, 2) AS dead_tup_percent
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY dead_tup_percent DESC;
```

**Detailed Bloat Analysis**
```sql
-- Extension for detailed bloat analysis
CREATE EXTENSION IF NOT EXISTS pgstattuple;

-- Check table bloat
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(tablename::regclass)) as total_size,
    tuple_count,
    dead_tuple_count,
    free_percent
FROM pgstat_tuple(table_name::regclass);

-- Check index bloat
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size,
    leaf_fragmentation,
    avg_leaf_density
FROM pgstatindex('index_name');
```

#### 4.2.3 Addressing Fragmentation

**VACUUM Operations**
```sql
-- Standard vacuum (removes dead tuples)
VACUUM employees;

-- Verbose vacuum with details
VACUUM VERBOSE employees;

-- Full vacuum (rebuilds table, requires exclusive lock)
VACUUM FULL employees;

-- Analyze statistics
ANALYZE employees;

-- Combined vacuum and analyze
VACUUM ANALYZE employees;
```

**Autovacuum Configuration**
```sql
-- Check autovacuum settings
SELECT name, setting FROM pg_settings WHERE name LIKE 'autovacuum%';

-- Per-table autovacuum settings
ALTER TABLE employees SET (
    autovacuum_vacuum_scale_factor = 0.1,
    autovacuum_analyze_scale_factor = 0.05
);

-- Disable autovacuum for specific table
ALTER TABLE temp_table SET (autovacuum_enabled = false);
```

#### 4.2.4 Preventing Fragmentation

**Best Practices**
```sql
-- Use appropriate data types
CREATE TABLE optimized_employees (
    id INTEGER,                    -- Not BIGINT if not needed
    name VARCHAR(100),             -- Not TEXT if length is known
    active BOOLEAN,                -- Not CHAR(1)
    created_at TIMESTAMP           -- With appropriate precision
);

-- Use FILLFACTOR for frequently updated tables
CREATE TABLE frequently_updated (
    id SERIAL PRIMARY KEY,
    data TEXT
) WITH (fillfactor = 80);

-- Create index with fillfactor
CREATE INDEX idx_name ON table_name (column) WITH (fillfactor = 80);
```

### 4.3 Index Strategy and Best Practices

#### 4.3.1 When to Create Indexes

**Good Candidates for Indexing**
```sql
-- Columns used in WHERE clauses
SELECT * FROM employees WHERE email = 'john@company.com';

-- Columns used in JOIN conditions
SELECT * FROM employees e JOIN departments d ON e.dept_id = d.id;

-- Columns used in ORDER BY
SELECT * FROM employees ORDER BY hire_date;

-- Foreign key columns
ALTER TABLE employees ADD FOREIGN KEY (department_id) REFERENCES departments(id);
```

#### 4.3.2 Multi-column Indexes

**Column Order Matters**
```sql
-- Good: Most selective column first
CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);

-- Can be used for:
-- WHERE department_id = 1
-- WHERE department_id = 1 AND salary > 50000
-- ORDER BY department_id, salary

-- Cannot efficiently use for:
-- WHERE salary > 50000 (without department_id)
```

#### 4.3.3 Partial Indexes

**Indexes with Conditions**
```sql
-- Index only active employees
CREATE INDEX idx_active_employees ON employees(department_id) 
WHERE status = 'active';

-- Index only recent orders
CREATE INDEX idx_recent_orders ON orders(customer_id, order_date)
WHERE order_date >= '2024-01-01';

-- Index only non-null values
CREATE INDEX idx_employees_phone ON employees(phone)
WHERE phone IS NOT NULL;
```

---

## 5. Database Objects - Procedures, Functions, Views {#database-objects}

### 5.1 Functions

#### 5.1.1 PL/pgSQL Functions

**Basic Function Syntax**
```sql
-- Simple function
CREATE OR REPLACE FUNCTION get_employee_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM employees);
END;
$$ LANGUAGE plpgsql;

-- Function with parameters
CREATE OR REPLACE FUNCTION get_department_employee_count(dept_id INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM employees WHERE department_id = dept_id);
END;
$$ LANGUAGE plpgsql;

-- Function with multiple parameters and return type
CREATE OR REPLACE FUNCTION calculate_bonus(
    emp_id INTEGER,
    bonus_rate DECIMAL DEFAULT 0.1
)
RETURNS DECIMAL AS $$
DECLARE
    emp_salary DECIMAL;
    bonus_amount DECIMAL;
BEGIN
    SELECT salary INTO emp_salary FROM employees WHERE id = emp_id;
    
    IF emp_salary IS NULL THEN
        RAISE EXCEPTION 'Employee with ID % not found', emp_id;
    END IF;
    
    bonus_amount := emp_salary * bonus_rate;
    RETURN bonus_amount;
END;
$$ LANGUAGE plpgsql;
```

#### 5.1.2 Advanced Function Features

**Functions with Complex Logic**
```sql
-- Function with conditional logic
CREATE OR REPLACE FUNCTION get_employee_grade(emp_id INTEGER)
RETURNS TEXT AS $$
DECLARE
    emp_salary DECIMAL;
    grade TEXT;
BEGIN
    SELECT salary INTO emp_salary FROM employees WHERE id = emp_id;
    
    IF emp_salary IS NULL THEN
        RETURN 'Not Found';
    END IF;
    
    CASE 
        WHEN emp_salary >= 100000 THEN grade := 'Senior';
        WHEN emp_salary >= 70000 THEN grade := 'Mid-Level';
        WHEN emp_salary >= 40000 THEN grade := 'Junior';
        ELSE grade := 'Entry Level';
    END CASE;
    
    RETURN grade;
END;
$$ LANGUAGE plpgsql;

-- Function returning table
CREATE OR REPLACE FUNCTION get_department_summary()
RETURNS TABLE(
    dept_name TEXT,
    employee_count BIGINT,
    avg_salary DECIMAL,
    total_salary DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.name::TEXT,
        COUNT(e.id),
        AVG(e.salary),
        SUM(e.salary)
    FROM departments d
    LEFT JOIN employees e ON d.id = e.department_id
    GROUP BY d.id, d.name
    ORDER BY d.name;
END;
$$ LANGUAGE plpgsql;
```

**Functions with Exception Handling**
```sql
CREATE OR REPLACE FUNCTION safe_divide(numerator DECIMAL, denominator DECIMAL)
RETURNS DECIMAL AS $$
BEGIN
    IF denominator = 0 THEN
        RAISE EXCEPTION 'Division by zero is not allowed';
    END IF;
    
    RETURN numerator / denominator;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Division by zero attempted, returning NULL';
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

#### 5.1.3 SQL Functions

**Simple SQL Functions**
```sql
-- SQL function (simpler, often faster)
CREATE OR REPLACE FUNCTION get_full_name(first_name TEXT, last_name TEXT)
RETURNS TEXT AS $$
    SELECT first_name || ' ' || last_name;
$$ LANGUAGE sql IMMUTABLE;

-- Function with default parameters
CREATE OR REPLACE FUNCTION format_currency(
    amount DECIMAL,
    currency_symbol TEXT DEFAULT '$'
)
RETURNS TEXT AS $$
    SELECT currency_symbol || amount::TEXT;
$$ LANGUAGE sql IMMUTABLE;
```

### 5.2 Stored Procedures

#### 5.2.1 Basic Procedures (PostgreSQL 11+)

**Creating Procedures**
```sql
-- Simple procedure
CREATE OR REPLACE PROCEDURE update_employee_salary(
    emp_id INTEGER,
    new_salary DECIMAL
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE employees 
    SET salary = new_salary, updated_at = NOW()
    WHERE id = emp_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee with ID % not found', emp_id;
    END IF;
    
    COMMIT;
END;
$$;

-- Procedure with transaction control
CREATE OR REPLACE PROCEDURE process_salary_increases()
LANGUAGE plpgsql AS $$
DECLARE
    emp_record RECORD;
    error_count INTEGER := 0;
BEGIN
    FOR emp_record IN 
        SELECT id, salary FROM employees WHERE status = 'active'
    LOOP
        BEGIN
            UPDATE employees 
            SET salary = salary * 1.05
            WHERE id = emp_record.id;
        EXCEPTION
            WHEN OTHERS THEN
                error_count := error_count + 1;
                RAISE NOTICE 'Error updating employee %: %', emp_record.id, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Processed salary increases with % errors', error_count;
    COMMIT;
END;
$$;
```

#### 5.2.2 Calling Procedures

```sql
-- Call procedure
CALL update_employee_salary(123, 85000);

-- Call procedure in transaction
BEGIN;
CALL process_salary_increases();
-- Transaction is automatically committed by the procedure
```

### 5.3 Views

#### 5.3.1 Simple Views

**Creating Views**
```sql
-- Simple view
CREATE VIEW active_employees AS
SELECT 
    id,
    first_name,
    last_name,
    email,
    hire_date,
    salary
FROM employees
WHERE status = 'active';

-- View with calculated columns
CREATE VIEW employee_summary AS
SELECT 
    id,
    first_name || ' ' || last_name AS full_name,
    email,
    DATE_PART('year', AGE(hire_date)) AS years_employed,
    salary,
    CASE 
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 60000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_grade
FROM employees;
```

#### 5.3.2 Complex Views with Joins

**Multi-table Views**
```sql
-- View joining multiple tables
CREATE VIEW employee_details AS
SELECT 
    e.id,
    e.first_name,
    e.last_name,
    e.email,
    e.salary,
    d.name AS department_name,
    d.budget AS department_budget,
    m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
LEFT JOIN employees m ON e.manager_id = m.id;

-- Aggregated view
CREATE VIEW department_statistics AS
SELECT 
    d.id,
    d.name AS department_name,
    COUNT(e.id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    SUM(e.salary) AS total_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name;
```

#### 5.3.3 Materialized Views

**Creating Materialized Views**
```sql
-- Materialized view (stores results physically)
CREATE MATERIALIZED VIEW monthly_sales_summary AS
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Create index on materialized view
CREATE INDEX idx_monthly_sales_month ON monthly_sales_summary(month);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW monthly_sales_summary;

-- Concurrent refresh (non-blocking)
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_sales_summary;
```

#### 5.3.4 Updatable Views

**Views that Support DML Operations**
```sql
-- Simple updatable view
CREATE VIEW high_earners AS
SELECT 
    id,
    first_name,
    last_name,
    email,
    salary
FROM employees
WHERE salary > 80000;

-- Insert through view
INSERT INTO high_earners (first_name, last_name, email, salary)
VALUES ('Alice', 'Johnson', 'alice.j@company.com', 95000);

-- Update through view
UPDATE high_earners SET salary = salary * 1.1 WHERE id = 123;

-- View with check option
CREATE VIEW senior_employees AS
SELECT 
    id,
    first_name,
    last_name,
    salary,
    years_experience
FROM employees
WHERE years_experience >= 5
WITH CHECK OPTION;
```

### 5.4 Triggers

#### 5.4.1 Basic Triggers

**Audit Trigger Example**
```sql
-- Create audit table
CREATE TABLE employee_audit (
    audit_id SERIAL PRIMARY KEY,
    employee_id INTEGER,
    action VARCHAR(10),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT NOW()
);

-- Create trigger function
CREATE OR REPLACE FUNCTION audit_employee_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO employee_audit (employee_id, action, old_values, changed_by)
        VALUES (OLD.id, 'DELETE', row_to_json(OLD), current_user);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO employee_audit (employee_id, action, old_values, new_values, changed_by)
        VALUES (NEW.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO employee_audit (employee_id, action, new_values, changed_by)
        VALUES (NEW.id, 'INSERT', row_to_json(NEW), current_user);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trigger_audit_employees
    AFTER INSERT OR UPDATE OR DELETE ON employees
    FOR EACH ROW EXECUTE FUNCTION audit_employee_changes();
```

#### 5.4.2 Advanced Trigger Examples

**Validation Trigger**
```sql
-- Email validation trigger
CREATE OR REPLACE FUNCTION validate_employee_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_email
    BEFORE INSERT OR UPDATE ON employees
    FOR EACH ROW EXECUTE FUNCTION validate_employee_email();
```

### 5.5 User-Defined Data Types

#### 5.5.1 Composite Types

**Creating Custom Types**
```sql
-- Create composite type
CREATE TYPE address_type AS (
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50)
);

-- Use in table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    billing_address address_type,
    shipping_address address_type
);

-- Insert data
INSERT INTO customers (name, billing_address, shipping_address)
VALUES (
    'John Doe',
    ROW('123 Main St', 'Anytown', 'CA', '12345', 'USA'),
    ROW('456 Oak Ave', 'Another City', 'CA', '67890', 'USA')
);
```

#### 5.5.2 Enumerated Types

**Creating Enums**
```sql
-- Create enum type
CREATE TYPE status_type AS ENUM ('active', 'inactive', 'pending', 'suspended');

-- Use in table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    status status_type DEFAULT 'pending'
);

-- Add value to enum
ALTER TYPE status_type ADD VALUE 'terminated';
```

---

## 6. Practical Labs and Exercises {#practical-labs}

### Lab 1: Working with PostgreSQL - Database Setup

**Objective**: Set up a complete database environment with users, schemas, and basic tables.

**Tasks**:
1. Create a new database called `company_db`
2. Create schemas for different departments: `hr`, `finance`, `sales`
3. Create users with appropriate permissions
4. Create basic tables in each schema

**Solution**:
```sql
-- Create database
CREATE DATABASE company_db;

-- Connect to the database
\c company_db

-- Create schemas
CREATE SCHEMA hr;
CREATE SCHEMA finance;
CREATE SCHEMA sales;

-- Create users
CREATE USER hr_admin WITH PASSWORD 'hr_pass123';
CREATE USER finance_admin WITH PASSWORD 'fin_pass123';
CREATE USER sales_admin WITH PASSWORD 'sales_pass123';

-- Grant schema permissions
GRANT ALL ON SCHEMA hr TO hr_admin;
GRANT ALL ON SCHEMA finance TO finance_admin;
GRANT ALL ON SCHEMA sales TO sales_admin;

-- Create tables in HR schema
CREATE TABLE hr.employees (
    id SERIAL PRIMARY KEY,
    employee_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE DEFAULT CURRENT_DATE,
    job_title VARCHAR(100),
    salary DECIMAL(10,2),
    manager_id INTEGER REFERENCES hr.employees(id),
    department VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active'
);

-- Grant table permissions
GRANT ALL ON hr.employees TO hr_admin;
GRANT ALL ON SEQUENCE hr.employees_id_seq TO hr_admin;
```

### Lab 2: Replication Setup

**Objective**: Set up streaming replication between two PostgreSQL instances.

**Tasks**:
1. Configure primary server for replication
2. Set up standby server
3. Test replication lag monitoring
4. Perform failover scenario

**Primary Server Setup**:
```bash
# Edit postgresql.conf
wal_level = replica
max_wal_senders = 3
checkpoint_segments = 8
wal_keep_segments = 8
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/archive/%f'
```

**Standby Server Setup**:
```bash
# Create base backup
pg_basebackup -h primary_ip -D /var/lib/postgresql/data -U replicator -P -W -R

# Start standby server
systemctl start postgresql
```

### Lab 3: Advanced DDL/DML Operations

**Objective**: Create a complex database schema with relationships and constraints.

**Tasks**:
1. Design and implement an e-commerce database schema
2. Create appropriate indexes
3. Write complex queries using CTEs and window functions
4. Implement data modification scenarios

**Schema Creation**:
```sql
-- Categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    category_id INTEGER REFERENCES categories(id),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_categories_parent ON categories(parent_id);

-- Complex query with CTE
WITH category_sales AS (
    SELECT 
        c.name AS category_name,
        SUM(oi.quantity * oi.price) AS total_sales,
        COUNT(DISTINCT o.id) AS order_count
    FROM categories c
    JOIN products p ON c.id = p.category_id
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY c.id, c.name
)
SELECT 
    category_name,
    total_sales,
    order_count,
    RANK() OVER (ORDER BY total_sales DESC) as sales_rank
FROM category_sales
ORDER BY total_sales DESC;
```

### Lab 4: Index Optimization and Performance

**Objective**: Analyze and optimize database performance using indexes.

**Tasks**:
1. Create a large dataset for testing
2. Identify slow queries
3. Create appropriate indexes
4. Monitor index usage and bloat

**Performance Testing**:
```sql
-- Create test data
INSERT INTO employees (first_name, last_name, email, salary, department)
SELECT 
    'User' || generate_series,
    'Test' || generate_series,
    'user' || generate_series || '@company.com',
    random() * 50000 + 30000,
    CASE (random() * 4)::INTEGER
        WHEN 0 THEN 'HR'
        WHEN 1 THEN 'Engineering'
        WHEN 2 THEN 'Sales'
        ELSE 'Marketing'
    END
FROM generate_series(1, 100000);

-- Analyze slow query
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM employees 
WHERE salary BETWEEN 50000 AND 70000 
AND department = 'Engineering'
ORDER BY hire_date;

-- Create composite index
CREATE INDEX idx_employees_dept_salary_date 
ON employees(department, salary, hire_date);

-- Check index usage
SELECT 
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE tablename = 'employees';
```

### Lab 5: Database Objects Implementation

**Objective**: Create and use various database objects including functions, procedures, and triggers.

**Tasks**:
1. Create functions for business logic
2. Implement stored procedures for data processing
3. Set up audit triggers
4. Create materialized views for reporting

**Implementation**:
```sql
-- Business logic function
CREATE OR REPLACE FUNCTION calculate_employee_bonus(
    emp_id INTEGER,
    performance_rating INTEGER
)
RETURNS DECIMAL AS $$
DECLARE
    base_salary DECIMAL;
    bonus_percentage DECIMAL;
    bonus_amount DECIMAL;
BEGIN
    -- Get employee salary
    SELECT salary INTO base_salary FROM employees WHERE id = emp_id;
    
    IF base_salary IS NULL THEN
        RAISE EXCEPTION 'Employee not found';
    END IF;
    
    -- Calculate bonus percentage based on rating
    bonus_percentage := CASE performance_rating
        WHEN 5 THEN 0.20  -- 20% for excellent
        WHEN 4 THEN 0.15  -- 15% for very good
        WHEN 3 THEN 0.10  -- 10% for good
        WHEN 2 THEN 0.05  -- 5% for satisfactory
        ELSE 0.00         -- 0% for below expectations
    END;
    
    bonus_amount := base_salary * bonus_percentage;
    RETURN bonus_amount;
END;
$$ LANGUAGE plpgsql;

-- Data processing procedure
CREATE OR REPLACE PROCEDURE process_monthly_bonuses()
LANGUAGE plpgsql AS $$
DECLARE
    emp_record RECORD;
    bonus_amount DECIMAL;
BEGIN
    FOR emp_record IN 
        SELECT id, first_name, last_name, performance_rating 
        FROM employees 
        WHERE status = 'active' AND performance_rating IS NOT NULL
    LOOP
        bonus_amount := calculate_employee_bonus(emp_record.id, emp_record.performance_rating);
        
        INSERT INTO bonuses (employee_id, bonus_amount, bonus_date)
        VALUES (emp_record.id, bonus_amount, CURRENT_DATE);
        
        RAISE NOTICE 'Processed bonus for %: $%', 
            emp_record.first_name || ' ' || emp_record.last_name, 
            bonus_amount;
    END LOOP;
    
    COMMIT;
END;
$$;

-- Materialized view for reporting
CREATE MATERIALIZED VIEW employee_performance_summary AS
SELECT 
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    AVG(performance_rating) AS avg_performance,
    SUM(CASE WHEN performance_rating >= 4 THEN 1 ELSE 0 END) AS high_performers
FROM employees
WHERE status = 'active'
GROUP BY department;

-- Refresh the materialized view
REFRESH MATERIALIZED VIEW employee_performance_summary;
```

---

## Summary and Best Practices

### Key Takeaways

1. **PostgreSQL Operations**: Master basic and advanced operations, user management, and server configuration
2. **High Availability**: Understand replication concepts and implement robust standby solutions
3. **DDL/DML Mastery**: Create efficient database schemas and write optimized data manipulation queries
4. **Performance Optimization**: Use indexes strategically and monitor for fragmentation and bloat
5. **Database Objects**: Leverage functions, procedures, views, and triggers for business logic and automation

### Performance Best Practices

1. **Indexing Strategy**:
   - Create indexes on frequently queried columns
   - Use composite indexes for multi-column queries
   - Monitor and remove unused indexes
   - Consider partial indexes for filtered data

2. **Query Optimization**:
   - Use EXPLAIN ANALYZE to understand query execution
   - Avoid SELECT * in production code
   - Use appropriate JOIN types
   - Leverage CTEs for complex logic

3. **Maintenance**:
   - Configure appropriate autovacuum settings
   - Monitor database bloat regularly
   - Keep statistics up to date with ANALYZE
   - Plan for regular index maintenance

4. **Development Guidelines**:
   - Use appropriate data types
   - Implement proper constraints
   - Design normalized schemas
   - Document database objects with comments

This comprehensive guide provides the foundation for working effectively with PostgreSQL in production environments, covering essential concepts from basic operations to advanced database administration and development practices.