# Module 5: Backup and Recovery Concepts

## Learning Objectives
- Understand different types of database backups
- Learn backup strategies and best practices
- Understand recovery concepts and scenarios
- Plan for disaster recovery and business continuity
- Design backup schedules and retention policies

## 5.1 Types of Database Backups

### 1. Logical Backups
Logical backups export database objects as SQL statements or data files.

**Advantages:**
- Platform independent
- Selective backup (specific tables/schemas)
- Human-readable format
- Easy to modify during restore

**Disadvantages:**
- Slower than physical backups
- Larger backup files
- Higher CPU overhead
- Cannot do point-in-time recovery alone

**PostgreSQL Tools:**
- `pg_dump` - Single database
- `pg_dumpall` - All databases
- `COPY` command - Individual tables

### 2. Physical Backups
Physical backups copy the actual database files and directories.

**Advantages:**
- Faster backup and restore
- Smaller backup files
- Point-in-time recovery possible
- Better for large databases

**Disadvantages:**
- Platform dependent
- All-or-nothing approach
- Requires PostgreSQL to be stopped (cold backup) or special procedures (hot backup)

**PostgreSQL Methods:**
- File system snapshots
- `pg_basebackup` - Hot physical backup
- Manual file copying (cold backup)

### 3. Continuous Archiving (WAL-based)
Uses Write-Ahead Logging (WAL) for continuous backup.

**Advantages:**
- Point-in-time recovery
- Minimal data loss
- Continuous protection
- Online backup capability

**Components:**
- Base backup
- WAL archive files
- Recovery process

## 5.2 Backup Strategies

### Full Backup Strategy
Complete backup of entire database.

```bash
# Daily full backup example
#!/bin/bash
BACKUP_DIR="/backup/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="myapp_db"

# Create backup directory
mkdir -p "$BACKUP_DIR/full/$DATE"

# Perform full backup
pg_dump -h localhost -U postgres -d $DB_NAME \
  -f "$BACKUP_DIR/full/$DATE/${DB_NAME}_full_$DATE.sql"

# Compress backup
gzip "$BACKUP_DIR/full/$DATE/${DB_NAME}_full_$DATE.sql"

echo "Full backup completed: $DATE"
```

### Incremental Backup Strategy
Backup only changes since last backup.

```bash
# WAL-based incremental backup
#!/bin/bash
WAL_ARCHIVE_DIR="/backup/wal_archive"
BASE_BACKUP_DIR="/backup/base"

# Archive WAL files
archive_command = 'test ! -f /backup/wal_archive/%f && cp %p /backup/wal_archive/%f'

# Weekly base backup + daily WAL archiving
if [ $(date +%u) -eq 1 ]; then  # Monday
    # Perform base backup
    pg_basebackup -h localhost -U postgres -D "$BASE_BACKUP_DIR/$(date +%Y%m%d)" -Ft -z
fi
```

### Differential Backup Strategy
Backup changes since last full backup.

```sql
-- PostgreSQL doesn't have native differential backup
-- Can be simulated using timestamps and logical backups

-- Full backup reference table
CREATE TABLE backup_tracking (
    backup_type VARCHAR(20),
    backup_timestamp TIMESTAMP,
    lsn TEXT
);

-- Track last full backup
INSERT INTO backup_tracking VALUES ('FULL', CURRENT_TIMESTAMP, pg_current_wal_lsn());

-- Differential backup of modified data
-- (Application-specific based on modification timestamps)
```

## 5.3 Recovery Concepts

### Recovery Types

#### 1. Complete Recovery
Restore database to most recent consistent state.

```bash
# Complete recovery from full backup
psql -h localhost -U postgres -d postgres -c "DROP DATABASE IF EXISTS myapp_db;"
psql -h localhost -U postgres -d postgres -c "CREATE DATABASE myapp_db;"
gunzip -c /backup/myapp_db_full_20240125.sql.gz | psql -h localhost -U postgres -d myapp_db
```

#### 2. Point-in-Time Recovery (PITR)
Restore database to specific point in time.

