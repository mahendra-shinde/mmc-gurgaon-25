# Module 8: Practical Labs and Exercises

## Learning Objectives
- Apply security and backup concepts through hands-on exercises
- Implement complete security and backup solutions
- Practice real-world scenarios and troubleshooting
- Develop operational procedures and documentation
- Validate learning through comprehensive practical assessments

## 8.1 Lab Environment Setup

### Prerequisites
- PostgreSQL 13+ installed and running
- Administrative access to PostgreSQL server
- Basic command line familiarity
- Text editor for configuration files

### Lab Environment Configuration

```bash
#!/bin/bash
# setup_lab_environment.sh

echo "Setting up PostgreSQL Security & Backup Lab Environment"

# Create lab directories
sudo mkdir -p /backup/postgresql/{daily,weekly,monthly,wal_archive,base}
sudo mkdir -p /scripts/backup
sudo mkdir -p /var/log/postgresql/lab
sudo mkdir -p /etc/postgresql/lab

# Set permissions
sudo chown -R postgres:postgres /backup/postgresql
sudo chown -R postgres:postgres /var/log/postgresql/lab
sudo chmod 755 /scripts/backup

# Create lab databases
psql -U postgres << EOF
-- Create lab databases
CREATE DATABASE security_lab;
CREATE DATABASE backup_lab;
CREATE DATABASE recovery_lab;

-- Create lab schemas
\c security_lab;
CREATE SCHEMA hr;
CREATE SCHEMA finance;
CREATE SCHEMA sales;

\c backup_lab;
CREATE SCHEMA production;
CREATE SCHEMA staging;

\c recovery_lab;
CREATE SCHEMA app_data;
CREATE SCHEMA audit;
EOF

echo "Lab environment setup completed"
```

### Sample Data Creation

```sql
-- sample_data_setup.sql
-- Connect to security_lab
\c security_lab;

-- HR Schema Tables
CREATE TABLE hr.employees (
    id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(10,2),
    department VARCHAR(50),
    manager_id INTEGER,
    ssn VARCHAR(11),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE hr.departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    budget DECIMAL(15,2),
    manager_id INTEGER
);

-- Finance Schema Tables
CREATE TABLE finance.accounts (
    id SERIAL PRIMARY KEY,
    account_number VARCHAR(20),
    account_name VARCHAR(100),
    balance DECIMAL(15,2),
    account_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE finance.transactions (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES finance.accounts(id),
    transaction_type VARCHAR(20),
    amount DECIMAL(15,2),
    description TEXT,
    transaction_date DATE DEFAULT CURRENT_DATE
);

-- Sales Schema Tables
CREATE TABLE sales.customers (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(20),
    company_name VARCHAR(100),
    contact_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sales.orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(20),
    customer_id INTEGER REFERENCES sales.customers(id),
    order_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(12,2),
    status VARCHAR(20)
);

-- Insert sample data
INSERT INTO hr.departments (name, budget, manager_id) VALUES
    ('Engineering', 2000000.00, 1),
    ('Sales', 1500000.00, 2),
    ('Finance', 800000.00, 3),
    ('HR', 600000.00, 4);

INSERT INTO hr.employees (employee_id, first_name, last_name, email, phone, hire_date, salary, department, ssn) VALUES
    ('EMP001', 'John', 'Doe', 'john.doe@company.com', '555-0101', '2020-01-15', 85000.00, 'Engineering', '123-45-6789'),
    ('EMP002', 'Jane', 'Smith', 'jane.smith@company.com', '555-0102', '2019-03-20', 92000.00, 'Engineering', '234-56-7890'),
    ('EMP003', 'Mike', 'Johnson', 'mike.johnson@company.com', '555-0103', '2021-06-10', 78000.00, 'Sales', '345-67-8901'),
    ('EMP004', 'Sarah', 'Wilson', 'sarah.wilson@company.com', '555-0104', '2018-11-05', 95000.00, 'Finance', '456-78-9012'),
    ('EMP005', 'David', 'Brown', 'david.brown@company.com', '555-0105', '2022-02-28', 72000.00, 'HR', '567-89-0123');

INSERT INTO finance.accounts (account_number, account_name, balance, account_type) VALUES
    ('ACC001', 'Operating Account', 500000.00, 'Checking'),
    ('ACC002', 'Payroll Account', 250000.00, 'Checking'),
    ('ACC003', 'Investment Account', 1000000.00, 'Investment'),
    ('ACC004', 'Emergency Fund', 750000.00, 'Savings');

INSERT INTO sales.customers (customer_id, company_name, contact_name, email, phone, address) VALUES
    ('CUST001', 'ABC Corporation', 'Robert Taylor', 'robert@abc-corp.com', '555-1001', '123 Business St, City, ST 12345'),
    ('CUST002', 'XYZ Industries', 'Lisa Anderson', 'lisa@xyz-ind.com', '555-1002', '456 Industrial Blvd, City, ST 12346'),
    ('CUST003', 'Tech Solutions LLC', 'Mark Davis', 'mark@techsol.com', '555-1003', '789 Technology Dr, City, ST 12347');

INSERT INTO sales.orders (order_number, customer_id, order_date, total_amount, status) VALUES
    ('ORD001', 1, '2024-01-15', 25000.00, 'Completed'),
    ('ORD002', 2, '2024-01-20', 45000.00, 'Processing'),
    ('ORD003', 3, '2024-01-25', 18000.00, 'Shipped'),
    ('ORD004', 1, '2024-01-28', 32000.00, 'Pending');
```

## 8.2 Lab 1: Comprehensive Security Implementation

### Objective
Implement a complete security solution including user management, role-based access control, and auditing.

### Exercise 1.1: Role-Based Security Design

