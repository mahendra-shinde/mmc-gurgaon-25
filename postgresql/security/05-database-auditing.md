# Module 4: Database Auditing

## Learning Objectives
- Understand PostgreSQL logging and auditing capabilities
- Configure comprehensive database auditing
- Implement pg_audit extension for enhanced auditing
- Monitor database activities and security events
- Analyze audit logs for compliance and security

## 4.1 PostgreSQL Logging Overview

### Built-in Logging Capabilities
PostgreSQL provides extensive logging capabilities through configuration parameters:

1. **Connection Logging** - Track connections and disconnections
2. **Statement Logging** - Log SQL statements
3. **Error Logging** - Log errors and warnings
4. **Performance Logging** - Log slow queries and performance metrics
5. **Administrative Logging** - Log administrative actions

### Key Logging Parameters

```ini
# postgresql.conf - Logging Configuration

# Where to log
log_destination = 'stderr,csvlog'        # Can be stderr, csvlog, syslog
logging_collector = on                   # Enable log collector
log_directory = 'pg_log'                # Log file directory
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'  # Log filename pattern
log_file_mode = 0600                    # Log file permissions

# When to log
log_min_messages = warning              # Minimum message level
log_min_error_statement = error         # Log statements causing errors
log_min_duration_statement = 1000       # Log slow queries (ms)

# What to log
log_connections = on                    # Log connections
log_disconnections = on                 # Log disconnections
log_duration = off                      # Log statement duration
log_statement = 'all'                  # Log statements (none, ddl, mod, all)
log_hostname = on                       # Log client hostnames
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
```

## 4.2 Standard Database Auditing Configuration

### Basic Auditing Setup

```sql
-- Enable comprehensive logging
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_duration = 'on';
ALTER SYSTEM SET log_min_duration_statement = 0;

-- Reload configuration
SELECT pg_reload_conf();
```

### Connection and Authentication Logging

```ini
# Log all connection attempts
log_connections = on
log_disconnections = on
log_hostname = on

# Authentication logging
log_line_prefix = '%m [%p] %q%u@%d/%a '

# Log failed authentication attempts
# (These appear as LOG messages with log_connections = on)
```

### Statement Logging Categories

```sql
-- Different logging levels
ALTER SYSTEM SET log_statement = 'none';    -- No statements
ALTER SYSTEM SET log_statement = 'ddl';     -- DDL only (CREATE, ALTER, DROP)
ALTER SYSTEM SET log_statement = 'mod';     -- DDL + DML (INSERT, UPDATE, DELETE)
ALTER SYSTEM SET log_statement = 'all';     -- All statements

-- Duration-based logging
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- Log queries > 1 second
ALTER SYSTEM SET log_duration = 'on';                -- Log all durations
```

### Error and Warning Logging

```sql
-- Configure error logging levels
ALTER SYSTEM SET log_min_messages = 'info';
ALTER SYSTEM SET log_min_error_statement = 'warning';

-- Client message logging
ALTER SYSTEM SET client_min_messages = 'notice';
```

## 4.3 pg_audit Extension

### Installation and Setup

```sql
-- Create the extension (requires superuser)
CREATE EXTENSION pg_audit;

-- Verify installation
SELECT * FROM pg_available_extensions WHERE name = 'pg_audit';
```

### Basic pg_audit Configuration

```sql
-- Set audit log format
ALTER SYSTEM SET pg_audit.log = 'all';  -- Audit everything
-- OR be more specific:
-- ALTER SYSTEM SET pg_audit.log = 'read,write,ddl,role';

-- Set log level
ALTER SYSTEM SET pg_audit.log_level = 'log';

-- Include additional information
ALTER SYSTEM SET pg_audit.log_client = 'on';
ALTER SYSTEM SET pg_audit.log_catalog = 'off';  -- Exclude system catalog access
ALTER SYSTEM SET pg_audit.log_parameter = 'on'; -- Include parameter values

-- Reload configuration
SELECT pg_reload_conf();
```

### pg_audit Configuration Options

