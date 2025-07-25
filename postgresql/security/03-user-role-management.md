# Module 2: User and Role Management

## Learning Objectives
- Understand PostgreSQL user and role concepts
- Create and manage database users and roles
- Implement role hierarchies and inheritance
- Manage group roles and memberships
- Best practices for user management

## 2.1 Understanding Users and Roles

### Concepts
In PostgreSQL, **users** and **roles** are essentially the same thing. A role can:
- Own database objects
- Have privileges granted to it
- Be a member of other roles
- Have other roles as members (group role)

### Role Attributes
- **LOGIN** - Can connect to database
- **SUPERUSER** - Bypass all permission checks
- **CREATEDB** - Can create databases
- **CREATEROLE** - Can create other roles
- **REPLICATION** - Can initiate replication
- **PASSWORD** - Has a password for authentication

## 2.2 Creating and Managing Roles

### Basic Role Creation

```sql
-- Create a basic role
CREATE ROLE role_name;

-- Create a role with login capability (user)
CREATE ROLE username WITH LOGIN;

-- Create user with password
CREATE USER username WITH PASSWORD 'secure_password';

-- Create role with multiple attributes
CREATE ROLE admin_user WITH 
  LOGIN 
  CREATEDB 
  CREATEROLE 
  PASSWORD 'admin_password';
```

### Role Modification

```sql
-- Modify role attributes
ALTER ROLE username WITH PASSWORD 'new_password';
ALTER ROLE username WITH CREATEDB;
ALTER ROLE username WITH NOCREATEDB;

-- Rename role
ALTER ROLE old_name RENAME TO new_name;

-- Set role parameters
ALTER ROLE username SET search_path = public, app_schema;
ALTER ROLE username SET work_mem = '256MB';
```

### Role Deletion

```sql
-- Drop role (must not own objects or have privileges)
DROP ROLE username;

-- Drop role and reassign objects
REASSIGN OWNED BY old_user TO new_user;
DROP OWNED BY old_user;
DROP ROLE old_user;
```

## 2.3 Role Hierarchies and Inheritance

### Group Roles
Group roles are roles that contain other roles as members.

```sql
-- Create group roles
CREATE ROLE developers;
CREATE ROLE managers;
CREATE ROLE hr_team;

-- Create individual user roles
CREATE ROLE john_doe WITH LOGIN PASSWORD 'john_pass';
CREATE ROLE jane_smith WITH LOGIN PASSWORD 'jane_pass';
CREATE ROLE bob_wilson WITH LOGIN PASSWORD 'bob_pass';

-- Grant group membership
GRANT developers TO john_doe;
GRANT developers TO jane_smith;
GRANT managers TO jane_smith;
GRANT hr_team TO bob_wilson;
```

### Role Inheritance

```sql
-- By default, roles inherit privileges from their groups
CREATE ROLE app_user WITH LOGIN INHERIT PASSWORD 'app_pass';
GRANT developers TO app_user;

-- Disable inheritance
CREATE ROLE special_user WITH LOGIN NOINHERIT PASSWORD 'special_pass';
GRANT developers TO special_user;

-- To use group privileges without inheritance
SET ROLE developers;  -- Switch to group role
RESET ROLE;          -- Switch back to original role
```

### Viewing Role Memberships

```sql
-- View role memberships
SELECT 
  r.rolname as role_name,
  m.rolname as member_of
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.member
JOIN pg_roles m ON am.roleid = m.oid
ORDER BY r.rolname;

-- View role hierarchy
\du+  -- In psql
```

## 2.4 Advanced Role Management

### Role-Based Access Control (RBAC) Design

