# Module 6: Backup Tools and Procedures

## Learning Objectives
- Master pg_dump and pg_restore utilities
- Understand pg_dumpall for cluster-wide backups
- Learn pg_basebackup for physical backups
- Implement WAL archiving and continuous backup
- Use third-party backup tools and solutions
- Automate backup procedures with scripts

## 6.1 pg_dump - Logical Database Backup

### Basic pg_dump Usage

```bash
# Basic database dump
pg_dump -h hostname -U username -d database_name > backup.sql

# With password prompt
pg_dump -h localhost -U postgres -W -d myapp > myapp_backup.sql

# Specify output file directly
pg_dump -h localhost -U postgres -d myapp -f myapp_backup.sql

# Compressed output
pg_dump -h localhost -U postgres -d myapp | gzip > myapp_backup.sql.gz
```

### pg_dump Output Formats

```bash
# Plain SQL format (default)
pg_dump -h localhost -U postgres -d myapp -f myapp.sql

# Custom format (compressed, allows parallel restore)
pg_dump -h localhost -U postgres -d myapp -Fc -f myapp.dump

# Directory format (parallel backup and restore)
pg_dump -h localhost -U postgres -d myapp -Fd -f myapp_backup_dir

# Tar format
pg_dump -h localhost -U postgres -d myapp -Ft -f myapp.tar
```

### Selective Backup Options

```bash
# Backup specific tables
pg_dump -h localhost -U postgres -d myapp -t employees -t departments -f tables_backup.sql

# Backup specific schema
pg_dump -h localhost -U postgres -d myapp -n public -f public_schema.sql

# Exclude specific tables
pg_dump -h localhost -U postgres -d myapp -T logs -T temp_data -f app_without_logs.sql

# Exclude specific schemas
pg_dump -h localhost -U postgres -d myapp -N temp_schema -f production_data.sql

# Data only (no schema)
pg_dump -h localhost -U postgres -d myapp --data-only -f data_only.sql

# Schema only (no data)
pg_dump -h localhost -U postgres -d myapp --schema-only -f schema_only.sql

# Include/exclude specific object types
pg_dump -h localhost -U postgres -d myapp --exclude-table-data='audit_*' -f app_no_audit.sql
```

### Advanced pg_dump Options

```bash
# Parallel backup (directory format only)
pg_dump -h localhost -U postgres -d myapp -Fd -j 4 -f myapp_parallel

# Include large objects
pg_dump -h localhost -U postgres -d myapp --blobs -f myapp_with_blobs.sql

# Verbose output
pg_dump -h localhost -U postgres -d myapp -v -f myapp.sql

# Include INSERT statements instead of COPY
pg_dump -h localhost -U postgres -d myapp --inserts -f myapp_inserts.sql

# Include column names in INSERT statements
pg_dump -h localhost -U postgres -d myapp --column-inserts -f myapp_column_inserts.sql

# Disable triggers during restore
pg_dump -h localhost -U postgres -d myapp --disable-triggers -f myapp_no_triggers.sql

# Include ownership information
pg_dump -h localhost -U postgres -d myapp --no-owner --no-privileges -f myapp_no_ownership.sql
```

### Production pg_dump Script

