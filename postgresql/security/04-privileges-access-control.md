# Module 3: Privileges and Access Control

## Learning Objectives
- Understand PostgreSQL privilege system
- Grant and revoke permissions on database objects
- Implement schema-based access control
- Use default privileges and role-based permissions
- Troubleshoot permission issues

## 3.1 PostgreSQL Privilege System Overview

### Types of Privileges
PostgreSQL implements a comprehensive privilege system with different types of permissions:

1. **Database Privileges**
   - CONNECT - Connect to database
   - CREATE - Create schemas
   - TEMPORARY/TEMP - Create temporary objects

2. **Schema Privileges**
   - USAGE - Access schema
   - CREATE - Create objects in schema

3. **Table/View Privileges**
   - SELECT - Read data
   - INSERT - Add new rows
   - UPDATE - Modify existing rows
   - DELETE - Remove rows
   - TRUNCATE - Empty table quickly
   - REFERENCES - Create foreign keys
   - TRIGGER - Create triggers

4. **Column Privileges**
   - SELECT - Read specific columns
   - INSERT - Insert into specific columns
   - UPDATE - Update specific columns
   - REFERENCES - Reference specific columns

5. **Function/Procedure Privileges**
   - EXECUTE - Execute function/procedure

6. **Sequence Privileges**
   - USAGE - Use sequence (nextval)
   - SELECT - Read sequence value
   - UPDATE - Modify sequence value

## 3.2 Granting and Revoking Privileges

### Basic Syntax

```sql
-- Grant privileges
GRANT privilege_type ON object TO role_name;

-- Revoke privileges
REVOKE privilege_type ON object FROM role_name;

-- Grant with admin option
GRANT privilege_type ON object TO role_name WITH GRANT OPTION;
```

### Database-Level Privileges

```sql
-- Grant database connection
GRANT CONNECT ON DATABASE mydb TO username;

-- Grant schema creation
GRANT CREATE ON DATABASE mydb TO username;

-- Grant temporary object creation
GRANT TEMPORARY ON DATABASE mydb TO username;

-- Grant all database privileges
GRANT ALL PRIVILEGES ON DATABASE mydb TO username;

-- Revoke database privileges
REVOKE CONNECT ON DATABASE mydb FROM username;
```

### Schema-Level Privileges

```sql
-- Grant schema usage (required to access objects)
GRANT USAGE ON SCHEMA public TO username;

-- Grant object creation in schema
GRANT CREATE ON SCHEMA public TO username;

-- Grant all schema privileges
GRANT ALL ON SCHEMA public TO username;

-- Grant on multiple schemas
GRANT USAGE ON SCHEMA sales, finance, hr TO username;
```

### Table-Level Privileges

```sql
-- Grant SELECT on table
GRANT SELECT ON TABLE employees TO username;

-- Grant multiple privileges
GRANT SELECT, INSERT, UPDATE ON TABLE employees TO username;

-- Grant all table privileges
GRANT ALL PRIVILEGES ON TABLE employees TO username;

-- Grant on all tables in schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO username;

-- Grant with grant option
GRANT SELECT ON TABLE employees TO username WITH GRANT OPTION;
```

### Column-Level Privileges

```sql
-- Grant SELECT on specific columns
GRANT SELECT (id, name, email) ON TABLE employees TO username;

-- Grant UPDATE on specific columns
GRANT UPDATE (salary, department) ON TABLE employees TO hr_manager;

-- Grant INSERT on specific columns
GRANT INSERT (name, email, department) ON TABLE employees TO recruiter;
```

### Function and Sequence Privileges

```sql
-- Grant function execution
GRANT EXECUTE ON FUNCTION calculate_bonus(integer) TO username;

-- Grant sequence usage
GRANT USAGE ON SEQUENCE employee_id_seq TO username;
GRANT SELECT ON SEQUENCE employee_id_seq TO username;

-- Grant on all functions in schema
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO username;
```

## 3.3 Default Privileges

### Setting Default Privileges
Default privileges automatically apply to new objects created by specific roles.