```bash
# PITR recovery process
# 1. Restore base backup
tar -xzf /backup/base/base_backup_20240125.tar.gz -C /var/lib/postgresql/data/

# 2. Create recovery.conf (PostgreSQL < 12) or recovery.signal (PostgreSQL >= 12)
echo "restore_command = 'cp /backup/wal_archive/%f %p'" > /var/lib/postgresql/data/recovery.signal
echo "recovery_target_time = '2024-01-25 14:30:00'" >> /var/lib/postgresql/data/postgresql.conf

# 3. Start PostgreSQL
systemctl start postgresql
```

#### 3. Incomplete Recovery
Recover to point before corruption or error.

```sql
-- Recovery scenarios
-- Skip problematic transaction
recovery_target_xid = '12345'

-- Recover to specific time before error
recovery_target_time = '2024-01-25 10:15:00'

-- Recover to specific LSN
recovery_target_lsn = '0/1500000'
```

### Recovery Scenarios

#### Scenario 1: Hardware Failure
Complete server hardware failure.

**Recovery Steps:**
1. Set up new hardware
2. Install PostgreSQL
3. Restore latest full backup
4. Apply incremental backups/WAL files
5. Verify data integrity

#### Scenario 2: Data Corruption
Database corruption due to disk issues.

**Recovery Steps:**
1. Identify corruption extent
2. Stop PostgreSQL
3. Restore from clean backup
4. Apply WAL up to corruption point
5. Validate data consistency

#### Scenario 3: Human Error
Accidental data deletion or modification.

**Recovery Steps:**
1. Identify error timestamp
2. Perform PITR to just before error
3. Export affected data
4. Restore current database
5. Merge recovered data

#### Scenario 4: Ransomware Attack
Database encrypted by ransomware.

**Recovery Steps:**
1. Isolate affected systems
2. Verify backup integrity
3. Clean install on new system
4. Restore from clean backups
5. Implement additional security

## 5.4 Business Continuity Planning

### Recovery Objectives

#### Recovery Time Objective (RTO)
Maximum acceptable time to restore service.

```yaml
# RTO Examples
Critical_Systems:
  RTO: 1 hour
  Strategy: Hot standby, immediate failover
  
Important_Systems:
  RTO: 4 hours
  Strategy: Warm standby, automated recovery
  
Normal_Systems:
  RTO: 24 hours
  Strategy: Cold backup, manual recovery
```

#### Recovery Point Objective (RPO)
Maximum acceptable data loss.

```yaml
# RPO Examples
Financial_Data:
  RPO: 0 minutes
  Strategy: Synchronous replication
  
Customer_Data:
  RPO: 15 minutes
  Strategy: Continuous WAL archiving
  
Analytics_Data:
  RPO: 4 hours
  Strategy: Regular automated backups
```

### Disaster Recovery Architecture

#### Primary-Secondary Setup
```yaml
# High-level DR architecture
Primary_Site:
  Location: "Data Center A"
  Role: "Active"
  Systems: ["Web Servers", "App Servers", "Database Primary"]
  
Secondary_Site:
  Location: "Data Center B"
  Role: "Standby"
  Systems: ["Web Servers (Standby)", "App Servers (Standby)", "Database Replica"]
  
Replication:
  Type: "Streaming Replication"
  Mode: "Asynchronous"
  Network: "Dedicated WAN Link"
```

#### Multi-Site Disaster Recovery
```sql
-- Configure streaming replication for DR
-- On primary server
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = 3;
ALTER SYSTEM SET wal_keep_segments = 64;  -- PostgreSQL < 13
-- ALTER SYSTEM SET wal_keep_size = '1GB';  -- PostgreSQL >= 13

-- Create replication user
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replica_password';

-- Configure pg_hba.conf for replication
-- host replication replicator dr_server_ip/32 md5

-- On DR server
pg_basebackup -h primary_server -D /var/lib/postgresql/data -U replicator -P -v -R -W
```

## 5.5 Backup Planning and Scheduling

### Backup Schedule Design