```sql
-- security_lab_exercise_1.sql
\c security_lab;

-- Task 1: Create role hierarchy
-- 1. Create department-based roles
CREATE ROLE hr_dept;
CREATE ROLE finance_dept;
CREATE ROLE sales_dept;

-- 2. Create function-based roles
CREATE ROLE readonly_access;
CREATE ROLE data_entry_access;
CREATE ROLE manager_access;
CREATE ROLE admin_access;

-- 3. Create specific user roles
CREATE ROLE hr_manager WITH LOGIN PASSWORD 'HRManager123!';
CREATE ROLE finance_analyst WITH LOGIN PASSWORD 'FinAnalyst123!';
CREATE ROLE sales_rep WITH LOGIN PASSWORD 'SalesRep123!';
CREATE ROLE data_entry_clerk WITH LOGIN PASSWORD 'DataEntry123!';
CREATE ROLE system_admin WITH LOGIN PASSWORD 'SysAdmin123!' CREATEDB CREATEROLE;

-- Task 2: Build role hierarchy
-- Grant function roles to department roles
GRANT readonly_access TO hr_dept;
GRANT data_entry_access TO hr_dept;
GRANT manager_access TO hr_dept;

GRANT readonly_access TO finance_dept;
GRANT manager_access TO finance_dept;

GRANT readonly_access TO sales_dept;
GRANT data_entry_access TO sales_dept;

-- Grant department roles to users
GRANT hr_dept TO hr_manager;
GRANT finance_dept TO finance_analyst;
GRANT sales_dept TO sales_rep;
GRANT data_entry_access TO data_entry_clerk;
GRANT admin_access TO system_admin;

-- Task 3: Implement schema-level permissions
-- HR schema permissions
GRANT USAGE ON SCHEMA hr TO hr_dept;
GRANT SELECT ON ALL TABLES IN SCHEMA hr TO readonly_access;
GRANT INSERT, UPDATE ON hr.employees TO data_entry_access;
GRANT ALL PRIVILEGES ON SCHEMA hr TO manager_access;

-- Finance schema permissions
GRANT USAGE ON SCHEMA finance TO finance_dept;
GRANT SELECT ON ALL TABLES IN SCHEMA finance TO readonly_access;
GRANT ALL PRIVILEGES ON SCHEMA finance TO manager_access;

-- Sales schema permissions
GRANT USAGE ON SCHEMA sales TO sales_dept;
GRANT SELECT ON ALL TABLES IN SCHEMA sales TO readonly_access;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sales TO data_entry_access;

-- Set default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA hr GRANT SELECT ON TABLES TO readonly_access;
ALTER DEFAULT PRIVILEGES IN SCHEMA hr GRANT INSERT, UPDATE ON TABLES TO data_entry_access;
ALTER DEFAULT PRIVILEGES IN SCHEMA finance GRANT SELECT ON TABLES TO readonly_access;
ALTER DEFAULT PRIVILEGES IN SCHEMA sales GRANT SELECT ON TABLES TO readonly_access;
ALTER DEFAULT PRIVILEGES IN SCHEMA sales GRANT INSERT, UPDATE, DELETE ON TABLES TO data_entry_access;
```

### Exercise 1.2: Column-Level Security

```sql
-- Task 4: Implement column-level security for sensitive data
-- Create view for HR data without sensitive columns
CREATE VIEW hr.employee_public AS
SELECT 
    id,
    employee_id,
    first_name,
    last_name,
    email,
    phone,
    hire_date,
    department,
    created_at
FROM hr.employees;

-- Grant access to public view
GRANT SELECT ON hr.employee_public TO readonly_access;

-- Create view for finance summary (without account details)
CREATE VIEW finance.account_summary AS
SELECT 
    id,
    account_name,
    account_type,
    CASE 
        WHEN balance > 100000 THEN 'High'
        WHEN balance > 50000 THEN 'Medium'
        ELSE 'Low'
    END as balance_category
FROM finance.accounts;

GRANT SELECT ON finance.account_summary TO readonly_access;

-- Task 5: Create audit function for sensitive data access
CREATE OR REPLACE FUNCTION log_sensitive_access()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit.access_log (
        table_name,
        user_name,
        access_time,
        operation,
        client_ip
    ) VALUES (
        TG_TABLE_NAME,
        current_user,
        CURRENT_TIMESTAMP,
        TG_OP,
        inet_client_addr()
    );
    
    IF TG_OP = 'SELECT' THEN
        RETURN NULL;
    ELSIF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create audit log table
CREATE TABLE audit.access_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    user_name VARCHAR(100),
    access_time TIMESTAMP,
    operation VARCHAR(10),
    client_ip INET
);

-- Apply audit trigger to sensitive tables
CREATE TRIGGER hr_employees_audit 
    AFTER SELECT OR INSERT OR UPDATE OR DELETE ON hr.employees
    FOR EACH ROW EXECUTE FUNCTION log_sensitive_access();

CREATE TRIGGER finance_accounts_audit 
    AFTER SELECT OR INSERT OR UPDATE OR DELETE ON finance.accounts
    FOR EACH ROW EXECUTE FUNCTION log_sensitive_access();
```

### Exercise 1.3: Testing Security Implementation

```bash
#!/bin/bash
# test_security_implementation.sh

echo "Testing Security Implementation"

# Test 1: HR Manager Access
echo "Test 1: HR Manager accessing HR data..."
psql -h localhost -U hr_manager -d security_lab -c "SELECT count(*) FROM hr.employees;" 2>&1 | grep -q "ERROR" && echo "FAIL" || echo "PASS"

# Test 2: Sales Rep accessing Finance data (should fail)
echo "Test 2: Sales Rep accessing Finance data (should fail)..."
psql -h localhost -U sales_rep -d security_lab -c "SELECT * FROM finance.accounts;" 2>&1 | grep -q "ERROR" && echo "PASS" || echo "FAIL"

# Test 3: Data Entry Clerk accessing salary information (should fail)
echo "Test 3: Data Entry Clerk accessing salary information (should fail)..."
psql -h localhost -U data_entry_clerk -d security_lab -c "SELECT salary FROM hr.employees;" 2>&1 | grep -q "ERROR" && echo "PASS" || echo "FAIL"

# Test 4: Finance Analyst accessing finance summary
echo "Test 4: Finance Analyst accessing finance summary..."
psql -h localhost -U finance_analyst -d security_lab -c "SELECT * FROM finance.account_summary;" 2>&1 | grep -q "ERROR" && echo "FAIL" || echo "PASS"

echo "Security testing completed"
```