```bash
#!/bin/bash
# production_pg_dump.sh

# Configuration
DB_HOST="localhost"
DB_USER="backup_user"
DB_NAME="production_db"
BACKUP_DIR="/backup/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

# Set environment variables
export PGPASSWORD="$DB_PASSWORD"

echo "Starting backup of $DB_NAME at $(date)"

# Full database backup
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME \
    -Fc \
    --verbose \
    --blobs \
    -f "$BACKUP_DIR/$DATE/${DB_NAME}_full_$DATE.dump"

if [ $? -eq 0 ]; then
    echo "✓ Full backup completed successfully"
    
    # Schema-only backup
    pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME \
        --schema-only \
        -f "$BACKUP_DIR/$DATE/${DB_NAME}_schema_$DATE.sql"
    
    # Data-only backup (for critical tables)
    pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME \
        --data-only \
        -t customers -t orders -t products \
        -Fc \
        -f "$BACKUP_DIR/$DATE/${DB_NAME}_critical_data_$DATE.dump"
    
    # Calculate backup size and checksum
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR/$DATE" | cut -f1)
    CHECKSUM=$(md5sum "$BACKUP_DIR/$DATE/${DB_NAME}_full_$DATE.dump" | cut -d' ' -f1)
    
    echo "✓ Backup size: $BACKUP_SIZE"
    echo "✓ Checksum: $CHECKSUM"
    
    # Log backup information
    echo "$DATE,$DB_NAME,$BACKUP_SIZE,$CHECKSUM,SUCCESS" >> "$BACKUP_DIR/backup_log.csv"
    
else
    echo "✗ Backup failed"
    echo "$DATE,$DB_NAME,,ERROR" >> "$BACKUP_DIR/backup_log.csv"
    exit 1
fi

# Cleanup old backups
find "$BACKUP_DIR" -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;

echo "Backup process completed at $(date)"
```

## 6.2 pg_restore - Restoring Logical Backups

### Basic pg_restore Usage

```bash
# Restore from custom format
pg_restore -h localhost -U postgres -d target_db backup.dump

# Restore with specific options
pg_restore -h localhost -U postgres -d target_db --verbose --clean backup.dump

# Create database and restore
pg_restore -h localhost -U postgres --create --dbname=postgres backup.dump
```

### Selective Restore Options

```bash
# List contents of backup file
pg_restore --list backup.dump

# Restore specific tables
pg_restore -h localhost -U postgres -d target_db -t employees -t departments backup.dump

# Restore specific schema
pg_restore -h localhost -U postgres -d target_db -n public backup.dump

# Restore data only
pg_restore -h localhost -U postgres -d target_db --data-only backup.dump

# Restore schema only
pg_restore -h localhost -U postgres -d target_db --schema-only backup.dump

# Restore with exclusions
pg_restore -h localhost -U postgres -d target_db -T audit_logs backup.dump
```

### Advanced pg_restore Options

```bash
# Parallel restore (faster for large databases)
pg_restore -h localhost -U postgres -d target_db -j 4 backup.dump

# Clean existing objects before restore
pg_restore -h localhost -U postgres -d target_db --clean backup.dump

# Don't restore ownership
pg_restore -h localhost -U postgres -d target_db --no-owner backup.dump

# Don't restore privileges
pg_restore -h localhost -U postgres -d target_db --no-privileges backup.dump

# Disable triggers during restore
pg_restore -h localhost -U postgres -d target_db --disable-triggers backup.dump

# Exit on error
pg_restore -h localhost -U postgres -d target_db --exit-on-error backup.dump

# Use single transaction
pg_restore -h localhost -U postgres -d target_db --single-transaction backup.dump
```

### Production Restore Script

```bash
#!/bin/bash
# production_restore.sh

# Configuration
SOURCE_BACKUP="$1"
TARGET_DB="$2"
DB_HOST="localhost"
DB_USER="postgres"

if [ -z "$SOURCE_BACKUP" ] || [ -z "$TARGET_DB" ]; then
    echo "Usage: $0 <backup_file> <target_database>"
    exit 1
fi

echo "Starting restore of $SOURCE_BACKUP to $TARGET_DB"

# Verify backup file exists
if [ ! -f "$SOURCE_BACKUP" ]; then
    echo "✗ Backup file not found: $SOURCE_BACKUP"
    exit 1
fi

# Create target database if it doesn't exist
psql -h $DB_HOST -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $TARGET_DB
if [ $? -ne 0 ]; then
    echo "Creating database $TARGET_DB"
    createdb -h $DB_HOST -U $DB_USER $TARGET_DB
fi

# Perform restore
echo "Restoring database..."
pg_restore -h $DB_HOST -U $DB_USER -d $TARGET_DB \
    --verbose \
    --clean \
    --no-owner \
    --no-privileges \
    --single-transaction \
    --exit-on-error \
    "$SOURCE_BACKUP"

if [ $? -eq 0 ]; then
    echo "✓ Restore completed successfully"
    
    # Verify restore
    TABLE_COUNT=$(psql -h $DB_HOST -U $DB_USER -d $TARGET_DB -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
    echo "✓ Restored $TABLE_COUNT tables"
    
else
    echo "✗ Restore failed"
    exit 1
fi
```