```sql
-- 1. Create functional roles
CREATE ROLE app_read_only;
CREATE ROLE app_read_write;
CREATE ROLE app_admin;

-- 2. Create department roles
CREATE ROLE sales_dept;
CREATE ROLE finance_dept;
CREATE ROLE hr_dept;

-- 3. Create specific user roles
CREATE ROLE sales_analyst WITH LOGIN PASSWORD 'analyst_pass';
CREATE ROLE finance_manager WITH LOGIN PASSWORD 'manager_pass';
CREATE ROLE hr_coordinator WITH LOGIN PASSWORD 'hr_pass';

-- 4. Build role hierarchy
-- Sales analyst gets read-only access to sales data
GRANT app_read_only TO sales_dept;
GRANT sales_dept TO sales_analyst;

-- Finance manager gets read-write access
GRANT app_read_write TO finance_dept;
GRANT finance_dept TO finance_manager;

-- HR coordinator gets admin access to HR systems
GRANT app_admin TO hr_dept;
GRANT hr_dept TO hr_coordinator;
```

### Service Account Management

```sql
-- Create service accounts for applications
CREATE ROLE app_backend WITH 
  LOGIN 
  CONNECTION LIMIT 50
  PASSWORD 'backend_service_pass';

CREATE ROLE app_reporting WITH 
  LOGIN 
  CONNECTION LIMIT 10
  PASSWORD 'reporting_service_pass';

-- Create read-only replica user
CREATE ROLE replica_user WITH 
  LOGIN 
  REPLICATION 
  PASSWORD 'replica_pass';
```

## 2.5 Password Management

### Password Policies

```sql
-- Set password encryption method globally
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
SELECT pg_reload_conf();

-- Create user with strong password
CREATE USER secure_user WITH 
  LOGIN 
  PASSWORD 'MyStr0ng!P@ssw0rd2024'
  VALID UNTIL '2024-12-31';

-- Set password expiration
ALTER ROLE username VALID UNTIL '2024-06-30';

-- Force password change on next login (using custom function)
CREATE OR REPLACE FUNCTION force_password_change()
RETURNS event_trigger AS $$
BEGIN
  -- Custom logic for password expiration
END;
$$ LANGUAGE plpgsql;
```

### Connection Limits

```sql
-- Set connection limits
ALTER ROLE username CONNECTION LIMIT 5;

-- View current connections
SELECT 
  usename,
  count(*) as connection_count
FROM pg_stat_activity 
WHERE state = 'active'
GROUP BY usename;
```

## 2.6 Practical Lab Exercises

### Lab 1: Basic Role Management

```sql
-- Exercise 1: Create basic roles and users
-- 1. Create a database for testing
CREATE DATABASE role_test_db;
\c role_test_db;

-- 2. Create group roles
CREATE ROLE readonly_group;
CREATE ROLE readwrite_group;
CREATE ROLE admin_group;

-- 3. Create users
CREATE USER alice WITH LOGIN PASSWORD 'alice123';
CREATE USER bob WITH LOGIN PASSWORD 'bob123';
CREATE USER charlie WITH LOGIN PASSWORD 'charlie123';

-- 4. Assign users to groups
GRANT readonly_group TO alice;
GRANT readwrite_group TO bob;
GRANT admin_group TO charlie;

-- 5. Verify assignments
SELECT 
  r.rolname as role,
  m.rolname as member
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.roleid
JOIN pg_roles m ON am.member = m.oid
WHERE r.rolname IN ('readonly_group', 'readwrite_group', 'admin_group');
```

### Lab 2: Complex Role Hierarchy