## 8.3 Lab 2: Comprehensive Backup Solution

### Objective
Implement a complete backup strategy including multiple backup types, scheduling, and monitoring.

### Exercise 2.1: Multi-Level Backup Strategy

```bash
#!/bin/bash
# comprehensive_backup_system.sh

# Configuration
BACKUP_ROOT="/backup/postgresql"
LOG_DIR="/var/log/postgresql/lab"
CONFIG_FILE="/etc/postgresql/lab/backup.conf"

# Create configuration file
cat > $CONFIG_FILE << EOF
# Backup Configuration
DB_HOST="localhost"
DB_USER="postgres"
DATABASES="security_lab backup_lab recovery_lab"

# Retention policies
DAILY_RETENTION=7
WEEKLY_RETENTION=4
MONTHLY_RETENTION=6
YEARLY_RETENTION=3

# Backup types and schedules
FULL_BACKUP_DAY=7      # Sunday
MONTHLY_BACKUP_DAY=1   # 1st of month

# Notification settings
ADMIN_EMAIL="admin@company.com"
ALERT_ON_FAILURE=true
ALERT_ON_SUCCESS=false

# Storage settings
COMPRESS_BACKUPS=true
ENCRYPT_BACKUPS=false
OFFSITE_BACKUP=true
OFFSITE_LOCATION="s3://company-backups/"
EOF

# Source configuration
source $CONFIG_FILE

# Function to determine backup type
determine_backup_type() {
    local day_of_week=$(date +%u)
    local day_of_month=$(date +%d)
    
    if [ "$day_of_month" = "01" ]; then
        echo "monthly"
    elif [ "$day_of_week" = "$FULL_BACKUP_DAY" ]; then
        echo "weekly"
    else
        echo "daily"
    fi
}

# Function to perform database backup
backup_database() {
    local db_name="$1"
    local backup_type="$2"
    local backup_dir="$3"
    local timestamp="$4"
    
    echo "Backing up database: $db_name (Type: $backup_type)"
    
    # Full backup
    pg_dump -h $DB_HOST -U $DB_USER -d $db_name \
        -Fc --verbose \
        -f "$backup_dir/${db_name}_${backup_type}_${timestamp}.dump"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✓ Database $db_name backup completed"
        
        # Schema-only backup
        pg_dump -h $DB_HOST -U $DB_USER -d $db_name \
            --schema-only \
            -f "$backup_dir/${db_name}_schema_${timestamp}.sql"
        
        # Compress if configured
        if [ "$COMPRESS_BACKUPS" = "true" ]; then
            gzip "$backup_dir/${db_name}_${backup_type}_${timestamp}.dump"
            gzip "$backup_dir/${db_name}_schema_${timestamp}.sql"
        fi
        
        return 0
    else
        echo "✗ Database $db_name backup failed"
        return 1
    fi
}

# Main backup execution
main() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_type=$(determine_backup_type)
    local backup_dir="$BACKUP_ROOT/$backup_type/$timestamp"
    
    echo "=== Comprehensive Backup Started ==="
    echo "Date: $(date)"
    echo "Type: $backup_type"
    echo "Directory: $backup_dir"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Backup each database
    local success_count=0
    local total_count=0
    
    for db in $DATABASES; do
        total_count=$((total_count + 1))
        if backup_database "$db" "$backup_type" "$backup_dir" "$timestamp"; then
            success_count=$((success_count + 1))
        fi
    done
    
    # Create backup manifest
    cat > "$backup_dir/backup_manifest.txt" << EOF
Backup Information
==================
Date: $(date)
Type: $backup_type
Databases: $DATABASES
Success Rate: $success_count/$total_count
Backup Size: $(du -sh "$backup_dir" | cut -f1)
Compression: $COMPRESS_BACKUPS
Encryption: $ENCRYPT_BACKUPS

File List:
$(ls -la "$backup_dir")
EOF
    
    # Calculate checksums
    find "$backup_dir" -name "*.dump*" -o -name "*.sql*" | while read file; do
        md5sum "$file" >> "$backup_dir/checksums.md5"
    done
    
    echo "=== Comprehensive Backup Completed ==="
    echo "Success rate: $success_count/$total_count"
}

# Execute main function
main "$@"
```

### Exercise 2.2: WAL Archiving Implementation

```bash
#!/bin/bash
# setup_wal_archiving.sh

WAL_ARCHIVE_DIR="/backup/postgresql/wal_archive"
ARCHIVE_SCRIPT="/scripts/backup/archive_wal.sh"

echo "Setting up WAL archiving..."

# Create WAL archive directory
mkdir -p "$WAL_ARCHIVE_DIR"
chown postgres:postgres "$WAL_ARCHIVE_DIR"

# Create advanced WAL archive script
cat > $ARCHIVE_SCRIPT << 'EOF'
#!/bin/bash
# Advanced WAL archive script

WAL_SOURCE="$1"
WAL_FILE="$2"
ARCHIVE_DIR="/backup/postgresql/wal_archive"
LOG_FILE="/var/log/postgresql/wal_archive.log"
REMOTE_ARCHIVE="s3://company-backups/wal/"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to archive to local storage
archive_local() {
    local source="$1"
    local target="$2"
    
    if cp "$source" "$target"; then
        log_message "SUCCESS: Archived $WAL_FILE locally"
        return 0
    else
        log_message "ERROR: Failed to archive $WAL_FILE locally"
        return 1
    fi
}

# Function to archive to remote storage
archive_remote() {
    local source="$1"
    local remote_path="$2"
    
    # Example using AWS CLI (uncomment and configure as needed)
    # if aws s3 cp "$source" "$remote_path"; then
    #     log_message "SUCCESS: Archived $WAL_FILE remotely"
    #     return 0
    # else
    #     log_message "ERROR: Failed to archive $WAL_FILE remotely"
    #     return 1
    # fi
    
    # For lab purposes, simulate remote archive
    log_message "SIMULATED: Remote archive of $WAL_FILE"
    return 0
}

# Main archive process
main() {
    log_message "Starting archive of $WAL_FILE"
    
    # Archive locally
    if archive_local "$WAL_SOURCE" "$ARCHIVE_DIR/$WAL_FILE"; then
        # Create checksum
        md5sum "$ARCHIVE_DIR/$WAL_FILE" > "$ARCHIVE_DIR/${WAL_FILE}.md5"
        
        # Archive remotely (optional)
        archive_remote "$ARCHIVE_DIR/$WAL_FILE" "$REMOTE_ARCHIVE$WAL_FILE"
        
        log_message "Archive process completed for $WAL_FILE"
        exit 0
    else
        log_message "Archive process failed for $WAL_FILE"
        exit 1
    fi
}

main
EOF

chmod +x $ARCHIVE_SCRIPT

# Configure PostgreSQL for WAL archiving
psql -U postgres << EOF
-- Enable WAL archiving
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET archive_mode = 'on';
ALTER SYSTEM SET archive_command = '$ARCHIVE_SCRIPT %p %f';
ALTER SYSTEM SET archive_timeout = 300;

-- Additional settings for better reliability
ALTER SYSTEM SET max_wal_senders = 3;
ALTER SYSTEM SET wal_keep_segments = 64;

-- Reload configuration
SELECT pg_reload_conf();
EOF

echo "WAL archiving setup completed"
```