#### Small to Medium Databases (< 100GB)
```bash
# Backup schedule for smaller databases
# Daily full backup + continuous WAL archiving

# /etc/cron.d/postgresql-backup
# Daily full backup at 2 AM
0 2 * * * postgres /scripts/daily_full_backup.sh

# Hourly WAL archive cleanup (keep last 7 days)
0 * * * * postgres /scripts/cleanup_old_wal.sh

# Weekly backup verification
0 3 * * 0 postgres /scripts/verify_backups.sh
```

#### Large Databases (> 100GB)
```bash
# Backup schedule for larger databases
# Weekly full + daily incremental + continuous WAL

# Weekly full backup (Sunday 1 AM)
0 1 * * 0 postgres /scripts/weekly_full_backup.sh

# Daily incremental backup (2 AM, Mon-Sat)
0 2 * * 1-6 postgres /scripts/daily_incremental_backup.sh

# Continuous WAL archiving
archive_command = '/scripts/archive_wal.sh %p %f'

# Monthly backup verification
0 4 1 * * postgres /scripts/monthly_backup_test.sh
```

### Retention Policies

#### Standard Retention Policy
```bash
#!/bin/bash
# backup_retention.sh

# Retention periods
DAILY_RETENTION_DAYS=7
WEEKLY_RETENTION_WEEKS=4
MONTHLY_RETENTION_MONTHS=12
YEARLY_RETENTION_YEARS=7

# Clean up daily backups
find /backup/daily -name "*.sql.gz" -mtime +$DAILY_RETENTION_DAYS -delete

# Clean up weekly backups
find /backup/weekly -name "*.sql.gz" -mtime +$((WEEKLY_RETENTION_WEEKS * 7)) -delete

# Clean up monthly backups
find /backup/monthly -name "*.sql.gz" -mtime +$((MONTHLY_RETENTION_MONTHS * 30)) -delete

# Clean up yearly backups
find /backup/yearly -name "*.sql.gz" -mtime +$((YEARLY_RETENTION_YEARS * 365)) -delete
```

#### Compliance-Based Retention
```yaml
# Compliance requirements
SOX_Compliance:
  Financial_Data: 7 years
  Supporting_Documents: 7 years
  
GDPR_Compliance:
  Personal_Data: "As long as legally required"
  Consent_Records: 3 years after withdrawal
  
HIPAA_Compliance:
  Medical_Records: 6 years minimum
  Access_Logs: 6 years
```

## 5.6 Backup Testing and Validation

### Automated Backup Testing

```bash
#!/bin/bash
# test_backup_restore.sh

TEST_DB="backup_test_$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="$1"

echo "Testing backup file: $BACKUP_FILE"

# Create test database
psql -U postgres -c "CREATE DATABASE $TEST_DB;"

# Restore backup
if gunzip -c "$BACKUP_FILE" | psql -U postgres -d "$TEST_DB" > /dev/null 2>&1; then
    echo "✓ Backup restoration successful"
    
    # Verify data integrity
    TABLE_COUNT=$(psql -U postgres -d "$TEST_DB" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
    echo "✓ Found $TABLE_COUNT tables"
    
    # Test sample queries
    if psql -U postgres -d "$TEST_DB" -c "SELECT 1;" > /dev/null 2>&1; then
        echo "✓ Database connectivity verified"
    else
        echo "✗ Database connectivity failed"
    fi
    
else
    echo "✗ Backup restoration failed"
fi

# Cleanup
psql -U postgres -c "DROP DATABASE $TEST_DB;"
echo "Test completed"
```

### Backup Integrity Verification