```sql
-- Set default privileges for tables created by current user
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT ON TABLES TO readonly_role;

-- Set default privileges for tables created by specific user
ALTER DEFAULT PRIVILEGES FOR ROLE developer IN SCHEMA public 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_role;

-- Set default privileges for functions
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT EXECUTE ON FUNCTIONS TO app_role;

-- Set default privileges for sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT USAGE ON SEQUENCES TO app_role;
```

### Viewing Default Privileges

```sql
-- View default privileges
SELECT 
  defaclrole::regrole AS grantor,
  defaclnamespace::regnamespace AS schema,
  defaclobjtype AS object_type,
  defaclacl AS privileges
FROM pg_default_acl;
```

## 3.4 Schema-Based Access Control

### Creating Secure Schema Structure

```sql
-- Create schemas for different departments
CREATE SCHEMA sales;
CREATE SCHEMA finance;
CREATE SCHEMA hr;
CREATE SCHEMA public_data;

-- Create roles for each department
CREATE ROLE sales_team;
CREATE ROLE finance_team;
CREATE ROLE hr_team;
CREATE ROLE general_users;

-- Grant schema access
GRANT USAGE ON SCHEMA sales TO sales_team;
GRANT USAGE ON SCHEMA finance TO finance_team;
GRANT USAGE ON SCHEMA hr TO hr_team;
GRANT USAGE ON SCHEMA public_data TO general_users;

-- Grant creation privileges within schemas
GRANT CREATE ON SCHEMA sales TO sales_team;
GRANT CREATE ON SCHEMA finance TO finance_team;
GRANT CREATE ON SCHEMA hr TO hr_team;
```

### Cross-Schema Access

```sql
-- Allow finance team to read sales data
GRANT USAGE ON SCHEMA sales TO finance_team;
GRANT SELECT ON ALL TABLES IN SCHEMA sales TO finance_team;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA sales 
GRANT SELECT ON TABLES TO finance_team;

-- Allow reporting team to read from multiple schemas
CREATE ROLE reporting_team;
GRANT USAGE ON SCHEMA sales, finance, hr TO reporting_team;
GRANT SELECT ON ALL TABLES IN SCHEMA sales, finance, hr TO reporting_team;
```

### Search Path Management

```sql
-- Set search path for users
ALTER ROLE sales_user SET search_path = sales, public_data, public;
ALTER ROLE finance_user SET search_path = finance, public_data, public;

-- View current search path
SHOW search_path;

-- Temporarily change search path
SET search_path = hr, public;
```

## 3.5 Row Level Security (RLS)

### Enabling Row Level Security

```sql
-- Create a table with RLS
CREATE TABLE employee_records (
  id SERIAL PRIMARY KEY,
  employee_id INTEGER,
  name VARCHAR(100),
  department VARCHAR(50),
  salary DECIMAL(10,2),
  manager_id INTEGER
);

-- Enable RLS
ALTER TABLE employee_records ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY employee_self_access ON employee_records 
FOR ALL TO general_users 
USING (employee_id = current_setting('app.current_employee_id')::INTEGER);

CREATE POLICY manager_access ON employee_records 
FOR ALL TO managers 
USING (manager_id = current_setting('app.current_employee_id')::INTEGER);

CREATE POLICY hr_full_access ON employee_records 
FOR ALL TO hr_team 
USING (true);
```

### Policy Examples

```sql
-- Department-based access
CREATE POLICY department_access ON employee_records 
FOR SELECT TO general_users 
USING (department = current_setting('app.user_department'));

-- Time-based access
CREATE POLICY business_hours_access ON sensitive_data 
FOR ALL TO business_users 
USING (EXTRACT(hour FROM now()) BETWEEN 9 AND 17);

-- Conditional access based on role
CREATE POLICY conditional_access ON financial_data 
FOR SELECT TO finance_users 
USING (
  CASE 
    WHEN current_setting('app.user_level') = 'senior' THEN true
    WHEN current_setting('app.user_level') = 'junior' AND amount < 10000 THEN true
    ELSE false
  END
);
```

## 3.6 Practical Lab Exercises