### Exercise 2.3: Backup Monitoring and Alerting

```sql
-- Create backup monitoring infrastructure
\c backup_lab;

-- Backup status tracking table
CREATE TABLE backup_monitoring (
    id SERIAL PRIMARY KEY,
    backup_date DATE,
    backup_type VARCHAR(20),
    database_name VARCHAR(100),
    backup_size BIGINT,
    duration INTERVAL,
    status VARCHAR(20),
    error_message TEXT,
    checksum VARCHAR(64),
    backup_path TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to log backup status
CREATE OR REPLACE FUNCTION log_backup_status(
    p_backup_type VARCHAR,
    p_database_name VARCHAR,
    p_backup_size BIGINT,
    p_duration INTERVAL,
    p_status VARCHAR,
    p_error_message TEXT DEFAULT NULL,
    p_checksum VARCHAR DEFAULT NULL,
    p_backup_path TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO backup_monitoring (
        backup_date, backup_type, database_name, backup_size,
        duration, status, error_message, checksum, backup_path
    ) VALUES (
        CURRENT_DATE, p_backup_type, p_database_name, p_backup_size,
        p_duration, p_status, p_error_message, p_checksum, p_backup_path
    );
END;
$$ LANGUAGE plpgsql;

-- Backup health check function
CREATE OR REPLACE FUNCTION check_backup_health()
RETURNS TABLE(
    check_name TEXT,
    status TEXT,
    details TEXT
) AS $$
BEGIN
    -- Check recent backup status
    RETURN QUERY
    SELECT 
        'Recent Backups'::TEXT,
        CASE 
            WHEN COUNT(*) > 0 THEN 'HEALTHY'
            ELSE 'WARNING'
        END::TEXT,
        ('Last successful backup: ' || COALESCE(MAX(backup_date)::TEXT, 'Never'))::TEXT
    FROM backup_monitoring 
    WHERE backup_date >= CURRENT_DATE - INTERVAL '2 days'
      AND status = 'SUCCESS';
    
    -- Check backup failures
    RETURN QUERY
    SELECT 
        'Backup Failures'::TEXT,
        CASE 
            WHEN COUNT(*) = 0 THEN 'HEALTHY'
            WHEN COUNT(*) <= 2 THEN 'WARNING'
            ELSE 'CRITICAL'
        END::TEXT,
        ('Failed backups in last 7 days: ' || COUNT(*)::TEXT)::TEXT
    FROM backup_monitoring 
    WHERE backup_date >= CURRENT_DATE - INTERVAL '7 days'
      AND status = 'FAILED';
    
    -- Check backup size trends
    RETURN QUERY
    WITH size_stats AS (
        SELECT 
            AVG(backup_size) as avg_size,
            MIN(backup_size) as min_size,
            MAX(backup_size) as max_size
        FROM backup_monitoring 
        WHERE backup_date >= CURRENT_DATE - INTERVAL '30 days'
          AND status = 'SUCCESS'
    )
    SELECT 
        'Backup Size Trend'::TEXT,
        'INFO'::TEXT,
        ('Avg: ' || pg_size_pretty(avg_size::BIGINT) || 
         ', Min: ' || pg_size_pretty(min_size::BIGINT) || 
         ', Max: ' || pg_size_pretty(max_size::BIGINT))::TEXT
    FROM size_stats;
END;
$$ LANGUAGE plpgsql;

-- WAL archiving monitoring
CREATE TABLE wal_archive_monitoring (
    id SERIAL PRIMARY KEY,
    wal_file VARCHAR(100),
    archive_time TIMESTAMP,
    archive_size BIGINT,
    archive_location TEXT,
    status VARCHAR(20),
    error_message TEXT
);
```

## 8.4 Lab 3: Recovery Scenarios

### Objective
Practice various recovery scenarios including complete recovery, point-in-time recovery, and disaster recovery.

### Exercise 3.1: Point-in-Time Recovery Simulation