```sql
-- Create backup verification table
CREATE TABLE backup_verification (
    backup_date DATE,
    backup_type VARCHAR(20),
    backup_size BIGINT,
    backup_checksum VARCHAR(64),
    verification_status VARCHAR(20),
    verification_date TIMESTAMP,
    notes TEXT
);

-- Function to verify backup integrity
CREATE OR REPLACE FUNCTION verify_backup_integrity(backup_path TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    checksum_old TEXT;
    checksum_new TEXT;
BEGIN
    -- Get stored checksum
    SELECT backup_checksum INTO checksum_old 
    FROM backup_verification 
    WHERE backup_path = backup_path;
    
    -- Calculate current checksum (this would be done externally)
    -- checksum_new := md5(pg_read_file(backup_path));
    
    -- Compare checksums
    IF checksum_old = checksum_new THEN
        UPDATE backup_verification 
        SET verification_status = 'VALID',
            verification_date = CURRENT_TIMESTAMP
        WHERE backup_path = backup_path;
        RETURN TRUE;
    ELSE
        UPDATE backup_verification 
        SET verification_status = 'CORRUPTED',
            verification_date = CURRENT_TIMESTAMP,
            notes = 'Checksum mismatch detected'
        WHERE backup_path = backup_path;
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

## 5.7 Practical Lab Exercises

### Lab 1: Backup Strategy Design

```sql
-- Exercise 1: Design backup strategy for different scenarios

-- Scenario A: E-commerce application
-- Requirements: 99.9% uptime, max 5 minutes data loss, 1 hour recovery time
CREATE TABLE ecommerce_backup_strategy AS
SELECT 
    'E-commerce App' as application,
    '99.9%' as uptime_requirement,
    '5 minutes' as rpo,
    '1 hour' as rto,
    'Streaming replication + WAL archiving' as strategy,
    'Continuous + Daily full + Weekly verification' as schedule;

-- Scenario B: Data warehouse
-- Requirements: 99% uptime, max 4 hours data loss, 24 hour recovery time
CREATE TABLE warehouse_backup_strategy AS
SELECT 
    'Data Warehouse' as application,
    '99%' as uptime_requirement,
    '4 hours' as rpo,
    '24 hours' as rto,
    'Scheduled logical backups + Monthly physical' as strategy,
    'Daily incremental + Weekly full' as schedule;

-- Scenario C: Development environment
-- Requirements: 95% uptime, max 24 hours data loss, 72 hour recovery time
CREATE TABLE dev_backup_strategy AS
SELECT 
    'Development' as application,
    '95%' as uptime_requirement,
    '24 hours' as rpo,
    '72 hours' as rto,
    'Weekly full backups only' as strategy,
    'Weekly full + Monthly verification' as schedule;
```

### Lab 2: Recovery Planning

```sql
-- Exercise 2: Create recovery procedures for different failure scenarios

-- Recovery procedure documentation
CREATE TABLE recovery_procedures (
    scenario_id SERIAL PRIMARY KEY,
    scenario_name VARCHAR(100),
    failure_type VARCHAR(50),
    estimated_downtime INTERVAL,
    recovery_steps TEXT[],
    required_resources TEXT[],
    success_criteria TEXT[]
);

-- Hardware failure recovery
INSERT INTO recovery_procedures (
    scenario_name, failure_type, estimated_downtime, recovery_steps, required_resources, success_criteria
) VALUES (
    'Complete Server Hardware Failure',
    'Hardware',
    '2-4 hours',
    ARRAY[
        '1. Procure replacement hardware',
        '2. Install OS and PostgreSQL',
        '3. Restore latest base backup',
        '4. Apply WAL files up to failure point',
        '5. Verify data integrity',
        '6. Update DNS/network configuration',
        '7. Resume application services'
    ],
    ARRAY['Replacement server', 'Network access', 'Backup storage', 'Technical staff'],
    ARRAY['Database starts successfully', 'All tables accessible', 'Application connects', 'Data integrity verified']
);

-- Data corruption recovery
INSERT INTO recovery_procedures (
    scenario_name, failure_type, estimated_downtime, recovery_steps, required_resources, success_criteria
) VALUES (
    'Database Corruption',
    'Corruption',
    '1-2 hours',
    ARRAY[
        '1. Identify corruption extent',
        '2. Stop PostgreSQL service',
        '3. Backup current corrupted data',
        '4. Restore from clean backup',
        '5. Apply WAL up to corruption point',
        '6. Verify data consistency',
        '7. Restart services'
    ],
    ARRAY['Clean backup', 'WAL archives', 'Storage space', 'DBA access'],
    ARRAY['Database integrity check passes', 'All critical data present', 'Applications function normally']
);
```

### Lab 3: Backup Automation

```bash
# Exercise 3: Create comprehensive backup automation

