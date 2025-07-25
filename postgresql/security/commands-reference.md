# PostgreSQL Security & Backup Commands Reference

## User and Role Management Commands

### Role Creation and Management
```sql
-- Create role with specific attributes
CREATE ROLE role_name WITH 
  LOGIN                    -- Can connect to database
  PASSWORD 'password'      -- Set password
  CREATEDB                 -- Can create databases
  CREATEROLE              -- Can create other roles
  SUPERUSER               -- Superuser privileges (use carefully)
  REPLICATION             -- Can initiate replication
  CONNECTION LIMIT 10     -- Limit connections
  VALID UNTIL '2024-12-31'; -- Password expiration

-- Modify existing role
ALTER ROLE role_name WITH PASSWORD 'new_password';
ALTER ROLE role_name WITH CREATEDB;
ALTER ROLE role_name WITH NOCREATEDB;
ALTER ROLE role_name RENAME TO new_name;

-- Drop role
DROP ROLE role_name;

-- Grant role membership
GRANT parent_role TO child_role;

-- Revoke role membership
REVOKE parent_role FROM child_role;

-- List all roles
\du
-- OR
SELECT * FROM pg_roles;
```

### Password Management
```sql
-- Set password encryption method
ALTER SYSTEM SET password_encryption = 'scram-sha-256';

-- Create user with encrypted password
CREATE USER username WITH ENCRYPTED PASSWORD 'password';

-- Set password expiration
ALTER ROLE username VALID UNTIL '2024-06-30';

-- Force password change (create function to handle this)
```

## Privilege Management Commands

### Database-Level Privileges
```sql
-- Grant database privileges
GRANT CONNECT ON DATABASE dbname TO username;
GRANT CREATE ON DATABASE dbname TO username;
GRANT TEMPORARY ON DATABASE dbname TO username;
GRANT ALL PRIVILEGES ON DATABASE dbname TO username;

-- Revoke database privileges
REVOKE CONNECT ON DATABASE dbname FROM username;
REVOKE CREATE ON DATABASE dbname FROM username;
```

### Schema-Level Privileges
```sql
-- Grant schema privileges
GRANT USAGE ON SCHEMA schema_name TO username;
GRANT CREATE ON SCHEMA schema_name TO username;
GRANT ALL ON SCHEMA schema_name TO username;

-- Grant on all schemas
GRANT USAGE ON ALL SCHEMAS IN DATABASE dbname TO username;
```

### Table-Level Privileges
```sql
-- Grant table privileges
GRANT SELECT ON TABLE table_name TO username;
GRANT INSERT ON TABLE table_name TO username;
GRANT UPDATE ON TABLE table_name TO username;
GRANT DELETE ON TABLE table_name TO username;
GRANT TRUNCATE ON TABLE table_name TO username;
GRANT REFERENCES ON TABLE table_name TO username;
GRANT TRIGGER ON TABLE table_name TO username;
GRANT ALL PRIVILEGES ON TABLE table_name TO username;

-- Grant on all tables in schema
GRANT SELECT ON ALL TABLES IN SCHEMA schema_name TO username;

-- Grant with grant option
GRANT SELECT ON TABLE table_name TO username WITH GRANT OPTION;
```

### Column-Level Privileges
```sql
-- Grant column-specific privileges
GRANT SELECT (column1, column2) ON TABLE table_name TO username;
GRANT UPDATE (column1) ON TABLE table_name TO username;
GRANT INSERT (column1, column2) ON TABLE table_name TO username;
```

### Function and Sequence Privileges
```sql
-- Grant function execution
GRANT EXECUTE ON FUNCTION function_name(args) TO username;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA schema_name TO username;

-- Grant sequence privileges
GRANT USAGE ON SEQUENCE sequence_name TO username;
GRANT SELECT ON SEQUENCE sequence_name TO username;
GRANT UPDATE ON SEQUENCE sequence_name TO username;
```