## 6.3 pg_dumpall - Cluster-wide Backup

### Basic pg_dumpall Usage

```bash
# Backup entire PostgreSQL cluster
pg_dumpall -h localhost -U postgres > cluster_backup.sql

# Backup with specific options
pg_dumpall -h localhost -U postgres --verbose > cluster_backup.sql

# Compressed cluster backup
pg_dumpall -h localhost -U postgres | gzip > cluster_backup.sql.gz
```

### Selective Cluster Backup

```bash
# Globals only (roles, tablespaces, etc.)
pg_dumpall -h localhost -U postgres --globals-only > globals_backup.sql

# Roles only
pg_dumpall -h localhost -U postgres --roles-only > roles_backup.sql

# Tablespaces only
pg_dumpall -h localhost -U postgres --tablespaces-only > tablespaces_backup.sql

# Schema only for all databases
pg_dumpall -h localhost -U postgres --schema-only > cluster_schema.sql
```

### Complete Cluster Backup Script

```bash
#!/bin/bash
# cluster_backup.sh

# Configuration
DB_HOST="localhost"
DB_USER="postgres"
BACKUP_DIR="/backup/postgresql/cluster"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR/$DATE"

echo "Starting cluster backup at $(date)"

# Full cluster backup
echo "Creating full cluster backup..."
pg_dumpall -h $DB_HOST -U $DB_USER --verbose > "$BACKUP_DIR/$DATE/cluster_full_$DATE.sql"

if [ $? -eq 0 ]; then
    echo "✓ Full cluster backup completed"
    
    # Separate globals backup
    echo "Creating globals backup..."
    pg_dumpall -h $DB_HOST -U $DB_USER --globals-only > "$BACKUP_DIR/$DATE/globals_$DATE.sql"
    
    # Individual database backups
    echo "Creating individual database backups..."
    DB_LIST=$(psql -h $DB_HOST -U $DB_USER -t -c "SELECT datname FROM pg_database WHERE datname NOT IN ('template0', 'template1');")
    
    for db in $DB_LIST; do
        echo "Backing up database: $db"
        pg_dump -h $DB_HOST -U $DB_USER -d $db -Fc > "$BACKUP_DIR/$DATE/${db}_$DATE.dump"
    done
    
    # Compress full backup
    gzip "$BACKUP_DIR/$DATE/cluster_full_$DATE.sql"
    
    echo "✓ Cluster backup completed successfully"
    
else
    echo "✗ Cluster backup failed"
    exit 1
fi
```

## 6.4 pg_basebackup - Physical Backup

### Basic pg_basebackup Usage

```bash
# Basic physical backup
pg_basebackup -h localhost -U replication_user -D /backup/base/backup_20240125

# With progress reporting
pg_basebackup -h localhost -U replication_user -D /backup/base/backup_20240125 -P

# Verbose output
pg_basebackup -h localhost -U replication_user -D /backup/base/backup_20240125 -v

# Include WAL files
pg_basebackup -h localhost -U replication_user -D /backup/base/backup_20240125 -X stream
```

### pg_basebackup Output Formats

```bash
# Plain format (default)
pg_basebackup -h localhost -U replication_user -D /backup/base/backup_20240125

# Tar format
pg_basebackup -h localhost -U replication_user -D /backup/base -Ft

# Compressed tar format
pg_basebackup -h localhost -U replication_user -D /backup/base -Ft -z

# Separate tablespace directories
pg_basebackup -h localhost -U replication_user -D /backup/base -T /old/path=/new/path
```

### Production pg_basebackup Script