# Master backup script
#!/bin/bash
# master_backup.sh

SCRIPT_DIR="/scripts/backup"
LOG_DIR="/var/log/postgresql/backup"
CONFIG_FILE="/etc/postgresql/backup.conf"

# Source configuration
source $CONFIG_FILE

# Create log file
LOG_FILE="$LOG_DIR/backup_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a $LOG_FILE)
exec 2>&1

echo "Starting backup process: $(date)"

# Determine backup type based on day
DAY_OF_WEEK=$(date +%u)  # 1=Monday, 7=Sunday
DAY_OF_MONTH=$(date +%d)

if [ "$DAY_OF_MONTH" = "01" ]; then
    # Monthly full backup
    echo "Performing monthly full backup"
    $SCRIPT_DIR/monthly_backup.sh
elif [ "$DAY_OF_WEEK" = "7" ]; then
    # Weekly full backup
    echo "Performing weekly full backup"
    $SCRIPT_DIR/weekly_backup.sh
else
    # Daily incremental backup
    echo "Performing daily incremental backup"
    $SCRIPT_DIR/daily_backup.sh
fi

# Verify backup
echo "Verifying backup integrity"
$SCRIPT_DIR/verify_backup.sh

# Cleanup old backups
echo "Cleaning up old backups"
$SCRIPT_DIR/cleanup_backups.sh

# Send notification
echo "Sending backup status notification"
$SCRIPT_DIR/send_notification.sh

echo "Backup process completed: $(date)"
```

## 5.8 Cloud Backup Strategies

### AWS RDS Backup Features
```yaml
# RDS Automated Backup Configuration
RDS_Configuration:
  BackupRetentionPeriod: 30  # days
  PreferredBackupWindow: "03:00-04:00"  # UTC
  PreferredMaintenanceWindow: "Sun:04:00-Sun:05:00"
  
  PointInTimeRecovery: enabled
  BackupWindow: "3:00 AM - 4:00 AM UTC"
  
  SnapshotConfiguration:
    ManualSnapshots: enabled
    AutomatedSnapshots: enabled
    SnapshotRetention: 30  # days
```

### Azure Database Backup
```yaml
# Azure PostgreSQL Backup Configuration
Azure_Configuration:
  BackupRetentionPeriod: 35  # days (7-35 range)
  BackupRedundancy: "Geo-redundant"  # Local, Zone, Geo
  
  PointInTimeRestore: enabled
  RestoreWindow: "Up to 35 days"
  
  LongTermRetention:
    WeeklyBackups: 12  # weeks
    MonthlyBackups: 60  # months
    YearlyBackups: 10   # years
```

### Hybrid Cloud Backup
```bash
#!/bin/bash
# hybrid_backup_sync.sh

LOCAL_BACKUP_DIR="/backup/postgresql"
S3_BUCKET="s3://company-db-backups"
AZURE_CONTAINER="https://storage.blob.core.windows.net/backups"

# Sync to AWS S3
aws s3 sync $LOCAL_BACKUP_DIR $S3_BUCKET --delete --storage-class STANDARD_IA

# Sync to Azure Blob Storage
az storage blob sync --source $LOCAL_BACKUP_DIR --container backups --account-name companystorage

# Verify uploads
aws s3 ls $S3_BUCKET --recursive | tail -10
az storage blob list --container-name backups --account-name companystorage | head -10

echo "Cloud backup sync completed: $(date)"
```

## Summary
In this module, we covered:
- Different types of database backups (logical, physical, continuous)
- Backup strategies for various scenarios
- Recovery concepts and procedures
- Business continuity and disaster recovery planning
- Backup scheduling and retention policies
- Backup testing and validation methods
- Practical exercises for backup planning
- Cloud backup strategies and hybrid approaches

## Next Module
[Module 6: Backup Tools and Procedures](07-backup-tools-procedures.md)