```bash
#!/bin/bash
# pitr_simulation.sh

echo "=== Point-in-Time Recovery Simulation ==="

# Setup test environment
DB_NAME="recovery_lab"
BACKUP_DIR="/backup/postgresql/pitr_test"
WAL_ARCHIVE_DIR="/backup/postgresql/wal_archive"

mkdir -p "$BACKUP_DIR"

# Step 1: Create initial data
echo "Step 1: Creating initial test data..."
psql -U postgres -d $DB_NAME << EOF
CREATE TABLE IF NOT EXISTS app_data.test_recovery (
    id SERIAL PRIMARY KEY,
    data_value VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert initial data
INSERT INTO app_data.test_recovery (data_value) 
VALUES ('Initial Data 1'), ('Initial Data 2'), ('Initial Data 3');

-- Force WAL switch
SELECT pg_switch_wal();
EOF

# Step 2: Take base backup
echo "Step 2: Taking base backup..."
BASE_BACKUP_TIME=$(date '+%Y-%m-%d %H:%M:%S')
pg_basebackup -U postgres -D "$BACKUP_DIR/base_backup" -Ft -z -X stream

echo "Base backup completed at: $BASE_BACKUP_TIME"

# Step 3: Add more data (good data)
sleep 2
echo "Step 3: Adding good data..."
GOOD_DATA_TIME=$(date '+%Y-%m-%d %H:%M:%S')

psql -U postgres -d $DB_NAME << EOF
INSERT INTO app_data.test_recovery (data_value) 
VALUES ('Good Data 1'), ('Good Data 2');

SELECT pg_switch_wal();
EOF

echo "Good data added at: $GOOD_DATA_TIME"

# Step 4: Simulate problematic change
sleep 2
echo "Step 4: Simulating problematic change..."
PROBLEM_TIME=$(date '+%Y-%m-%d %H:%M:%S')

psql -U postgres -d $DB_NAME << EOF
DELETE FROM app_data.test_recovery WHERE data_value LIKE 'Initial%';
UPDATE app_data.test_recovery SET data_value = 'CORRUPTED' WHERE data_value LIKE 'Good%';

SELECT pg_switch_wal();
EOF

echo "Problematic change made at: $PROBLEM_TIME"

# Step 5: Show corrupted state
echo "Step 5: Current (corrupted) state:"
psql -U postgres -d $DB_NAME -c "SELECT * FROM app_data.test_recovery ORDER BY id;"

# Step 6: Perform PITR
echo "Step 6: Performing Point-in-Time Recovery to: $GOOD_DATA_TIME"

# Stop PostgreSQL
sudo systemctl stop postgresql

# Backup current data
mv /var/lib/postgresql/data /var/lib/postgresql/data_corrupted_$(date +%Y%m%d_%H%M%S)

# Restore base backup
mkdir -p /var/lib/postgresql/data
tar -xzf "$BACKUP_DIR/base_backup/base.tar.gz" -C /var/lib/postgresql/data/

# Configure recovery
cat > /var/lib/postgresql/data/recovery.signal << EOF
# PITR Recovery
EOF

cat >> /var/lib/postgresql/data/postgresql.conf << EOF

# PITR Configuration
restore_command = 'cp $WAL_ARCHIVE_DIR/%f %p'
recovery_target_time = '$GOOD_DATA_TIME'
recovery_target_action = 'promote'
EOF

# Set ownership
chown -R postgres:postgres /var/lib/postgresql/data

# Start PostgreSQL
sudo systemctl start postgresql

# Wait for recovery
echo "Waiting for recovery to complete..."
sleep 10

# Verify recovery
echo "Step 7: Verifying recovered data:"
psql -U postgres -d $DB_NAME -c "SELECT * FROM app_data.test_recovery ORDER BY id;"

echo "=== PITR Simulation Completed ==="
```

### Exercise 3.2: Disaster Recovery Drill

```bash
#!/bin/bash
# disaster_recovery_drill.sh

echo "=== Disaster Recovery Drill ==="

# Configuration
PRIMARY_HOST="primary-db-server"
DR_HOST="dr-db-server"
APP_SERVERS=("app1" "app2" "app3")
LB_CONFIG="/etc/nginx/nginx.conf"

# Function to simulate disaster
simulate_disaster() {
    echo "Simulating primary site disaster..."
    
    # Simulate network partition or hardware failure
    echo "Primary site is now unreachable"
    
    # Log disaster event
    logger "DR_DRILL: Primary site disaster simulated at $(date)"
}

# Function to activate DR site
activate_dr_site() {
    echo "Activating DR site..."
    
    # Promote standby to primary
    ssh postgres@$DR_HOST "psql -c 'SELECT pg_promote();'"
    
    # Wait for promotion
    sleep 30
    
    # Verify promotion
    IS_PRIMARY=$(ssh postgres@$DR_HOST "psql -t -c 'SELECT NOT pg_is_in_recovery();'" | tr -d ' ')
    
    if [ "$IS_PRIMARY" = "t" ]; then
        echo "✓ DR database promoted to primary"
    else
        echo "✗ DR promotion failed"
        exit 1
    fi
}

# Function to update application configuration
update_app_config() {
    echo "Updating application configuration..."
    
    for app_server in "${APP_SERVERS[@]}"; do
        echo "Updating config on $app_server"
        
        # Update database connection string
        ssh root@$app_server "sed -i 's/$PRIMARY_HOST/$DR_HOST/g' /app/config/database.conf"
        
        # Restart application
        ssh root@$app_server "systemctl restart application"
        
        # Verify application health
        sleep 5
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$app_server/health")
        
        if [ "$HTTP_STATUS" = "200" ]; then
            echo "✓ Application on $app_server is healthy"
        else
            echo "✗ Application on $app_server failed health check"
        fi
    done
}

# Function to update load balancer
update_load_balancer() {
    echo "Updating load balancer configuration..."
    
    # Backup current config
    cp $LB_CONFIG "${LB_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Update upstream configuration
    sed -i "s/server $PRIMARY_HOST/server $DR_HOST/g" $LB_CONFIG
    
    # Test configuration
    nginx -t
    
    if [ $? -eq 0 ]; then
        # Reload configuration
        nginx -s reload
        echo "✓ Load balancer configuration updated"
    else
        echo "✗ Load balancer configuration error"
        # Restore backup
        cp "${LB_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)" $LB_CONFIG
        exit 1
    fi
}

# Function to verify DR system
verify_dr_system() {
    echo "Verifying DR system functionality..."
    
    # Database connectivity test
    if psql -h $DR_HOST -U app_user -d production -c "SELECT 1;" > /dev/null 2>&1; then
        echo "✓ Database connectivity verified"
    else
        echo "✗ Database connectivity failed"
        return 1
    fi
    
    # Application end-to-end test
    RESPONSE=$(curl -s "http://load-balancer/api/health")
    if [[ "$RESPONSE" == *"healthy"* ]]; then
        echo "✓ Application end-to-end test passed"
    else
        echo "✗ Application end-to-end test failed"
        return 1
    fi
    
    # Performance baseline test
    echo "Running performance baseline test..."
    # Add performance testing logic here
    
    return 0
}

# Function to document DR activation
document_dr_activation() {
    local dr_report="/var/log/postgresql/dr_drill_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$dr_report" << EOF
DISASTER RECOVERY DRILL REPORT
==============================

Drill Date: $(date)
Scenario: Primary site failure
DR Site: $DR_HOST

Timeline:
- Disaster simulation: $DISASTER_TIME
- DR activation started: $DR_START_TIME
- DR activation completed: $DR_END_TIME
- Total RTO: $(($(date -d "$DR_END_TIME" +%s) - $(date -d "$DISASTER_TIME" +%s))) seconds

Components Activated:
- Database: Promoted standby to primary
- Applications: Updated connection strings and restarted
- Load Balancer: Updated upstream configuration

Verification Results:
- Database connectivity: $(verify_dr_system > /dev/null 2>&1 && echo "PASS" || echo "FAIL")
- Application health checks: All servers healthy
- End-to-end functionality: Verified

Lessons Learned:
- [Add observations here]
- [Add improvement suggestions here]

Next Steps:
- Monitor system performance
- Plan failback procedure
- Update DR documentation

Participants:
- DBA Team
- Operations Team
- Application Team
EOF

    echo "DR drill report created: $dr_report"
}

# Main drill execution
main() {
    DISASTER_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "Starting disaster recovery drill at $DISASTER_TIME"
    
    simulate_disaster
    
    DR_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    activate_dr_site
    update_app_config
    update_load_balancer
    DR_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    
    if verify_dr_system; then
        echo "✓ Disaster recovery drill completed successfully"
        document_dr_activation
    else
        echo "✗ Disaster recovery drill failed verification"
        exit 1
    fi
}

# Execute drill
main "$@"
```