```bash
#!/bin/bash
# basebackup.sh

# Configuration
DB_HOST="localhost"
REPL_USER="replication_user"
BACKUP_DIR="/backup/postgresql/base"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

echo "Starting base backup at $(date)"

# Perform base backup
pg_basebackup -h $DB_HOST -U $REPL_USER \
    -D "$BACKUP_DIR/$DATE" \
    -Ft -z \
    -X stream \
    -P -v \
    -W

if [ $? -eq 0 ]; then
    echo "✓ Base backup completed successfully"
    
    # Create backup manifest
    cat > "$BACKUP_DIR/$DATE/backup_manifest.txt" << EOF
Backup Date: $DATE
Backup Type: Physical (pg_basebackup)
Source Host: $DB_HOST
Backup Size: $(du -sh "$BACKUP_DIR/$DATE" | cut -f1)
WAL Included: Yes (streaming)
Compression: Yes (gzip)
EOF
    
    # Log backup information
    BACKUP_SIZE=$(du -sb "$BACKUP_DIR/$DATE" | cut -f1)
    echo "$DATE,base_backup,$BACKUP_SIZE,SUCCESS" >> "$BACKUP_DIR/../backup_log.csv"
    
else
    echo "✗ Base backup failed"
    exit 1
fi

# Cleanup old backups
find "$BACKUP_DIR" -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;

echo "Base backup process completed at $(date)"
```

## 6.5 WAL Archiving and Continuous Backup

### WAL Archiving Configuration

```ini
# postgresql.conf - WAL archiving setup
wal_level = replica                    # Enable WAL archiving
archive_mode = on                      # Turn on archiving
archive_command = 'cp %p /backup/wal_archive/%f'  # Archive command
archive_timeout = 300                  # Force archive every 5 minutes

# Additional settings for reliability
max_wal_senders = 3                    # For replication
wal_keep_segments = 64                 # Keep WAL files (PostgreSQL < 13)
# wal_keep_size = '1GB'                # Keep WAL files (PostgreSQL >= 13)
```

### Advanced WAL Archive Script

```bash
#!/bin/bash
# archive_wal.sh
# Usage: archive_wal.sh %p %f (called by PostgreSQL)

WAL_PATH="$1"
WAL_FILE="$2"
ARCHIVE_DIR="/backup/wal_archive"
LOG_FILE="/var/log/postgresql/wal_archive.log"

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Log archive attempt
echo "$(date): Archiving $WAL_FILE" >> "$LOG_FILE"

# Copy WAL file to archive
if cp "$WAL_PATH" "$ARCHIVE_DIR/$WAL_FILE"; then
    echo "$(date): Successfully archived $WAL_FILE" >> "$LOG_FILE"
    
    # Verify copy
    if [ -f "$ARCHIVE_DIR/$WAL_FILE" ]; then
        # Optional: Create checksum
        md5sum "$ARCHIVE_DIR/$WAL_FILE" > "$ARCHIVE_DIR/${WAL_FILE}.md5"
        exit 0
    else
        echo "$(date): Archive verification failed for $WAL_FILE" >> "$LOG_FILE"
        exit 1
    fi
else
    echo "$(date): Failed to archive $WAL_FILE" >> "$LOG_FILE"
    exit 1
fi
```

### WAL Archive Cleanup Script

```bash
#!/bin/bash
# cleanup_wal_archive.sh

ARCHIVE_DIR="/backup/wal_archive"
BACKUP_DIR="/backup/base"
RETENTION_DAYS=7

echo "Starting WAL archive cleanup at $(date)"

# Find oldest base backup
OLDEST_BACKUP=$(find "$BACKUP_DIR" -name "20*" -type d | sort | head -1)

if [ -n "$OLDEST_BACKUP" ]; then
    # Get backup date from directory name
    BACKUP_DATE=$(basename "$OLDEST_BACKUP")
    echo "Oldest base backup: $BACKUP_DATE"
    
    # Find WAL files older than oldest backup minus retention period
    CUTOFF_DATE=$(date -d "$BACKUP_DATE - $RETENTION_DAYS days" +%Y%m%d)
    echo "Cleaning WAL files older than: $CUTOFF_DATE"
    
    # Remove old WAL files
    find "$ARCHIVE_DIR" -name "*.wal" -o -name "*.partial" | while read wal_file; do
        WAL_DATE=$(stat -c %Y "$wal_file")
        WAL_DATE_STR=$(date -d "@$WAL_DATE" +%Y%m%d)
        
        if [ "$WAL_DATE_STR" -lt "$CUTOFF_DATE" ]; then
            echo "Removing old WAL file: $(basename "$wal_file")"
            rm -f "$wal_file" "${wal_file}.md5"
        fi
    done
    
else
    echo "No base backups found, keeping all WAL files"
fi

echo "WAL archive cleanup completed at $(date)"
```