### Lab 1: Basic Privilege Management

```sql
-- Exercise 1: Set up basic database security
-- 1. Create test database and schemas
CREATE DATABASE privilege_lab;
\c privilege_lab;

CREATE SCHEMA app_data;
CREATE SCHEMA reporting;
CREATE SCHEMA admin;

-- 2. Create roles
CREATE ROLE app_readonly;
CREATE ROLE app_readwrite;
CREATE ROLE app_admin;
CREATE ROLE report_user;

-- 3. Create test tables
CREATE TABLE app_data.customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE app_data.orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES app_data.customers(id),
  amount DECIMAL(10,2),
  order_date DATE DEFAULT CURRENT_DATE
);

-- 4. Grant appropriate privileges
-- Read-only access to app data
GRANT USAGE ON SCHEMA app_data TO app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA app_data TO app_readonly;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA app_data TO app_readonly;

-- Read-write access to app data
GRANT USAGE ON SCHEMA app_data TO app_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app_data TO app_readwrite;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA app_data TO app_readwrite;

-- Admin access to all schemas
GRANT ALL PRIVILEGES ON SCHEMA app_data, reporting, admin TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app_data, reporting, admin TO app_admin;

-- Reporting access
GRANT USAGE ON SCHEMA app_data, reporting TO report_user;
GRANT SELECT ON ALL TABLES IN SCHEMA app_data TO report_user;
GRANT ALL PRIVILEGES ON SCHEMA reporting TO report_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA reporting TO report_user;
```

### Lab 2: Column-Level Security

```sql
-- Exercise 2: Implement column-level security
-- 1. Create sensitive data table
CREATE TABLE app_data.employee_data (
  id SERIAL PRIMARY KEY,
  employee_id VARCHAR(20),
  name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20),
  salary DECIMAL(10,2),
  ssn VARCHAR(11),
  department VARCHAR(50),
  hire_date DATE
);

-- 2. Create specialized roles
CREATE ROLE hr_manager;
CREATE ROLE department_manager;
CREATE ROLE general_employee;

-- 3. Grant column-specific privileges
-- HR managers can see all data
GRANT ALL PRIVILEGES ON app_data.employee_data TO hr_manager;

-- Department managers can see most data but not salary/SSN
GRANT SELECT (id, employee_id, name, email, phone, department, hire_date) 
ON app_data.employee_data TO department_manager;
GRANT UPDATE (email, phone, department) 
ON app_data.employee_data TO department_manager;

-- General employees can only see basic contact information
GRANT SELECT (name, email, phone, department) 
ON app_data.employee_data TO general_employee;
```

### Lab 3: Row Level Security Implementation

```sql
-- Exercise 3: Implement Row Level Security
-- 1. Create multi-tenant table
CREATE TABLE app_data.documents (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200),
  content TEXT,
  owner_id INTEGER,
  department VARCHAR(50),
  confidentiality_level VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE app_data.documents ENABLE ROW LEVEL SECURITY;

-- 2. Create policies
-- Users can only see their own documents
CREATE POLICY own_documents ON app_data.documents 
FOR ALL TO general_employee 
USING (owner_id = current_setting('app.current_user_id')::INTEGER);

-- Department managers can see all documents in their department
CREATE POLICY department_documents ON app_data.documents 
FOR ALL TO department_manager 
USING (department = current_setting('app.user_department'));

-- HR can see all non-confidential documents
CREATE POLICY hr_access ON app_data.documents 
FOR SELECT TO hr_manager 
USING (confidentiality_level != 'TOP_SECRET');

-- Admins can see everything
CREATE POLICY admin_access ON app_data.documents 
FOR ALL TO app_admin 
USING (true);

-- 3. Test the policies
-- Set user context
SET app.current_user_id = '123';
SET app.user_department = 'FINANCE';

-- Insert test data
INSERT INTO app_data.documents (title, content, owner_id, department, confidentiality_level)
VALUES 
  ('Budget Report', 'Q4 financial data...', 123, 'FINANCE', 'CONFIDENTIAL'),
  ('Team Meeting Notes', 'Weekly sync notes...', 124, 'FINANCE', 'PUBLIC'),
  ('Secret Project', 'Top secret information...', 125, 'FINANCE', 'TOP_SECRET');
```