## 8.5 Lab 4: Performance and Optimization

### Objective
Optimize backup and recovery procedures for performance and reliability.

### Exercise 4.1: Backup Performance Optimization

```sql
-- Backup performance monitoring
\c backup_lab;

-- Create backup performance tracking
CREATE TABLE backup_performance (
    id SERIAL PRIMARY KEY,
    backup_date DATE,
    database_name VARCHAR(100),
    backup_type VARCHAR(20),
    backup_size BIGINT,
    backup_duration INTERVAL,
    compression_ratio DECIMAL(5,2),
    io_throughput DECIMAL(10,2),
    cpu_usage DECIMAL(5,2),
    parallel_jobs INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to calculate backup efficiency
CREATE OR REPLACE FUNCTION calculate_backup_efficiency(
    p_database_name VARCHAR,
    p_days_back INTEGER DEFAULT 30
) RETURNS TABLE(
    metric VARCHAR,
    value TEXT
) AS $$
BEGIN
    -- Average backup duration
    RETURN QUERY
    SELECT 
        'Average Duration'::VARCHAR,
        (AVG(EXTRACT(EPOCH FROM backup_duration)) || ' seconds')::TEXT
    FROM backup_performance 
    WHERE database_name = p_database_name
      AND backup_date >= CURRENT_DATE - p_days_back;
    
    -- Average throughput
    RETURN QUERY
    SELECT 
        'Average Throughput'::VARCHAR,
        (AVG(backup_size::DECIMAL / EXTRACT(EPOCH FROM backup_duration)) || ' bytes/sec')::TEXT
    FROM backup_performance 
    WHERE database_name = p_database_name
      AND backup_date >= CURRENT_DATE - p_days_back
      AND backup_duration > INTERVAL '0';
    
    -- Best compression ratio
    RETURN QUERY
    SELECT 
        'Best Compression'::VARCHAR,
        (MAX(compression_ratio) || '%')::TEXT
    FROM backup_performance 
    WHERE database_name = p_database_name
      AND backup_date >= CURRENT_DATE - p_days_back;
    
    -- Optimal parallel jobs
    RETURN QUERY
    WITH optimal_jobs AS (
        SELECT 
            parallel_jobs,
            AVG(EXTRACT(EPOCH FROM backup_duration)) as avg_duration
        FROM backup_performance 
        WHERE database_name = p_database_name
          AND backup_date >= CURRENT_DATE - p_days_back
        GROUP BY parallel_jobs
        ORDER BY avg_duration ASC
        LIMIT 1
    )
    SELECT 
        'Optimal Parallel Jobs'::VARCHAR,
        parallel_jobs::TEXT
    FROM optimal_jobs;
END;
$$ LANGUAGE plpgsql;
```

### Exercise 4.2: Recovery Performance Testing