## 6.6 Third-Party Backup Tools

### pgBackRest Configuration

```ini
# pgbackrest.conf
[global]
repo1-path=/backup/pgbackrest
repo1-retention-full=2
repo1-retention-diff=4
repo1-retention-archive=7
log-level-console=info
log-level-file=debug

[main]
pg1-path=/var/lib/postgresql/data
pg1-port=5432
pg1-user=postgres
```

```bash
# pgBackRest usage examples

# Full backup
pgbackrest --stanza=main backup --type=full

# Differential backup
pgbackrest --stanza=main backup --type=diff

# Incremental backup
pgbackrest --stanza=main backup --type=incr

# List backups
pgbackrest --stanza=main info

# Restore latest backup
pgbackrest --stanza=main restore

# Point-in-time restore
pgbackrest --stanza=main restore --type=time --target="2024-01-25 14:30:00"
```

### Barman (Backup and Recovery Manager)

```ini
# barman.conf
[barman]
barman_user = barman
configuration_files_directory = /etc/barman.d
barman_home = /var/lib/barman
log_file = /var/log/barman/barman.log
log_level = INFO

[main]
description = "Main Production Database"
conninfo = host=localhost user=postgres dbname=postgres
streaming_conninfo = host=localhost user=streaming_barman dbname=postgres
backup_method = rsync
streaming_archiver = on
slot_name = barman
```

```bash
# Barman usage examples

# Check server configuration
barman check main

# Perform backup
barman backup main

# List backups
barman list-backup main

# Show backup details
barman show-backup main latest

# Restore backup
barman recover main latest /var/lib/postgresql/recovery

# Point-in-time recovery
barman recover main latest /var/lib/postgresql/recovery --target-time "2024-01-25 14:30:00"
```

### wal-e for Cloud Backup

```bash
# wal-e configuration for AWS S3
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export WALE_S3_PREFIX="s3://your-bucket/wal-e"

# PostgreSQL configuration for wal-e
# archive_command = 'wal-e wal-push %p'
# restore_command = 'wal-e wal-fetch %f %p'

# Create base backup
wal-e backup-push /var/lib/postgresql/data

# List backups
wal-e backup-list

# Restore backup
wal-e backup-fetch /var/lib/postgresql/recovery LATEST
```

## 6.7 Practical Lab Exercises

### Lab 1: Complete Backup Solution

```bash
#!/bin/bash
# Lab Exercise 1: Implement complete backup solution

# Create lab environment
psql -U postgres -c "CREATE DATABASE backup_lab;"
psql -U postgres -d backup_lab << EOF
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    amount DECIMAL(10,2),
    order_date DATE DEFAULT CURRENT_DATE
);

INSERT INTO customers (name, email) VALUES 
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Bob Wilson', 'bob@example.com');

INSERT INTO orders (customer_id, amount) VALUES 
    (1, 100.50),
    (1, 250.00),
    (2, 75.25),
    (3, 500.00);
EOF

# Exercise tasks:
# 1. Create full logical backup
pg_dump -h localhost -U postgres -d backup_lab -Fc -f backup_lab_full.dump

# 2. Create schema-only backup
pg_dump -h localhost -U postgres -d backup_lab --schema-only -f backup_lab_schema.sql

# 3. Create data-only backup
pg_dump -h localhost -U postgres -d backup_lab --data-only -Fc -f backup_lab_data.dump

# 4. Create selective backup (customers table only)
pg_dump -h localhost -U postgres -d backup_lab -t customers -f backup_lab_customers.sql

# 5. Test restore
createdb -U postgres backup_lab_test
pg_restore -h localhost -U postgres -d backup_lab_test backup_lab_full.dump
```