### Default Privileges
```sql
-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA schema_name 
GRANT SELECT ON TABLES TO username;

ALTER DEFAULT PRIVILEGES FOR ROLE creator_role IN SCHEMA schema_name 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO username;

ALTER DEFAULT PRIVILEGES IN SCHEMA schema_name 
GRANT EXECUTE ON FUNCTIONS TO username;
```

## Row Level Security Commands

### Enable RLS
```sql
-- Enable RLS on table
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Disable RLS
ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;

-- Force RLS for table owners
ALTER TABLE table_name FORCE ROW LEVEL SECURITY;
```

### RLS Policies
```sql
-- Create RLS policy
CREATE POLICY policy_name ON table_name 
FOR ALL                          -- OR SELECT, INSERT, UPDATE, DELETE
TO role_name                     -- Target roles
USING (condition);               -- Row filter condition

-- Policy with both USING and WITH CHECK
CREATE POLICY policy_name ON table_name 
FOR UPDATE TO role_name
USING (user_id = current_user_id())     -- Rows user can see
WITH CHECK (user_id = current_user_id()); -- Rows user can modify

-- Drop policy
DROP POLICY policy_name ON table_name;

-- Example policies
CREATE POLICY user_data_policy ON user_table 
FOR ALL TO regular_users 
USING (user_id = current_setting('app.current_user_id')::int);

CREATE POLICY manager_policy ON employee_table 
FOR ALL TO managers 
USING (department = current_setting('app.user_department'));
```

## Backup Commands

### pg_dump - Logical Backup
```bash
# Basic dump
pg_dump -h hostname -U username -d database > backup.sql

# Custom format (recommended)
pg_dump -h hostname -U username -d database -Fc -f backup.dump

# Directory format (parallel backup/restore)
pg_dump -h hostname -U username -d database -Fd -f backup_dir

# Compressed tar format
pg_dump -h hostname -U username -d database -Ft -f backup.tar

# Parallel backup (directory format only)
pg_dump -h hostname -U username -d database -Fd -j 4 -f backup_dir

# Specific tables only
pg_dump -h hostname -U username -d database -t table1 -t table2 -f backup.sql

# Specific schema only
pg_dump -h hostname -U username -d database -n schema_name -f backup.sql

# Exclude tables
pg_dump -h hostname -U username -d database -T log_table -T temp_table -f backup.sql

# Schema only
pg_dump -h hostname -U username -d database --schema-only -f schema.sql

# Data only
pg_dump -h hostname -U username -d database --data-only -f data.sql

# With verbose output
pg_dump -h hostname -U username -d database -v -Fc -f backup.dump

# Include INSERT statements instead of COPY
pg_dump -h hostname -U username -d database --inserts -f backup.sql

# Include column names in INSERT statements
pg_dump -h hostname -U username -d database --column-inserts -f backup.sql
```

### pg_dumpall - Cluster Backup
```bash
# Full cluster backup
pg_dumpall -h hostname -U username > cluster_backup.sql

# Globals only (roles, tablespaces)
pg_dumpall -h hostname -U username --globals-only > globals.sql

# Roles only
pg_dumpall -h hostname -U username --roles-only > roles.sql

# Tablespaces only
pg_dumpall -h hostname -U username --tablespaces-only > tablespaces.sql

# Schema only for entire cluster
pg_dumpall -h hostname -U username --schema-only > cluster_schema.sql
```

### pg_basebackup - Physical Backup
```bash
# Basic base backup
pg_basebackup -h hostname -U replication_user -D backup_dir

# With WAL files
pg_basebackup -h hostname -U replication_user -D backup_dir -X stream

# Tar format
pg_basebackup -h hostname -U replication_user -D backup_dir -Ft

# Compressed tar format
pg_basebackup -h hostname -U replication_user -D backup_dir -Ft -z

# With progress reporting
pg_basebackup -h hostname -U replication_user -D backup_dir -P

# Verbose output
pg_basebackup -h hostname -U replication_user -D backup_dir -v

# Write-ahead log method
pg_basebackup -h hostname -U replication_user -D backup_dir -X fetch
pg_basebackup -h hostname -U replication_user -D backup_dir -X stream
```