```bash
#!/bin/bash
# recovery_performance_test.sh

echo "=== Recovery Performance Testing ==="

# Test configuration
TEST_DB="performance_test_db"
BACKUP_FILE="/backup/postgresql/test/performance_test.dump"
TEST_RESULTS="/var/log/postgresql/recovery_performance_$(date +%Y%m%d_%H%M%S).log"

# Function to create test database with sample data
create_test_data() {
    local size_category="$1"  # small, medium, large
    
    echo "Creating test database with $size_category dataset..."
    
    psql -U postgres -c "DROP DATABASE IF EXISTS $TEST_DB;"
    psql -U postgres -c "CREATE DATABASE $TEST_DB;"
    
    case $size_category in
        "small")
            ROWS_PER_TABLE=1000
            NUM_TABLES=10
            ;;
        "medium")
            ROWS_PER_TABLE=100000
            NUM_TABLES=20
            ;;
        "large")
            ROWS_PER_TABLE=1000000
            NUM_TABLES=50
            ;;
    esac
    
    psql -U postgres -d $TEST_DB << EOF
-- Create test schema
CREATE SCHEMA test_data;

-- Function to generate test data
CREATE OR REPLACE FUNCTION generate_test_table(table_name TEXT, row_count INTEGER)
RETURNS VOID AS \$\$
BEGIN
    EXECUTE format('
        CREATE TABLE test_data.%I (
            id SERIAL PRIMARY KEY,
            data_field_1 VARCHAR(100),
            data_field_2 TEXT,
            numeric_field DECIMAL(10,2),
            date_field DATE,
            timestamp_field TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )', table_name);
    
    EXECUTE format('
        INSERT INTO test_data.%I (data_field_1, data_field_2, numeric_field, date_field)
        SELECT 
            ''Test Data '' || generate_series,
            ''Lorem ipsum dolor sit amet, consectetur adipiscing elit. '' || generate_series,
            random() * 10000,
            CURRENT_DATE - (random() * 365)::INTEGER
        FROM generate_series(1, %s)
    ', table_name, row_count);
    
    EXECUTE format('CREATE INDEX idx_%s_data_field_1 ON test_data.%I (data_field_1)', table_name, table_name);
    EXECUTE format('CREATE INDEX idx_%s_date_field ON test_data.%I (date_field)', table_name, table_name);
END;
\$\$ LANGUAGE plpgsql;

EOF

    # Create test tables
    for i in $(seq 1 $NUM_TABLES); do
        echo "Creating test table $i of $NUM_TABLES..."
        psql -U postgres -d $TEST_DB -c "SELECT generate_test_table('test_table_$i', $ROWS_PER_TABLE);"
    done
    
    echo "Test data creation completed"
}

# Function to test backup performance
test_backup_performance() {
    local parallel_jobs="$1"
    local format="$2"
    
    echo "Testing backup performance (Jobs: $parallel_jobs, Format: $format)..."
    
    local start_time=$(date +%s)
    local backup_file="${BACKUP_FILE%.dump}_j${parallel_jobs}_${format}.dump"
    
    case $format in
        "custom")
            pg_dump -U postgres -d $TEST_DB -Fc -j $parallel_jobs -f "$backup_file"
            ;;
        "directory")
            local backup_dir="${backup_file%.dump}_dir"
            rm -rf "$backup_dir"
            pg_dump -U postgres -d $TEST_DB -Fd -j $parallel_jobs -f "$backup_dir"
            backup_file="$backup_dir"
            ;;
        "plain")
            pg_dump -U postgres -d $TEST_DB -f "${backup_file%.dump}.sql"
            backup_file="${backup_file%.dump}.sql"
            ;;
    esac
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local backup_size=$(du -sb "$backup_file" | cut -f1)
    
    echo "Backup completed in $duration seconds, size: $(numfmt --to=iec $backup_size)"
    
    # Log results
    echo "$parallel_jobs,$format,$duration,$backup_size" >> "${TEST_RESULTS}.backup_performance.csv"
    
    return $duration
}

# Function to test restore performance
test_restore_performance() {
    local backup_file="$1"
    local parallel_jobs="$2"
    local format="$3"
    
    echo "Testing restore performance (Jobs: $parallel_jobs, Format: $format)..."
    
    # Drop and recreate test database
    psql -U postgres -c "DROP DATABASE IF EXISTS ${TEST_DB}_restore;"
    psql -U postgres -c "CREATE DATABASE ${TEST_DB}_restore;"
    
    local start_time=$(date +%s)
    
    case $format in
        "custom"|"directory")
            pg_restore -U postgres -d "${TEST_DB}_restore" -j $parallel_jobs "$backup_file"
            ;;
        "plain")
            psql -U postgres -d "${TEST_DB}_restore" -f "$backup_file"
            ;;
    esac
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "Restore completed in $duration seconds"
    
    # Log results
    echo "$parallel_jobs,$format,$duration" >> "${TEST_RESULTS}.restore_performance.csv"
    
    # Cleanup
    psql -U postgres -c "DROP DATABASE ${TEST_DB}_restore;"
    
    return $duration
}

# Main performance test
main() {
    echo "Starting recovery performance testing..."
    
    # Initialize CSV files
    echo "parallel_jobs,format,duration,size" > "${TEST_RESULTS}.backup_performance.csv"
    echo "parallel_jobs,format,duration" > "${TEST_RESULTS}.restore_performance.csv"
    
    # Test different dataset sizes
    for size in small medium large; do
        echo "Testing with $size dataset..."
        
        create_test_data "$size"
        
        # Test different parallel job counts
        for jobs in 1 2 4 8; do
            # Test different formats
            for format in custom directory plain; do
                echo "Testing: Size=$size, Jobs=$jobs, Format=$format"
                
                backup_duration=$(test_backup_performance $jobs $format)
                restore_duration=$(test_restore_performance "${BACKUP_FILE%.dump}_j${jobs}_${format}.dump" $jobs $format)
                
                echo "Results: Backup=${backup_duration}s, Restore=${restore_duration}s"
            done
        done
    done
    
    # Generate performance report
    generate_performance_report
    
    echo "Performance testing completed. Results in: $TEST_RESULTS"
}

# Function to generate performance report
generate_performance_report() {
    cat > "${TEST_RESULTS}.report.txt" << EOF
BACKUP AND RESTORE PERFORMANCE REPORT
====================================

Test Date: $(date)
Test Database: $TEST_DB

Backup Performance Summary:
$(sort -t, -k3 -n "${TEST_RESULTS}.backup_performance.csv" | head -5)

Restore Performance Summary:
$(sort -t, -k3 -n "${TEST_RESULTS}.restore_performance.csv" | head -5)

Recommendations:
- Optimal parallel jobs for backup: $(awk -F, 'NR>1 {print $1, $3}' "${TEST_RESULTS}.backup_performance.csv" | sort -k2 -n | head -1 | cut -d' ' -f1)
- Optimal format for backup: $(awk -F, 'NR>1 {print $2, $3}' "${TEST_RESULTS}.backup_performance.csv" | sort -k2 -n | head -1 | cut -d' ' -f1)
- Optimal parallel jobs for restore: $(awk -F, 'NR>1 {print $1, $3}' "${TEST_RESULTS}.restore_performance.csv" | sort -k2 -n | head -1 | cut -d' ' -f1)

Next Steps:
1. Implement optimal settings in production backup scripts
2. Consider hardware upgrades for bottlenecked operations
3. Schedule regular performance testing
EOF
}

# Execute performance tests
main "$@"
```