### Lab 2: WAL Archiving Setup

```bash
# Lab Exercise 2: Set up WAL archiving

# Create WAL archive directory
sudo mkdir -p /backup/wal_archive
sudo chown postgres:postgres /backup/wal_archive

# Create archive script
cat > /backup/archive_wal.sh << 'EOF'
#!/bin/bash
WAL_PATH="$1"
WAL_FILE="$2"
ARCHIVE_DIR="/backup/wal_archive"

cp "$WAL_PATH" "$ARCHIVE_DIR/$WAL_FILE" && exit 0 || exit 1
EOF

chmod +x /backup/archive_wal.sh

# Configure PostgreSQL for WAL archiving
psql -U postgres << EOF
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET archive_mode = 'on';
ALTER SYSTEM SET archive_command = '/backup/archive_wal.sh %p %f';
SELECT pg_reload_conf();
EOF

# Create base backup
pg_basebackup -U postgres -D /backup/base/$(date +%Y%m%d_%H%M%S) -Ft -z -X stream -P

# Generate some WAL activity
psql -U postgres -d backup_lab << EOF
INSERT INTO customers (name, email) VALUES ('Test User', 'test@example.com');
SELECT pg_switch_wal();  -- Force WAL switch
EOF

# Verify WAL files are being archived
ls -la /backup/wal_archive/
```

### Lab 3: Automated Backup System

```bash
#!/bin/bash
# Lab Exercise 3: Create automated backup system

# Create backup configuration
cat > /etc/postgresql/backup_config.conf << EOF
# Backup Configuration
DB_HOST="localhost"
DB_USER="postgres"
BACKUP_ROOT="/backup/postgresql"
RETENTION_DAILY=7
RETENTION_WEEKLY=4
RETENTION_MONTHLY=6

# Databases to backup
DATABASES="backup_lab postgres"

# Notification settings
NOTIFICATION_EMAIL="admin@company.com"
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
EOF

# Create master backup script
cat > /scripts/automated_backup.sh << 'EOF'
#!/bin/bash
source /etc/postgresql/backup_config.conf

DATE=$(date +%Y%m%d_%H%M%S)
DAY_OF_WEEK=$(date +%u)
DAY_OF_MONTH=$(date +%d)

# Determine backup type
if [ "$DAY_OF_MONTH" = "01" ]; then
    BACKUP_TYPE="monthly"
    BACKUP_DIR="$BACKUP_ROOT/monthly/$DATE"
elif [ "$DAY_OF_WEEK" = "7" ]; then
    BACKUP_TYPE="weekly"
    BACKUP_DIR="$BACKUP_ROOT/weekly/$DATE"
else
    BACKUP_TYPE="daily"
    BACKUP_DIR="$BACKUP_ROOT/daily/$DATE"
fi

mkdir -p "$BACKUP_DIR"

echo "Starting $BACKUP_TYPE backup at $(date)"

# Backup each database
for db in $DATABASES; do
    echo "Backing up database: $db"
    
    pg_dump -h $DB_HOST -U $DB_USER -d $db \
        -Fc --verbose \
        -f "$BACKUP_DIR/${db}_${BACKUP_TYPE}_$DATE.dump"
    
    if [ $? -eq 0 ]; then
        echo "✓ $db backup completed"
    else
        echo "✗ $db backup failed"
        # Send alert
        echo "Backup failed for $db on $(date)" | mail -s "Backup Alert" $NOTIFICATION_EMAIL
    fi
done

# Cleanup old backups based on retention policy
case $BACKUP_TYPE in
    daily)
        find "$BACKUP_ROOT/daily" -type d -mtime +$RETENTION_DAILY -exec rm -rf {} \;
        ;;
    weekly)
        find "$BACKUP_ROOT/weekly" -type d -mtime +$((RETENTION_WEEKLY * 7)) -exec rm -rf {} \;
        ;;
    monthly)
        find "$BACKUP_ROOT/monthly" -type d -mtime +$((RETENTION_MONTHLY * 30)) -exec rm -rf {} \;
        ;;
esac

echo "$BACKUP_TYPE backup completed at $(date)"
EOF

chmod +x /scripts/automated_backup.sh

# Create cron job
echo "0 2 * * * postgres /scripts/automated_backup.sh" | sudo tee -a /etc/crontab

# Test the backup system
/scripts/automated_backup.sh
```