## Restore Commands

### pg_restore - Logical Restore
```bash
# Basic restore from custom format
pg_restore -h hostname -U username -d database backup.dump

# Create database and restore
pg_restore -h hostname -U username --create --dbname=postgres backup.dump

# Parallel restore
pg_restore -h hostname -U username -d database -j 4 backup.dump

# Specific tables only
pg_restore -h hostname -U username -d database -t table1 -t table2 backup.dump

# List contents of backup
pg_restore --list backup.dump

# Schema only
pg_restore -h hostname -U username -d database --schema-only backup.dump

# Data only
pg_restore -h hostname -U username -d database --data-only backup.dump

# Clean existing objects first
pg_restore -h hostname -U username -d database --clean backup.dump

# Verbose output
pg_restore -h hostname -U username -d database --verbose backup.dump

# Don't restore ownership
pg_restore -h hostname -U username -d database --no-owner backup.dump

# Don't restore privileges
pg_restore -h hostname -U username -d database --no-privileges backup.dump

# Single transaction
pg_restore -h hostname -U username -d database --single-transaction backup.dump

# Exit on error
pg_restore -h hostname -U username -d database --exit-on-error backup.dump
```

### SQL Restore
```bash
# Restore from plain SQL file
psql -h hostname -U username -d database < backup.sql

# Restore with specific options
psql -h hostname -U username -d database -f backup.sql

# Restore and stop on first error
psql -h hostname -U username -d database -v ON_ERROR_STOP=1 -f backup.sql
```

## WAL Archiving Commands

### Configuration
```sql
-- Enable WAL archiving
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET archive_mode = 'on';
ALTER SYSTEM SET archive_command = 'cp %p /archive/location/%f';
ALTER SYSTEM SET archive_timeout = 300;  -- seconds

-- Reload configuration
SELECT pg_reload_conf();
```

### WAL Management
```sql
-- Force WAL switch
SELECT pg_switch_wal();

-- Get current WAL position
SELECT pg_current_wal_lsn();

-- Check archiver status
SELECT * FROM pg_stat_archiver;

-- View WAL archiver settings
SELECT name, setting FROM pg_settings 
WHERE name IN ('wal_level', 'archive_mode', 'archive_command');
```

## Point-in-Time Recovery Commands

### Recovery Configuration (PostgreSQL 12+)
```bash
# Create recovery.signal file
touch /var/lib/postgresql/data/recovery.signal

# Add recovery settings to postgresql.conf
echo "restore_command = 'cp /archive/location/%f %p'" >> postgresql.conf
echo "recovery_target_time = '2024-01-25 14:30:00'" >> postgresql.conf
echo "recovery_target_action = 'pause'" >> postgresql.conf
```

### Recovery Targets
```bash
# Time-based recovery
recovery_target_time = '2024-01-25 14:30:00'

# Transaction ID recovery
recovery_target_xid = '12345'

# LSN-based recovery
recovery_target_lsn = '0/1500000'

# Named restore point
recovery_target_name = 'before_data_corruption'

# Immediate recovery (end of base backup)
recovery_target = 'immediate'
```

### Recovery Actions
```bash
# Pause recovery at target
recovery_target_action = 'pause'

# Promote immediately at target
recovery_target_action = 'promote'

# Shutdown server at target
recovery_target_action = 'shutdown'
```

## Monitoring and Information Commands