## 8.6 Final Assessment

### Comprehensive Security and Backup Assessment

```sql
-- Final assessment database
CREATE DATABASE final_assessment;
\c final_assessment;

-- Assessment scenario setup
CREATE SCHEMA company_data;
CREATE SCHEMA sensitive_data;
CREATE SCHEMA public_data;

-- Create assessment tables
CREATE TABLE company_data.employees (
    id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20),
    name VARCHAR(100),
    email VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    ssn VARCHAR(11),
    hire_date DATE
);

CREATE TABLE company_data.projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    budget DECIMAL(12,2),
    start_date DATE,
    end_date DATE,
    confidential BOOLEAN DEFAULT FALSE
);

CREATE TABLE sensitive_data.financial_records (
    id SERIAL PRIMARY KEY,
    account_number VARCHAR(20),
    balance DECIMAL(15,2),
    transaction_history JSONB,
    access_level VARCHAR(20)
);

-- Insert assessment data
INSERT INTO company_data.employees VALUES
    (1, 'EMP001', 'John Manager', 'john@company.com', 'Management', 120000, '111-22-3333', '2020-01-15'),
    (2, 'EMP002', 'Jane Developer', 'jane@company.com', 'Engineering', 85000, '222-33-4444', '2021-03-20'),
    (3, 'EMP003', 'Bob Analyst', 'bob@company.com', 'Finance', 75000, '333-44-5555', '2019-07-10');

INSERT INTO company_data.projects VALUES
    (1, 'Public Website', 50000, '2024-01-01', '2024-06-30', FALSE),
    (2, 'Secret Algorithm', 500000, '2024-02-01', '2024-12-31', TRUE),
    (3, 'Customer Portal', 150000, '2024-03-01', '2024-09-30', FALSE);

INSERT INTO sensitive_data.financial_records VALUES
    (1, 'ACC001', 1500000.00, '{"transactions": []}', 'TOP_SECRET'),
    (2, 'ACC002', 750000.00, '{"transactions": []}', 'CONFIDENTIAL'),
    (3, 'ACC003', 250000.00, '{"transactions": []}', 'INTERNAL');
```

### Assessment Tasks

#### Task 1: Security Implementation (25 points)
```sql
-- Task 1: Implement comprehensive security
-- Requirements:
-- 1. Create role hierarchy for different access levels
-- 2. Implement column-level security for sensitive data
-- 3. Create row-level security policies
-- 4. Set up auditing for sensitive table access

-- Your solution here:
-- [Students implement security solution]
```

#### Task 2: Backup Strategy Design (25 points)
```bash
#!/bin/bash
# Task 2: Design and implement backup strategy
# Requirements:
# 1. Multiple backup types (full, incremental)
# 2. Automated scheduling
# 3. Retention policies
# 4. Backup verification

# Your solution here:
# [Students implement backup strategy]
```

#### Task 3: Recovery Procedures (25 points)
```bash
#!/bin/bash
# Task 3: Implement recovery procedures
# Requirements:
# 1. Complete database recovery
# 2. Point-in-time recovery
# 3. Selective table recovery
# 4. Recovery validation

# Your solution here:
# [Students implement recovery procedures]
```

#### Task 4: Monitoring and Documentation (25 points)
```sql
-- Task 4: Create monitoring and documentation
-- Requirements:
-- 1. Security monitoring queries
-- 2. Backup health checks
-- 3. Recovery validation procedures
-- 4. Complete documentation

-- Your solution here:
-- [Students implement monitoring and documentation]
```

### Assessment Scoring Rubric

| Criteria | Excellent (4) | Good (3) | Satisfactory (2) | Needs Improvement (1) |
|----------|---------------|----------|------------------|-----------------------|
| **Security Implementation** | Complete role hierarchy, column/row level security, comprehensive auditing | Good security with minor gaps | Basic security implementation | Incomplete or incorrect security |
| **Backup Strategy** | Comprehensive strategy with automation, monitoring, and retention | Good backup strategy with most requirements | Basic backup implementation | Incomplete backup solution |
| **Recovery Procedures** | All recovery types working with validation | Most recovery scenarios working | Basic recovery capability | Limited or non-functional recovery |
| **Monitoring & Documentation** | Comprehensive monitoring with clear documentation | Good monitoring with adequate documentation | Basic monitoring and documentation | Poor or missing monitoring/docs |

### Assessment Validation Scripts

```bash
#!/bin/bash
# assessment_validation.sh

echo "=== Final Assessment Validation ==="

# Validate security implementation
echo "1. Testing security implementation..."
./validate_security.sh

# Validate backup strategy
echo "2. Testing backup strategy..."
./validate_backups.sh

# Validate recovery procedures
echo "3. Testing recovery procedures..."
./validate_recovery.sh

# Validate monitoring
echo "4. Testing monitoring..."
./validate_monitoring.sh

echo "Assessment validation completed"
```

## Summary
In this comprehensive practical module, we covered:
- Complete lab environment setup with sample data
- Hands-on security implementation with role-based access control
- Comprehensive backup solution development and testing
- Recovery scenario practice including PITR and disaster recovery
- Performance optimization and testing procedures
- Final assessment with real-world scenarios

These practical exercises provide hands-on experience with:
- PostgreSQL security features and best practices
- Backup tool usage and automation
- Recovery procedures and validation
- Performance monitoring and optimization
- Real-world operational procedures

Students completing these labs will have practical experience implementing and managing PostgreSQL security and backup/recovery systems in production environments.