```sql
-- Exercise 2: Create a complex organizational structure
-- Department roles
CREATE ROLE engineering_dept;
CREATE ROLE sales_dept;
CREATE ROLE finance_dept;

-- Function-based roles
CREATE ROLE junior_developer;
CREATE ROLE senior_developer;
CREATE ROLE team_lead;
CREATE ROLE sales_rep;
CREATE ROLE sales_manager;
CREATE ROLE accountant;
CREATE ROLE finance_manager;

-- Build hierarchy
GRANT junior_developer TO engineering_dept;
GRANT senior_developer TO engineering_dept;
GRANT team_lead TO engineering_dept;

GRANT sales_rep TO sales_dept;
GRANT sales_manager TO sales_dept;

GRANT accountant TO finance_dept;
GRANT finance_manager TO finance_dept;

-- Create actual users
CREATE USER john_dev WITH LOGIN PASSWORD 'john123';
CREATE USER mary_lead WITH LOGIN PASSWORD 'mary123';
CREATE USER tom_sales WITH LOGIN PASSWORD 'tom123';
CREATE USER lisa_finance WITH LOGIN PASSWORD 'lisa123';

-- Assign users to functional roles
GRANT junior_developer TO john_dev;
GRANT team_lead TO mary_lead;
GRANT sales_manager TO tom_sales;
GRANT finance_manager TO lisa_finance;
```

### Lab 3: Service Account Setup

```sql
-- Exercise 3: Create service accounts for different applications
-- Web application backend
CREATE ROLE webapp_backend WITH 
  LOGIN 
  CONNECTION LIMIT 25
  PASSWORD 'webapp_secure_2024';

-- Reporting service (read-only)
CREATE ROLE reporting_service WITH 
  LOGIN 
  CONNECTION LIMIT 5
  PASSWORD 'reporting_secure_2024';

-- ETL process
CREATE ROLE etl_process WITH 
  LOGIN 
  CONNECTION LIMIT 3
  PASSWORD 'etl_secure_2024';

-- Monitoring service
CREATE ROLE monitoring_service WITH 
  LOGIN 
  CONNECTION LIMIT 2
  PASSWORD 'monitor_secure_2024';

-- Create functional groups for services
CREATE ROLE app_services;
CREATE ROLE data_services;

GRANT app_services TO webapp_backend;
GRANT data_services TO reporting_service;
GRANT data_services TO etl_process;
GRANT app_services TO monitoring_service;
```

## 2.7 Monitoring and Auditing Roles

### Viewing Role Information

```sql
-- List all roles and their attributes
SELECT 
  rolname,
  rolsuper,
  rolinherit,
  rolcreaterole,
  rolcreatedb,
  rolcanlogin,
  rolconnlimit,
  rolvaliduntil
FROM pg_roles
ORDER BY rolname;

-- View role memberships
SELECT 
  r.rolname AS role_name,
  r.rolcanlogin AS can_login,
  m.rolname AS member_of,
  am.admin_option
FROM pg_roles r
LEFT JOIN pg_auth_members am ON r.oid = am.member
LEFT JOIN pg_roles m ON am.roleid = m.oid
ORDER BY r.rolname;

-- Check current role and inherited roles
SELECT current_user, session_user;
SELECT * FROM pg_roles WHERE pg_has_role(current_user, oid, 'member');
```

### Role Activity Monitoring

```sql
-- Monitor role connections
SELECT 
  usename,
  application_name,
  client_addr,
  backend_start,
  state,
  query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY backend_start;

-- Failed login attempts (requires log analysis)
-- This would typically be done through log analysis tools
```

## 2.8 Best Practices

### 1. Role Naming Conventions
- Use descriptive names: `finance_readonly`, `app_admin`
- Use consistent prefixes: `role_`, `user_`, `service_`
- Avoid special characters in role names

### 2. Security Best Practices
- Use principle of least privilege
- Regularly audit role memberships
- Implement password expiration policies
- Use service accounts for applications
- Monitor role activity

### 3. Maintenance Practices
- Document role purposes and assignments
- Regular cleanup of unused roles
- Automated role provisioning where possible
- Version control for role definitions

## Summary
In this module, we covered:
- PostgreSQL user and role concepts
- Creating and managing roles with various attributes
- Implementing role hierarchies and inheritance
- Advanced role management techniques
- Password and connection management
- Practical exercises for hands-on experience
- Monitoring and auditing roles
- Best practices for role management

## Next Module
[Module 3: Privileges and Access Control](04-privileges-access-control.md)