### Security Monitoring
```sql
-- View current connections
SELECT * FROM pg_stat_activity;

-- View role information
SELECT * FROM pg_roles;

-- View role memberships
SELECT 
  r.rolname as role_name,
  m.rolname as member_of
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.member
JOIN pg_roles m ON am.roleid = m.oid;

-- Check privileges on objects
SELECT * FROM information_schema.table_privileges WHERE grantee = 'username';
SELECT * FROM information_schema.column_privileges WHERE grantee = 'username';

-- Check if user has specific privilege
SELECT has_table_privilege('username', 'table_name', 'SELECT');
SELECT has_schema_privilege('username', 'schema_name', 'USAGE');
SELECT has_database_privilege('username', 'database_name', 'CONNECT');

-- View RLS policies
SELECT * FROM pg_policies WHERE tablename = 'table_name';
```

### Backup Monitoring
```sql
-- Check archiver status
SELECT * FROM pg_stat_archiver;

-- View replication status (for standby servers)
SELECT * FROM pg_stat_replication;

-- Check recovery status
SELECT pg_is_in_recovery();
SELECT pg_last_wal_receive_lsn();
SELECT pg_last_wal_replay_lsn();

-- View backup history (custom table)
SELECT * FROM backup_log ORDER BY backup_date DESC;
```

### Database Information
```sql
-- Database size
SELECT pg_size_pretty(pg_database_size('database_name'));

-- Table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index sizes
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexname)) as size
FROM pg_indexes
ORDER BY pg_relation_size(indexname) DESC;
```

## Configuration Commands

### Security Configuration
```sql
-- SSL settings
ALTER SYSTEM SET ssl = 'on';
ALTER SYSTEM SET ssl_cert_file = 'server.crt';
ALTER SYSTEM SET ssl_key_file = 'server.key';

-- Connection settings
ALTER SYSTEM SET listen_addresses = 'localhost';
ALTER SYSTEM SET port = 5432;
ALTER SYSTEM SET max_connections = 100;

-- Authentication settings
ALTER SYSTEM SET password_encryption = 'scram-sha-256';

-- Logging settings
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 1000;

-- Reload configuration
SELECT pg_reload_conf();

-- View current settings
SELECT name, setting, context FROM pg_settings WHERE name LIKE '%ssl%';
```

### Backup Configuration
```sql
-- WAL settings
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = 3;
ALTER SYSTEM SET wal_keep_segments = 64;  -- PostgreSQL < 13
ALTER SYSTEM SET wal_keep_size = '1GB';   -- PostgreSQL >= 13

-- Archive settings
ALTER SYSTEM SET archive_mode = 'on';
ALTER SYSTEM SET archive_command = 'cp %p /archive/%f';
ALTER SYSTEM SET archive_timeout = 300;

-- Checkpoint settings
ALTER SYSTEM SET checkpoint_completion_target = 0.7;
ALTER SYSTEM SET checkpoint_timeout = 900;

-- Reload configuration
SELECT pg_reload_conf();
```

## Useful Scripts and Functions

### Security Functions
```sql
-- Function to check user privileges
CREATE OR REPLACE FUNCTION check_user_privileges(username TEXT)
RETURNS TABLE(object_type TEXT, object_name TEXT, privilege_type TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT 'table'::TEXT, table_name::TEXT, privilege_type::TEXT
  FROM information_schema.table_privileges 
  WHERE grantee = username
  UNION ALL
  SELECT 'schema'::TEXT, schema_name::TEXT, 'USAGE'::TEXT
  FROM information_schema.usage_privileges
  WHERE grantee = username AND object_type = 'SCHEMA';
END;
$$ LANGUAGE plpgsql;
```

### Backup Functions
```sql
-- Function to log backup status
CREATE OR REPLACE FUNCTION log_backup(
  db_name TEXT, 
  backup_type TEXT, 
  status TEXT, 
  backup_size BIGINT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
  INSERT INTO backup_log (database_name, backup_type, status, backup_size, backup_date)
  VALUES (db_name, backup_type, status, backup_size, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;
```

This reference guide provides the essential commands and SQL statements needed for PostgreSQL security and backup operations. Keep this handy for daily operations and troubleshooting.