## 3.7 Viewing and Analyzing Privileges

### System Views for Privileges

```sql
-- View table privileges
SELECT 
  schemaname,
  tablename,
  grantor,
  grantee,
  privilege_type,
  is_grantable
FROM information_schema.table_privileges
WHERE grantee != 'PUBLIC'
ORDER BY schemaname, tablename, grantee;

-- View column privileges
SELECT 
  table_schema,
  table_name,
  column_name,
  grantor,
  grantee,
  privilege_type,
  is_grantable
FROM information_schema.column_privileges
ORDER BY table_schema, table_name, column_name;

-- View routine (function) privileges
SELECT 
  routine_schema,
  routine_name,
  grantor,
  grantee,
  privilege_type,
  is_grantable
FROM information_schema.routine_privileges
ORDER BY routine_schema, routine_name;
```

### Using PostgreSQL Specific Views

```sql
-- View ACL (Access Control List) for tables
SELECT 
  schemaname,
  tablename,
  tableowner,
  tablespace,
  hasindexes,
  hasrules,
  hastriggers,
  rowsecurity
FROM pg_tables
WHERE schemaname NOT IN ('information_schema', 'pg_catalog');

-- Check if user has specific privileges
SELECT 
  has_table_privilege('username', 'schema.table', 'SELECT') as can_select,
  has_table_privilege('username', 'schema.table', 'INSERT') as can_insert,
  has_table_privilege('username', 'schema.table', 'UPDATE') as can_update,
  has_table_privilege('username', 'schema.table', 'DELETE') as can_delete;

-- Check schema privileges
SELECT 
  has_schema_privilege('username', 'schema_name', 'USAGE') as can_use,
  has_schema_privilege('username', 'schema_name', 'CREATE') as can_create;
```

### Privilege Troubleshooting

```sql
-- Find who has access to a specific table
SELECT 
  r.rolname,
  array_agg(privilege_type) as privileges
FROM information_schema.table_privileges tp
JOIN pg_roles r ON tp.grantee = r.rolname
WHERE table_schema = 'app_data' AND table_name = 'customers'
GROUP BY r.rolname;

-- Find all privileges for a specific user
SELECT 
  table_schema,
  table_name,
  privilege_type,
  is_grantable
FROM information_schema.table_privileges
WHERE grantee = 'specific_username'
ORDER BY table_schema, table_name;

-- Check effective privileges (including inherited from roles)
SELECT 
  schemaname,
  tablename,
  usename,
  has_table_privilege(usename, schemaname||'.'||tablename, 'SELECT') as select_priv,
  has_table_privilege(usename, schemaname||'.'||tablename, 'INSERT') as insert_priv,
  has_table_privilege(usename, schemaname||'.'||tablename, 'UPDATE') as update_priv,
  has_table_privilege(usename, schemaname||'.'||tablename, 'DELETE') as delete_priv
FROM pg_tables, pg_user
WHERE schemaname = 'app_data'
  AND usename = 'test_user';
```

## 3.8 Best Practices

### 1. Principle of Least Privilege
- Grant minimum necessary permissions
- Use role-based access control
- Regular permission audits
- Remove unused privileges

### 2. Schema Organization
- Use schemas to organize access levels
- Implement consistent naming conventions
- Document schema purposes and access rules

### 3. Default Privileges
- Set appropriate default privileges
- Use for automated object creation
- Review and update regularly

### 4. Monitoring and Auditing
- Log privilege changes
- Monitor privilege escalation
- Regular access reviews
- Automated compliance checking

## Summary
In this module, we covered:
- PostgreSQL privilege system architecture
- Granting and revoking privileges at various levels
- Schema-based access control strategies
- Default privileges for automated security
- Row Level Security implementation
- Practical exercises for hands-on experience
- Privilege monitoring and troubleshooting
- Security best practices

## Next Module
[Module 4: Database Auditing](05-database-auditing.md)