```sql
-- Comprehensive audit configuration
ALTER SYSTEM SET pg_audit.log = 'read,write,ddl,role,misc';
ALTER SYSTEM SET pg_audit.log_relation = 'on';    -- Log relation names
ALTER SYSTEM SET pg_audit.log_statement_once = 'off'; -- Log each statement
ALTER SYSTEM SET pg_audit.role = 'audit_role';    -- Audit specific role activities

-- Session-level audit settings
SET pg_audit.log = 'write';  -- Only audit writes for this session
```

### Object-Level Auditing

```sql
-- Create audit role
CREATE ROLE audit_role;

-- Grant audit role to users you want to monitor
GRANT audit_role TO sensitive_user;

-- Set object-level auditing
ALTER SYSTEM SET pg_audit.role = 'audit_role';

-- Grant specific object access to audit role to track access
GRANT SELECT ON sensitive_table TO audit_role;
GRANT INSERT, UPDATE, DELETE ON critical_table TO audit_role;
```

## 4.4 Advanced Auditing Techniques

### Custom Audit Triggers

```sql
-- Create audit table
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  table_name TEXT NOT NULL,
  operation CHAR(1) NOT NULL, -- I, U, D
  user_name TEXT NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  old_values JSONB,
  new_values JSONB
);

-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (table_name, operation, user_name, old_values)
    VALUES (TG_TABLE_NAME, 'D', current_user, row_to_json(OLD));
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (table_name, operation, user_name, old_values, new_values)
    VALUES (TG_TABLE_NAME, 'U', current_user, row_to_json(OLD), row_to_json(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (table_name, operation, user_name, new_values)
    VALUES (TG_TABLE_NAME, 'I', current_user, row_to_json(NEW));
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply audit trigger to tables
CREATE TRIGGER employees_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON employees
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

### Application-Level Auditing

```sql
-- Create application audit table
CREATE TABLE app_audit_log (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  username TEXT,
  action TEXT,
  resource TEXT,
  details JSONB,
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to log application actions
CREATE OR REPLACE FUNCTION log_app_action(
  p_user_id INTEGER,
  p_username TEXT,
  p_action TEXT,
  p_resource TEXT,
  p_details JSONB DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
  INSERT INTO app_audit_log (
    user_id, username, action, resource, details, 
    ip_address, user_agent
  ) VALUES (
    p_user_id, p_username, p_action, p_resource, p_details,
    p_ip_address, p_user_agent
  );
END;
$$ LANGUAGE plpgsql;

-- Example usage
SELECT log_app_action(
  123, 
  'john_doe', 
  'UPDATE', 
  'employee_salary', 
  '{"old_salary": 50000, "new_salary": 55000, "employee_id": 456}'::jsonb,
  '192.168.1.100'::inet,
  'Mozilla/5.0...'
);
```

## 4.5 Log Analysis and Monitoring

### PostgreSQL Log File Analysis

```bash
# View recent log entries
tail -f /var/lib/postgresql/data/pg_log/postgresql-2024-01-25_120000.log

# Search for specific patterns
grep "FATAL" /var/lib/postgresql/data/pg_log/*.log
grep "authentication failed" /var/lib/postgresql/data/pg_log/*.log
grep "DROP TABLE" /var/lib/postgresql/data/pg_log/*.log

# Count login attempts
grep "connection authorized" /var/lib/postgresql/data/pg_log/*.log | wc -l
grep "connection received" /var/lib/postgresql/data/pg_log/*.log | wc -l
```

### CSV Log Analysis

```sql
-- Create table to load CSV logs
CREATE TABLE postgres_log (
  log_time timestamp(3) with time zone,
  user_name text,
  database_name text,
  process_id integer,
  connection_from text,
  session_id text,
  session_line_num bigint,
  command_tag text,
  session_start_time timestamp with time zone,
  virtual_transaction_id text,
  transaction_id bigint,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos integer,
  context text,
  query text,
  query_pos integer,
  location text,
  application_name text
);

-- Load CSV log file
COPY postgres_log FROM '/path/to/postgresql.csv' WITH csv;

-- Analyze failed connections
SELECT 
  log_time,
  user_name,
  database_name,
  connection_from,
  message
FROM postgres_log 
WHERE message LIKE '%authentication failed%'
ORDER BY log_time DESC;

-- Analyze DDL operations
SELECT 
  log_time,
  user_name,
  database_name,
  command_tag,
  query
FROM postgres_log 
WHERE command_tag IN ('CREATE TABLE', 'DROP TABLE', 'ALTER TABLE')
ORDER BY log_time DESC;
```

### Real-time Monitoring Queries

```sql
-- Monitor current connections
SELECT 
  usename,
  application_name,
  client_addr,
  backend_start,
  state,
  query_start,
  LEFT(query, 50) as query_preview
FROM pg_stat_activity 
WHERE state = 'active'
ORDER BY query_start;

-- Monitor failed authentication attempts (requires log table)
SELECT 
  COUNT(*) as failed_attempts,
  connection_from,
  user_name
FROM postgres_log 
WHERE message LIKE '%authentication failed%'
  AND log_time > CURRENT_TIMESTAMP - INTERVAL '1 hour'
GROUP BY connection_from, user_name
ORDER BY failed_attempts DESC;

-- Monitor privilege escalation attempts
SELECT 
  log_time,
  user_name,
  database_name,
  query
FROM postgres_log 
WHERE query ILIKE '%grant%superuser%'
   OR query ILIKE '%alter%role%'
   OR query ILIKE '%create%role%'
ORDER BY log_time DESC;
```

## 4.6 Compliance and Security Auditing

### Compliance Frameworks

#### SOX (Sarbanes-Oxley) Compliance
```sql
-- Track financial data access
CREATE VIEW sox_audit_view AS
SELECT 
  al.timestamp,
  al.user_name,
  al.table_name,
  al.operation,
  al.old_values,
  al.new_values
FROM audit_log al
WHERE al.table_name IN (
  'financial_transactions',
  'account_balances',
  'revenue_data',
  'expense_data'
);

-- Regular compliance report
SELECT 
  DATE(timestamp) as audit_date,
  user_name,
  COUNT(*) as access_count,
  STRING_AGG(DISTINCT operation, ',') as operations
FROM sox_audit_view
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(timestamp), user_name
ORDER BY audit_date DESC, access_count DESC;
```

#### GDPR Compliance
```sql
-- Track personal data access
CREATE VIEW gdpr_audit_view AS
SELECT 
  al.timestamp,
  al.user_name,
  al.table_name,
  al.operation,
  CASE 
    WHEN al.table_name IN ('customers', 'users', 'personal_info') THEN 'PERSONAL_DATA'
    WHEN al.table_name IN ('preferences', 'consents') THEN 'CONSENT_DATA'
    ELSE 'OTHER'
  END as data_type
FROM audit_log al
WHERE al.table_name IN (
  'customers', 'users', 'personal_info', 
  'preferences', 'consents', 'contact_info'
);

-- Data subject access log
SELECT 
  timestamp,
  user_name,
  operation,
  table_name,
  CASE 
    WHEN new_values ? 'email' OR old_values ? 'email' THEN 'EMAIL_ACCESS'
    WHEN new_values ? 'phone' OR old_values ? 'phone' THEN 'PHONE_ACCESS'
    ELSE 'OTHER_PERSONAL_DATA'
  END as access_type
FROM audit_log
WHERE table_name = 'customers'
  AND timestamp >= CURRENT_DATE - INTERVAL '7 days';
```

### Security Event Detection

```sql
-- Detect suspicious activities
WITH suspicious_activities AS (
  -- Multiple failed logins
  SELECT 
    'MULTIPLE_FAILED_LOGINS' as alert_type,
    connection_from as source,
    user_name,
    COUNT(*) as event_count,
    MIN(log_time) as first_event,
    MAX(log_time) as last_event
  FROM postgres_log 
  WHERE message LIKE '%authentication failed%'
    AND log_time > CURRENT_TIMESTAMP - INTERVAL '1 hour'
  GROUP BY connection_from, user_name
  HAVING COUNT(*) >= 5
  
  UNION ALL
  
  -- Off-hours database access
  SELECT 
    'OFF_HOURS_ACCESS' as alert_type,
    client_addr::text as source,
    usename as user_name,
    1 as event_count,
    backend_start as first_event,
    backend_start as last_event
  FROM pg_stat_activity 
  WHERE EXTRACT(hour FROM backend_start) NOT BETWEEN 7 AND 19
    AND usename NOT IN ('postgres', 'monitoring_user')
    
  UNION ALL
  
  -- Unusual privilege changes
  SELECT 
    'PRIVILEGE_CHANGE' as alert_type,
    connection_from as source,
    user_name,
    1 as event_count,
    log_time as first_event,
    log_time as last_event
  FROM postgres_log 
  WHERE (query ILIKE '%grant%' OR query ILIKE '%revoke%')
    AND log_time > CURRENT_TIMESTAMP - INTERVAL '24 hours'
    AND user_name != 'postgres'
)
SELECT * FROM suspicious_activities
ORDER BY last_event DESC;
```

## 4.7 Practical Lab Exercises

### Lab 1: Basic Auditing Setup

```sql
-- Exercise 1: Configure comprehensive auditing
-- 1. Enable basic logging
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_min_duration_statement = 1000;

-- 2. Configure detailed log format
ALTER SYSTEM SET log_line_prefix = '%m [%p] %q%u@%d/%a %h ';

-- 3. Reload configuration
SELECT pg_reload_conf();

-- 4. Test logging by performing various operations
CREATE TABLE audit_test (id SERIAL PRIMARY KEY, name TEXT);
INSERT INTO audit_test (name) VALUES ('Test Entry');
UPDATE audit_test SET name = 'Updated Entry' WHERE id = 1;
DELETE FROM audit_test WHERE id = 1;
DROP TABLE audit_test;

-- 5. Check log files for these operations
-- (Review log files in system)
```

### Lab 2: pg_audit Implementation

```sql
-- Exercise 2: Set up pg_audit extension
-- 1. Install pg_audit (if not already installed)
CREATE EXTENSION IF NOT EXISTS pg_audit;

-- 2. Configure comprehensive auditing
ALTER SYSTEM SET pg_audit.log = 'read,write,ddl,role';
ALTER SYSTEM SET pg_audit.log_client = 'on';
ALTER SYSTEM SET pg_audit.log_parameter = 'on';
ALTER SYSTEM SET pg_audit.log_relation = 'on';

-- 3. Reload configuration
SELECT pg_reload_conf();

-- 4. Create test scenario
CREATE TABLE sensitive_data (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER,
  credit_card VARCHAR(16),
  balance DECIMAL(10,2)
);

-- 5. Perform audited operations
INSERT INTO sensitive_data (customer_id, credit_card, balance) 
VALUES (1001, '1234567890123456', 1500.00);

SELECT * FROM sensitive_data WHERE customer_id = 1001;

UPDATE sensitive_data SET balance = 1600.00 WHERE customer_id = 1001;

-- 6. Review audit logs in PostgreSQL log files
```

### Lab 3: Custom Audit Trail

```sql
-- Exercise 3: Implement custom audit trail
-- 1. Create comprehensive audit infrastructure
CREATE SCHEMA audit;

CREATE TABLE audit.data_changes (
  id BIGSERIAL PRIMARY KEY,
  schema_name TEXT NOT NULL,
  table_name TEXT NOT NULL,
  operation CHAR(1) NOT NULL CHECK (operation IN ('I','U','D')),
  user_name TEXT NOT NULL,
  session_id TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  old_data JSONB,
  new_data JSONB,
  changed_fields TEXT[],
  client_addr INET,
  application_name TEXT
);

-- 2. Create advanced audit function
CREATE OR REPLACE FUNCTION audit.log_data_changes()
RETURNS TRIGGER AS $$
DECLARE
  old_data JSONB;
  new_data JSONB;
  changed_fields TEXT[];
  client_addr INET;
  app_name TEXT;
BEGIN
  -- Get client information
  SELECT client_addr, application_name INTO client_addr, app_name
  FROM pg_stat_activity WHERE pid = pg_backend_pid();
  
  IF TG_OP = 'DELETE' THEN
    old_data := row_to_json(OLD);
    INSERT INTO audit.data_changes (
      schema_name, table_name, operation, user_name, session_id,
      old_data, client_addr, application_name
    ) VALUES (
      TG_TABLE_SCHEMA, TG_TABLE_NAME, 'D', current_user, 
      current_setting('log_line_prefix'),
      old_data, client_addr, app_name
    );
    RETURN OLD;
    
  ELSIF TG_OP = 'UPDATE' THEN
    old_data := row_to_json(OLD);
    new_data := row_to_json(NEW);
    
    -- Identify changed fields
    SELECT array_agg(key) INTO changed_fields
    FROM jsonb_each(old_data) o
    WHERE o.value IS DISTINCT FROM (new_data -> o.key);
    
    INSERT INTO audit.data_changes (
      schema_name, table_name, operation, user_name, session_id,
      old_data, new_data, changed_fields, client_addr, application_name
    ) VALUES (
      TG_TABLE_SCHEMA, TG_TABLE_NAME, 'U', current_user,
      current_setting('log_line_prefix'),
      old_data, new_data, changed_fields, client_addr, app_name
    );
    RETURN NEW;
    
  ELSIF TG_OP = 'INSERT' THEN
    new_data := row_to_json(NEW);
    INSERT INTO audit.data_changes (
      schema_name, table_name, operation, user_name, session_id,
      new_data, client_addr, application_name
    ) VALUES (
      TG_TABLE_SCHEMA, TG_TABLE_NAME, 'I', current_user,
      current_setting('log_line_prefix'),
      new_data, client_addr, app_name
    );
    RETURN NEW;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 3. Apply audit trigger to test table
CREATE TRIGGER employees_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON employees
  FOR EACH ROW EXECUTE FUNCTION audit.log_data_changes();

-- 4. Test the audit system
INSERT INTO employees (name, email, department, salary) 
VALUES ('Alice Johnson', 'alice@company.com', 'Engineering', 75000);

UPDATE employees SET salary = 80000 WHERE name = 'Alice Johnson';

DELETE FROM employees WHERE name = 'Alice Johnson';

-- 5. Review audit data
SELECT 
  timestamp,
  schema_name,
  table_name,
  operation,
  user_name,
  changed_fields,
  old_data,
  new_data
FROM audit.data_changes
ORDER BY timestamp DESC;
```

## 4.8 Log Management and Retention

### Log Rotation Configuration

```ini
# postgresql.conf - Log rotation settings
log_truncate_on_rotation = on        # Overwrite old log files
log_rotation_age = 1d               # Rotate daily
log_rotation_size = 100MB           # Rotate when file reaches 100MB
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
```

### Automated Log Cleanup

```bash
#!/bin/bash
# log_cleanup.sh - Clean up old PostgreSQL logs

LOG_DIR="/var/lib/postgresql/data/pg_log"
RETENTION_DAYS=30

# Remove logs older than retention period
find "$LOG_DIR" -name "postgresql-*.log" -type f -mtime +$RETENTION_DAYS -delete

# Compress logs older than 7 days
find "$LOG_DIR" -name "postgresql-*.log" -type f -mtime +7 ! -name "*.gz" -exec gzip {} \;

echo "Log cleanup completed: $(date)"
```

### Centralized Log Management

```bash
# rsyslog configuration for PostgreSQL
# Add to /etc/rsyslog.conf or /etc/rsyslog.d/postgresql.conf

# PostgreSQL logs
local0.*    /var/log/postgresql/postgresql.log

# Forward to centralized log server
*.* @@logserver.company.com:514
```

## Summary
In this module, we covered:
- PostgreSQL built-in logging capabilities
- Comprehensive audit configuration
- pg_audit extension for enhanced auditing
- Custom audit trail implementation
- Log analysis and monitoring techniques
- Compliance and security auditing
- Practical exercises for hands-on experience
- Log management and retention strategies

## Next Module
[Module 5: Backup and Recovery Concepts](06-backup-recovery-concepts.md)