## 6.8 Backup Monitoring and Alerting

### Backup Status Monitoring

```sql
-- Create backup monitoring table
CREATE TABLE backup_status (
    id SERIAL PRIMARY KEY,
    backup_date DATE,
    backup_type VARCHAR(20),
    database_name VARCHAR(100),
    backup_size BIGINT,
    duration INTERVAL,
    status VARCHAR(20),
    error_message TEXT,
    checksum VARCHAR(64)
);

-- Function to log backup status
CREATE OR REPLACE FUNCTION log_backup_status(
    p_backup_type VARCHAR,
    p_database_name VARCHAR,
    p_backup_size BIGINT,
    p_duration INTERVAL,
    p_status VARCHAR,
    p_error_message TEXT DEFAULT NULL,
    p_checksum VARCHAR DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO backup_status (
        backup_date, backup_type, database_name, backup_size,
        duration, status, error_message, checksum
    ) VALUES (
        CURRENT_DATE, p_backup_type, p_database_name, p_backup_size,
        p_duration, p_status, p_error_message, p_checksum
    );
END;
$$ LANGUAGE plpgsql;

-- View backup history
SELECT 
    backup_date,
    backup_type,
    database_name,
    pg_size_pretty(backup_size) as size,
    duration,
    status
FROM backup_status
ORDER BY backup_date DESC, database_name;
```

### Automated Backup Verification

```bash
#!/bin/bash
# verify_backups.sh

BACKUP_DIR="/backup/postgresql"
LOG_FILE="/var/log/postgresql/backup_verification.log"

echo "Starting backup verification at $(date)" >> "$LOG_FILE"

# Find all backup files from last 24 hours
find "$BACKUP_DIR" -name "*.dump" -mtime -1 | while read backup_file; do
    echo "Verifying: $backup_file" >> "$LOG_FILE"
    
    # Check file integrity
    if [ -f "$backup_file" ]; then
        # Verify pg_dump file header
        if pg_restore --list "$backup_file" > /dev/null 2>&1; then
            echo "✓ $backup_file - Header verification passed" >> "$LOG_FILE"
            
            # Optional: Test restore to temporary database
            TEST_DB="verify_$(basename "$backup_file" .dump)_$(date +%H%M%S)"
            
            if createdb "$TEST_DB" 2>/dev/null; then
                if pg_restore -d "$TEST_DB" "$backup_file" > /dev/null 2>&1; then
                    echo "✓ $backup_file - Restore test passed" >> "$LOG_FILE"
                else
                    echo "✗ $backup_file - Restore test failed" >> "$LOG_FILE"
                fi
                dropdb "$TEST_DB" 2>/dev/null
            fi
            
        else
            echo "✗ $backup_file - Header verification failed" >> "$LOG_FILE"
        fi
    else
        echo "✗ $backup_file - File not found" >> "$LOG_FILE"
    fi
done

echo "Backup verification completed at $(date)" >> "$LOG_FILE"
```

## Summary
In this module, we covered:
- pg_dump utility for logical backups with various formats and options
- pg_restore for flexible restoration of logical backups
- pg_dumpall for cluster-wide backups including globals
- pg_basebackup for physical backups and replication setup
- WAL archiving for continuous backup and point-in-time recovery
- Third-party backup tools like pgBackRest, Barman, and wal-e
- Practical exercises for implementing complete backup solutions
- Backup monitoring, verification, and alerting systems

## Next Module
[Module 7: Recovery Procedures](08-recovery-procedures.md)
