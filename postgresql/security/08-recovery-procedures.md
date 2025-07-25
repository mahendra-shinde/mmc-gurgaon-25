# Module 7: Recovery Procedures

## Learning Objectives
- Perform complete database recovery from backups
- Execute point-in-time recovery (PITR) procedures
- Handle disaster recovery scenarios
- Implement standby server recovery
- Troubleshoot recovery issues and validate recovered data
- Create recovery documentation and procedures

## 7.1 Recovery Fundamentals

### Recovery Scenarios

#### 1. Complete Database Loss
Total loss of database due to hardware failure, corruption, or deletion.

**Recovery Strategy:**
- Restore from most recent full backup
- Apply incremental backups or WAL files
- Minimize data loss and downtime

#### 2. Point-in-Time Recovery
Need to recover to specific time before data corruption or human error.

**Recovery Strategy:**
- Restore base backup taken before target time
- Apply WAL files up to target time
- Precise recovery to avoid including problematic changes

#### 3. Partial Recovery
Recovery of specific tables, schemas, or data subsets.

**Recovery Strategy:**
- Restore full backup to temporary location
- Extract required data
- Import into production system

#### 4. Standby Server Recovery
Bringing standby server online after primary failure.

**Recovery Strategy:**
- Promote standby to primary
- Update application connection strings
- Rebuild replication if needed

## 7.2 Complete Database Recovery

### Recovery from Logical Backup

```bash
#!/bin/bash
# complete_recovery_logical.sh

# Configuration
SOURCE_BACKUP="$1"
TARGET_DB="$2"
DB_HOST="localhost"
DB_USER="postgres"
RECOVERY_LOG="/var/log/postgresql/recovery_$(date +%Y%m%d_%H%M%S).log"

if [ -z "$SOURCE_BACKUP" ] || [ -z "$TARGET_DB" ]; then
    echo "Usage: $0 <backup_file> <target_database>"
    exit 1
fi

exec 1> >(tee -a $RECOVERY_LOG)
exec 2>&1

echo "=== Complete Database Recovery Started ===" 
echo "Date: $(date)"
echo "Source backup: $SOURCE_BACKUP"
echo "Target database: $TARGET_DB"
echo "Recovery log: $RECOVERY_LOG"

# Step 1: Verify backup file
echo "Step 1: Verifying backup file..."
if [ ! -f "$SOURCE_BACKUP" ]; then
    echo "ERROR: Backup file not found: $SOURCE_BACKUP"
    exit 1
fi

# Check backup integrity
if pg_restore --list "$SOURCE_BACKUP" > /dev/null 2>&1; then
    echo "✓ Backup file integrity verified"
else
    echo "ERROR: Backup file appears corrupted"
    exit 1
fi

# Step 2: Stop applications (if needed)
echo "Step 2: Stopping applications..."
# systemctl stop application_service

# Step 3: Backup current database (if exists)
echo "Step 3: Backing up current database..."
DB_EXISTS=$(psql -h $DB_HOST -U $DB_USER -lqt | cut -d \| -f 1 | grep -w $TARGET_DB | wc -l)

if [ $DB_EXISTS -gt 0 ]; then
    BACKUP_NAME="${TARGET_DB}_pre_recovery_$(date +%Y%m%d_%H%M%S).dump"
    echo "Creating safety backup: $BACKUP_NAME"
    pg_dump -h $DB_HOST -U $DB_USER -d $TARGET_DB -Fc -f "/backup/safety/$BACKUP_NAME"
    
    # Drop existing database
    echo "Dropping existing database..."
    psql -h $DB_HOST -U $DB_USER -c "DROP DATABASE $TARGET_DB;"
fi

# Step 4: Create new database
echo "Step 4: Creating target database..."
createdb -h $DB_HOST -U $DB_USER $TARGET_DB

if [ $? -eq 0 ]; then
    echo "✓ Database $TARGET_DB created successfully"
else
    echo "ERROR: Failed to create database $TARGET_DB"
    exit 1
fi

# Step 5: Restore from backup
echo "Step 5: Restoring from backup..."
START_TIME=$(date +%s)

pg_restore -h $DB_HOST -U $DB_USER -d $TARGET_DB \
    --verbose \
    --single-transaction \
    --exit-on-error \
    "$SOURCE_BACKUP"

if [ $? -eq 0 ]; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    echo "✓ Restore completed successfully in $DURATION seconds"
else
    echo "ERROR: Restore failed"
    exit 1
fi

# Step 6: Verify recovery
echo "Step 6: Verifying recovery..."
TABLE_COUNT=$(psql -h $DB_HOST -U $DB_USER -d $TARGET_DB -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
echo "✓ Verified $TABLE_COUNT tables restored"

# Test database connectivity
if psql -h $DB_HOST -U $DB_USER -d $TARGET_DB -c "SELECT version();" > /dev/null 2>&1; then
    echo "✓ Database connectivity verified"
else
    echo "ERROR: Database connectivity test failed"
    exit 1
fi

# Step 7: Update statistics
echo "Step 7: Updating database statistics..."
psql -h $DB_HOST -U $DB_USER -d $TARGET_DB -c "ANALYZE;"

# Step 8: Restart applications
echo "Step 8: Restarting applications..."
# systemctl start application_service

echo "=== Complete Database Recovery Completed ==="
echo "Recovery completed at: $(date)"
```

### Recovery from Physical Backup

```bash
#!/bin/bash
# complete_recovery_physical.sh

# Configuration
BACKUP_DIR="$1"
POSTGRES_DATA_DIR="/var/lib/postgresql/data"
WAL_ARCHIVE_DIR="/backup/wal_archive"
RECOVERY_TARGET="$2"  # Optional: 'latest', timestamp, or xid

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 <backup_directory> [recovery_target]"
    exit 1
fi

echo "=== Physical Database Recovery Started ==="
echo "Date: $(date)"
echo "Backup directory: $BACKUP_DIR"
echo "Data directory: $POSTGRES_DATA_DIR"
echo "Recovery target: ${RECOVERY_TARGET:-latest}"

# Step 1: Stop PostgreSQL
echo "Step 1: Stopping PostgreSQL..."
systemctl stop postgresql

# Step 2: Backup current data directory
echo "Step 2: Backing up current data directory..."
if [ -d "$POSTGRES_DATA_DIR" ]; then
    mv "$POSTGRES_DATA_DIR" "${POSTGRES_DATA_DIR}_pre_recovery_$(date +%Y%m%d_%H%M%S)"
fi

# Step 3: Restore base backup
echo "Step 3: Restoring base backup..."
mkdir -p "$POSTGRES_DATA_DIR"

if [ -f "$BACKUP_DIR/base.tar.gz" ]; then
    # Restore from compressed tar
    tar -xzf "$BACKUP_DIR/base.tar.gz" -C "$POSTGRES_DATA_DIR"
elif [ -d "$BACKUP_DIR" ]; then
    # Copy from directory backup
    cp -r "$BACKUP_DIR"/* "$POSTGRES_DATA_DIR"/
else
    echo "ERROR: Invalid backup format"
    exit 1
fi

# Set proper ownership
chown -R postgres:postgres "$POSTGRES_DATA_DIR"

# Step 4: Configure recovery
echo "Step 4: Configuring recovery..."

# PostgreSQL 12+
cat > "$POSTGRES_DATA_DIR/recovery.signal" << EOF
# Recovery configuration
EOF

# Add recovery configuration to postgresql.conf
cat >> "$POSTGRES_DATA_DIR/postgresql.conf" << EOF

# Recovery settings
restore_command = 'cp $WAL_ARCHIVE_DIR/%f %p'
recovery_target_action = 'promote'
EOF

# Configure recovery target if specified
if [ -n "$RECOVERY_TARGET" ] && [ "$RECOVERY_TARGET" != "latest" ]; then
    if [[ "$RECOVERY_TARGET" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        # Timestamp recovery
        echo "recovery_target_time = '$RECOVERY_TARGET'" >> "$POSTGRES_DATA_DIR/postgresql.conf"
    elif [[ "$RECOVERY_TARGET" =~ ^[0-9]+$ ]]; then
        # Transaction ID recovery
        echo "recovery_target_xid = '$RECOVERY_TARGET'" >> "$POSTGRES_DATA_DIR/postgresql.conf"
    fi
fi

# Step 5: Start PostgreSQL
echo "Step 5: Starting PostgreSQL for recovery..."
systemctl start postgresql

# Step 6: Monitor recovery progress
echo "Step 6: Monitoring recovery progress..."
while true; do
    if pg_isready > /dev/null 2>&1; then
        echo "✓ PostgreSQL is ready"
        break
    else
        echo "Waiting for recovery to complete..."
        sleep 5
    fi
done

# Step 7: Verify recovery
echo "Step 7: Verifying recovery..."
RECOVERY_INFO=$(psql -U postgres -t -c "SELECT pg_is_in_recovery(), pg_last_wal_replay_lsn();")
echo "Recovery status: $RECOVERY_INFO"

echo "=== Physical Database Recovery Completed ==="
```

## 7.3 Point-in-Time Recovery (PITR)

### PITR Prerequisites

```sql
-- Check WAL archiving status
SELECT 
    name,
    setting,
    context
FROM pg_settings 
WHERE name IN ('wal_level', 'archive_mode', 'archive_command');

-- Check current WAL position
SELECT pg_current_wal_lsn();

-- Check WAL archive status
SELECT 
    archived_count,
    last_archived_wal,
    last_archived_time,
    failed_count,
    last_failed_wal,
    last_failed_time
FROM pg_stat_archiver;
```

### PITR Recovery Script

```bash
#!/bin/bash
# pitr_recovery.sh

# Configuration
BASE_BACKUP_DIR="$1"
TARGET_TIME="$2"
POSTGRES_DATA_DIR="/var/lib/postgresql/data"
WAL_ARCHIVE_DIR="/backup/wal_archive"
RECOVERY_LOG="/var/log/postgresql/pitr_recovery_$(date +%Y%m%d_%H%M%S).log"

if [ -z "$BASE_BACKUP_DIR" ] || [ -z "$TARGET_TIME" ]; then
    echo "Usage: $0 <base_backup_directory> <target_time>"
    echo "Example: $0 /backup/base/20240125_020000 '2024-01-25 14:30:00'"
    exit 1
fi

exec 1> >(tee -a $RECOVERY_LOG)
exec 2>&1

echo "=== Point-in-Time Recovery Started ==="
echo "Date: $(date)"
echo "Base backup: $BASE_BACKUP_DIR"
echo "Target time: $TARGET_TIME"
echo "Data directory: $POSTGRES_DATA_DIR"
echo "WAL archive: $WAL_ARCHIVE_DIR"

# Step 1: Validate inputs
echo "Step 1: Validating inputs..."

# Check if base backup exists
if [ ! -d "$BASE_BACKUP_DIR" ]; then
    echo "ERROR: Base backup directory not found: $BASE_BACKUP_DIR"
    exit 1
fi

# Validate target time format
if ! date -d "$TARGET_TIME" > /dev/null 2>&1; then
    echo "ERROR: Invalid target time format: $TARGET_TIME"
    echo "Use format: 'YYYY-MM-DD HH:MM:SS'"
    exit 1
fi

# Check WAL archive directory
if [ ! -d "$WAL_ARCHIVE_DIR" ]; then
    echo "ERROR: WAL archive directory not found: $WAL_ARCHIVE_DIR"
    exit 1
fi

# Step 2: Stop PostgreSQL
echo "Step 2: Stopping PostgreSQL..."
systemctl stop postgresql

# Wait for PostgreSQL to stop
sleep 5

# Step 3: Backup current data directory
echo "Step 3: Backing up current data directory..."
if [ -d "$POSTGRES_DATA_DIR" ]; then
    BACKUP_NAME="data_pre_pitr_$(date +%Y%m%d_%H%M%S)"
    mv "$POSTGRES_DATA_DIR" "/backup/safety/$BACKUP_NAME"
    echo "Current data backed up to: /backup/safety/$BACKUP_NAME"
fi

# Step 4: Restore base backup
echo "Step 4: Restoring base backup..."
mkdir -p "$POSTGRES_DATA_DIR"

if [ -f "$BASE_BACKUP_DIR/base.tar.gz" ]; then
    tar -xzf "$BASE_BACKUP_DIR/base.tar.gz" -C "$POSTGRES_DATA_DIR"
elif [ -f "$BASE_BACKUP_DIR"/*.tar.gz ]; then
    for tar_file in "$BASE_BACKUP_DIR"/*.tar.gz; do
        tar -xzf "$tar_file" -C "$POSTGRES_DATA_DIR"
    done
else
    cp -r "$BASE_BACKUP_DIR"/* "$POSTGRES_DATA_DIR"/
fi

# Set ownership
chown -R postgres:postgres "$POSTGRES_DATA_DIR"

# Step 5: Configure PITR recovery
echo "Step 5: Configuring PITR recovery..."

# Create recovery.signal file (PostgreSQL 12+)
touch "$POSTGRES_DATA_DIR/recovery.signal"

# Configure recovery in postgresql.conf
cat >> "$POSTGRES_DATA_DIR/postgresql.conf" << EOF

# Point-in-Time Recovery Configuration
restore_command = 'cp $WAL_ARCHIVE_DIR/%f %p'
recovery_target_time = '$TARGET_TIME'
recovery_target_action = 'pause'
recovery_target_inclusive = false
EOF

# Step 6: Start PostgreSQL for recovery
echo "Step 6: Starting PostgreSQL for PITR..."
systemctl start postgresql

# Step 7: Monitor recovery progress
echo "Step 7: Monitoring PITR progress..."
TIMEOUT=300  # 5 minutes timeout
COUNTER=0

while [ $COUNTER -lt $TIMEOUT ]; do
    if pg_isready > /dev/null 2>&1; then
        # Check if recovery is paused at target
        RECOVERY_STATUS=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | tr -d ' ')
        if [ "$RECOVERY_STATUS" = "t" ]; then
            echo "✓ Recovery paused at target time"
            break
        elif [ "$RECOVERY_STATUS" = "f" ]; then
            echo "✓ Recovery completed and promoted"
            break
        fi
    fi
    
    echo "Waiting for PITR to reach target time... ($COUNTER/$TIMEOUT)"
    sleep 5
    COUNTER=$((COUNTER + 5))
done

if [ $COUNTER -ge $TIMEOUT ]; then
    echo "ERROR: PITR recovery timeout"
    exit 1
fi

# Step 8: Verify recovery point
echo "Step 8: Verifying recovery point..."
CURRENT_TIME=$(psql -U postgres -t -c "SELECT now();" | tr -d ' ')
echo "Database current time: $CURRENT_TIME"

# Check last replayed WAL
LAST_WAL=$(psql -U postgres -t -c "SELECT pg_last_wal_replay_lsn();" | tr -d ' ')
echo "Last replayed WAL LSN: $LAST_WAL"

# Step 9: Promote if recovery paused
RECOVERY_STATUS=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" | tr -d ' ')
if [ "$RECOVERY_STATUS" = "t" ]; then
    echo "Step 9: Promoting database..."
    psql -U postgres -c "SELECT pg_promote();"
    
    # Wait for promotion
    while true; do
        RECOVERY_STATUS=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | tr -d ' ')
        if [ "$RECOVERY_STATUS" = "f" ]; then
            echo "✓ Database promoted successfully"
            break
        fi
        sleep 2
    done
fi

# Step 10: Final verification
echo "Step 10: Final verification..."
DB_VERSION=$(psql -U postgres -t -c "SELECT version();" | head -1)
echo "Database version: $DB_VERSION"

# Test basic operations
psql -U postgres -c "SELECT 'PITR Recovery Test' as status;"

echo "=== Point-in-Time Recovery Completed ==="
echo "Recovery completed at: $(date)"
echo "Database recovered to: $TARGET_TIME"
```

### PITR Recovery Validation

```sql
-- Verify recovery point
SELECT 
    'Recovery Point Validation' as check_type,
    now() as current_time,
    pg_last_wal_replay_lsn() as last_wal_lsn,
    pg_is_in_recovery() as in_recovery;

-- Check timeline
SELECT 
    'Timeline Information' as check_type,
    pg_control_checkpoint() ->> 'timeline_id' as timeline_id,
    pg_control_checkpoint() ->> 'redo_lsn' as redo_lsn;

-- Verify data consistency
-- (Application-specific queries to verify data state)
```

## 7.4 Disaster Recovery Procedures

### Complete Site Disaster Recovery

```bash
#!/bin/bash
# disaster_recovery.sh

# Disaster Recovery Configuration
DR_SITE_CONFIG="/etc/postgresql/dr_config.conf"
source "$DR_SITE_CONFIG"

RECOVERY_LOG="/var/log/postgresql/dr_recovery_$(date +%Y%m%d_%H%M%S).log"

exec 1> >(tee -a $RECOVERY_LOG)
exec 2>&1

echo "=== DISASTER RECOVERY PROCEDURE ==="
echo "Date: $(date)"
echo "DR Site: $DR_SITE_NAME"
echo "Primary Site: $PRIMARY_SITE_NAME"

# Step 1: Assess disaster scope
echo "Step 1: Assessing disaster scope..."
echo "Disaster type: $DISASTER_TYPE"
echo "Estimated RTO: $RTO_HOURS hours"
echo "Estimated RPO: $RPO_MINUTES minutes"

# Step 2: Activate DR site infrastructure
echo "Step 2: Activating DR site infrastructure..."

# Start DR servers if needed
if [ "$DR_INFRASTRUCTURE_AUTO" = "true" ]; then
    echo "Starting DR infrastructure automatically..."
    # AWS: aws ec2 start-instances --instance-ids $DR_INSTANCE_IDS
    # Azure: az vm start --ids $DR_VM_IDS
    # VMware: powerOn DR VMs
fi

# Step 3: Verify DR database status
echo "Step 3: Verifying DR database status..."

if systemctl is-active postgresql > /dev/null 2>&1; then
    echo "PostgreSQL is running on DR site"
    
    # Check if it's a standby
    IS_STANDBY=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" | tr -d ' ')
    if [ "$IS_STANDBY" = "t" ]; then
        echo "Database is in standby mode - will promote"
        PROMOTE_NEEDED=true
    else
        echo "Database is already promoted"
        PROMOTE_NEEDED=false
    fi
else
    echo "PostgreSQL is not running - starting recovery"
    START_NEEDED=true
fi

# Step 4: Promote standby to primary (if needed)
if [ "$PROMOTE_NEEDED" = "true" ]; then
    echo "Step 4: Promoting standby to primary..."
    
    # Promote the standby
    psql -U postgres -c "SELECT pg_promote();"
    
    # Wait for promotion to complete
    TIMEOUT=120
    COUNTER=0
    while [ $COUNTER -lt $TIMEOUT ]; do
        IS_RECOVERY=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | tr -d ' ')
        if [ "$IS_RECOVERY" = "f" ]; then
            echo "✓ Standby promoted to primary successfully"
            break
        fi
        sleep 2
        COUNTER=$((COUNTER + 2))
    done
    
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo "ERROR: Promotion timeout"
        exit 1
    fi
fi

# Step 5: Update network configuration
echo "Step 5: Updating network configuration..."

# Update DNS to point to DR site
if [ "$AUTO_DNS_UPDATE" = "true" ]; then
    echo "Updating DNS records..."
    # Update DNS A record to point to DR site IP
    # This would typically involve API calls to your DNS provider
fi

# Update load balancer configuration
if [ "$AUTO_LB_UPDATE" = "true" ]; then
    echo "Updating load balancer configuration..."
    # Update load balancer to point to DR site
fi

# Step 6: Start application services
echo "Step 6: Starting application services..."

# Update application configuration
if [ -f "$APP_CONFIG_FILE" ]; then
    sed -i "s/$PRIMARY_DB_HOST/$DR_DB_HOST/g" "$APP_CONFIG_FILE"
    sed -i "s/$PRIMARY_DB_PORT/$DR_DB_PORT/g" "$APP_CONFIG_FILE"
fi

# Start application services
for service in $APP_SERVICES; do
    echo "Starting service: $service"
    systemctl start "$service"
    
    # Verify service started
    sleep 5
    if systemctl is-active "$service" > /dev/null 2>&1; then
        echo "✓ $service started successfully"
    else
        echo "✗ Failed to start $service"
    fi
done

# Step 7: Verify DR system functionality
echo "Step 7: Verifying DR system functionality..."

# Database connectivity test
if psql -h $DR_DB_HOST -U $APP_DB_USER -d $APP_DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ Database connectivity verified"
else
    echo "✗ Database connectivity failed"
    exit 1
fi

# Application health check
if [ -n "$APP_HEALTH_URL" ]; then
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_HEALTH_URL")
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✓ Application health check passed"
    else
        echo "✗ Application health check failed (HTTP $HTTP_STATUS)"
    fi
fi

# Step 8: Notify stakeholders
echo "Step 8: Notifying stakeholders..."

# Send notification to operations team
if [ -n "$OPS_EMAIL" ]; then
    echo "DR activation completed at $(date)" | mail -s "DR Site Activated" "$OPS_EMAIL"
fi

# Send Slack notification
if [ -n "$SLACK_WEBHOOK" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"🚨 DR Site Activated - $DR_SITE_NAME is now primary\"}" \
        "$SLACK_WEBHOOK"
fi

# Step 9: Begin replication setup (for future failback)
echo "Step 9: Setting up replication for future failback..."

# This would involve setting up streaming replication
# from the new primary (DR site) back to the original site
# when it becomes available

echo "=== DISASTER RECOVERY COMPLETED ==="
echo "DR site is now active and serving traffic"
echo "Primary database: $DR_DB_HOST:$DR_DB_PORT"
echo "Recovery completed at: $(date)"

# Create DR activation summary
cat > "/var/log/postgresql/dr_summary_$(date +%Y%m%d_%H%M%S).txt" << EOF
DISASTER RECOVERY SUMMARY
========================

Activation Date: $(date)
Disaster Type: $DISASTER_TYPE
Original Primary: $PRIMARY_SITE_NAME
New Primary: $DR_SITE_NAME

Services Activated:
$(for service in $APP_SERVICES; do echo "- $service"; done)

Next Steps:
1. Monitor system performance and stability
2. Coordinate with application teams for testing
3. Plan for failback when original site is restored
4. Document any issues or improvements needed

Contact Information:
- DBA Team: $DBA_CONTACT
- Operations: $OPS_CONTACT
- Management: $MGMT_CONTACT
EOF
```

## 7.5 Standby Server Recovery

### Streaming Replication Standby Setup

```bash
#!/bin/bash
# setup_standby_recovery.sh

# Configuration
PRIMARY_HOST="$1"
STANDBY_DATA_DIR="/var/lib/postgresql/standby"
REPLICATION_USER="replicator"
RECOVERY_LOG="/var/log/postgresql/standby_setup_$(date +%Y%m%d_%H%M%S).log"

if [ -z "$PRIMARY_HOST" ]; then
    echo "Usage: $0 <primary_host>"
    exit 1
fi

exec 1> >(tee -a $RECOVERY_LOG)
exec 2>&1

echo "=== Standby Server Setup Started ==="
echo "Primary host: $PRIMARY_HOST"
echo "Standby data directory: $STANDBY_DATA_DIR"

# Step 1: Stop PostgreSQL if running
echo "Step 1: Stopping PostgreSQL..."
systemctl stop postgresql

# Step 2: Remove old data directory
echo "Step 2: Preparing standby data directory..."
if [ -d "$STANDBY_DATA_DIR" ]; then
    mv "$STANDBY_DATA_DIR" "${STANDBY_DATA_DIR}_old_$(date +%Y%m%d_%H%M%S)"
fi

mkdir -p "$STANDBY_DATA_DIR"

# Step 3: Create base backup from primary
echo "Step 3: Creating base backup from primary..."
pg_basebackup -h $PRIMARY_HOST -U $REPLICATION_USER \
    -D "$STANDBY_DATA_DIR" \
    -P -v -R -W

if [ $? -eq 0 ]; then
    echo "✓ Base backup completed successfully"
else
    echo "ERROR: Base backup failed"
    exit 1
fi

# Step 4: Configure standby-specific settings
echo "Step 4: Configuring standby settings..."

cat >> "$STANDBY_DATA_DIR/postgresql.conf" << EOF

# Standby server configuration
hot_standby = on
max_standby_streaming_delay = 30s
max_standby_archive_delay = 30s
wal_receiver_status_interval = 10s
hot_standby_feedback = on
EOF

# Step 5: Set ownership and permissions
echo "Step 5: Setting ownership and permissions..."
chown -R postgres:postgres "$STANDBY_DATA_DIR"
chmod 700 "$STANDBY_DATA_DIR"

# Step 6: Start PostgreSQL standby
echo "Step 6: Starting PostgreSQL standby..."
systemctl start postgresql

# Step 7: Verify standby status
echo "Step 7: Verifying standby status..."
sleep 10

if pg_isready > /dev/null 2>&1; then
    echo "✓ PostgreSQL standby is ready"
    
    # Check replication status
    STANDBY_STATUS=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" | tr -d ' ')
    if [ "$STANDBY_STATUS" = "t" ]; then
        echo "✓ Standby is in recovery mode"
        
        # Check replication lag
        REPLICATION_LAG=$(psql -U postgres -t -c "SELECT CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END AS lag_seconds;" | tr -d ' ')
        echo "Current replication lag: $REPLICATION_LAG seconds"
        
    else
        echo "WARNING: Standby is not in recovery mode"
    fi
    
else
    echo "ERROR: PostgreSQL standby failed to start"
    exit 1
fi

echo "=== Standby Server Setup Completed ==="
```

### Standby Promotion to Primary

```bash
#!/bin/bash
# promote_standby.sh

STANDBY_DATA_DIR="/var/lib/postgresql/data"
PROMOTION_LOG="/var/log/postgresql/promotion_$(date +%Y%m%d_%H%M%S).log"

exec 1> >(tee -a $PROMOTION_LOG)
exec 2>&1

echo "=== Standby Promotion Started ==="
echo "Date: $(date)"

# Step 1: Verify standby status
echo "Step 1: Verifying standby status..."
IS_STANDBY=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" | tr -d ' ')

if [ "$IS_STANDBY" != "t" ]; then
    echo "ERROR: Database is not in standby mode"
    exit 1
fi

echo "✓ Confirmed database is in standby mode"

# Step 2: Check replication lag
echo "Step 2: Checking replication lag..."
REPLICATION_LAG=$(psql -U postgres -t -c "SELECT CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END AS lag_seconds;" | tr -d ' ')

echo "Current replication lag: $REPLICATION_LAG seconds"

if (( $(echo "$REPLICATION_LAG > 60" | bc -l) )); then
    echo "WARNING: Replication lag is high ($REPLICATION_LAG seconds)"
    read -p "Continue with promotion? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Promotion cancelled"
        exit 1
    fi
fi

# Step 3: Promote standby to primary
echo "Step 3: Promoting standby to primary..."
psql -U postgres -c "SELECT pg_promote();"

if [ $? -eq 0 ]; then
    echo "✓ Promotion command executed"
else
    echo "ERROR: Promotion command failed"
    exit 1
fi

# Step 4: Wait for promotion to complete
echo "Step 4: Waiting for promotion to complete..."
TIMEOUT=60
COUNTER=0

while [ $COUNTER -lt $TIMEOUT ]; do
    IS_RECOVERY=$(psql -U postgres -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | tr -d ' ')
    if [ "$IS_RECOVERY" = "f" ]; then
        echo "✓ Promotion completed successfully"
        break
    fi
    sleep 2
    COUNTER=$((COUNTER + 2))
done

if [ $COUNTER -ge $TIMEOUT ]; then
    echo "ERROR: Promotion timeout"
    exit 1
fi

# Step 5: Verify new primary status
echo "Step 5: Verifying new primary status..."

# Check if database accepts writes
psql -U postgres -c "CREATE TEMP TABLE promotion_test (id INT);" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Database accepts writes"
else
    echo "ERROR: Database does not accept writes"
    exit 1
fi

# Check WAL sender processes
ACTIVE_SENDERS=$(psql -U postgres -t -c "SELECT count(*) FROM pg_stat_replication;" | tr -d ' ')
echo "Active WAL senders: $ACTIVE_SENDERS"

# Step 6: Update configuration for new primary role
echo "Step 6: Updating configuration for primary role..."

# Remove standby.signal file if it exists (PostgreSQL 12+)
if [ -f "$STANDBY_DATA_DIR/standby.signal" ]; then
    rm "$STANDBY_DATA_DIR/standby.signal"
    echo "✓ Removed standby.signal file"
fi

# Update postgresql.conf for primary role
cat >> "$STANDBY_DATA_DIR/postgresql.conf" << EOF

# Primary server configuration (added during promotion)
wal_level = replica
max_wal_senders = 3
wal_keep_segments = 64
archive_mode = on
archive_command = 'cp %p /backup/wal_archive/%f'
EOF

# Step 7: Reload configuration
echo "Step 7: Reloading configuration..."
psql -U postgres -c "SELECT pg_reload_conf();"

echo "=== Standby Promotion Completed ==="
echo "Database is now primary and ready to accept connections"
```

## 7.6 Recovery Troubleshooting

### Common Recovery Issues

#### Issue 1: Missing WAL Files

```bash
# Diagnosis
echo "Checking for missing WAL files..."
psql -U postgres -c "SELECT pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"

# List available WAL files
ls -la /backup/wal_archive/ | tail -20

# Solution: Locate missing WAL files
find /backup -name "*.wal" | grep <missing_wal_name>

# Or create dummy WAL file if acceptable data loss
# pg_resetwal -D /var/lib/postgresql/data
```

#### Issue 2: Corrupted Backup Files

```bash
# Diagnosis
pg_restore --list backup.dump | head -10

# Verify file integrity
md5sum backup.dump
# Compare with stored checksum

# Solution: Use alternative backup
ls -la /backup/postgresql/ | grep $(date -d "yesterday" +%Y%m%d)
```

#### Issue 3: Recovery Timeout

```sql
-- Check recovery progress
SELECT 
    pg_last_wal_receive_lsn(),
    pg_last_wal_replay_lsn(),
    pg_last_xact_replay_timestamp(),
    EXTRACT(EPOCH FROM now() - pg_last_xact_replay_timestamp()) AS lag_seconds;

-- Check for long-running recovery conflicts
SELECT 
    pid,
    usename,
    application_name,
    state,
    query_start,
    LEFT(query, 50) as query
FROM pg_stat_activity 
WHERE state = 'active' 
  AND query != '<IDLE>';
```

#### Issue 4: Recovery Conflicts

```sql
-- Check for recovery conflicts
SELECT 
    confl_tablespace,
    confl_lock,
    confl_snapshot,
    confl_bufferpin,
    confl_deadlock
FROM pg_stat_database_conflicts 
WHERE datname = current_database();

-- Resolve by adjusting settings
ALTER SYSTEM SET max_standby_streaming_delay = '300s';
ALTER SYSTEM SET max_standby_archive_delay = '300s';
SELECT pg_reload_conf();
```

### Recovery Validation Scripts

```bash
#!/bin/bash
# validate_recovery.sh

DATABASE="$1"
VALIDATION_LOG="/var/log/postgresql/validation_$(date +%Y%m%d_%H%M%S).log"

exec 1> >(tee -a $VALIDATION_LOG)
exec 2>&1

echo "=== Recovery Validation Started ==="
echo "Database: $DATABASE"
echo "Date: $(date)"

# Test 1: Basic connectivity
echo "Test 1: Database connectivity..."
if psql -U postgres -d $DATABASE -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ Database connectivity: PASS"
else
    echo "✗ Database connectivity: FAIL"
    exit 1
fi

# Test 2: Data integrity
echo "Test 2: Data integrity checks..."

# Check for corrupted pages
CORRUPTED_PAGES=$(psql -U postgres -d $DATABASE -t -c "
    SELECT COUNT(*) FROM (
        SELECT schemaname, tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    ) t(schema, table_name)
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_stat_user_tables 
        WHERE schemaname = t.schema AND relname = t.table_name
    );
" | tr -d ' ')

if [ "$CORRUPTED_PAGES" = "0" ]; then
    echo "✓ Data integrity: PASS"
else
    echo "✗ Data integrity: FAIL ($CORRUPTED_PAGES issues found)"
fi

# Test 3: Table count verification
echo "Test 3: Table count verification..."
TABLE_COUNT=$(psql -U postgres -d $DATABASE -t -c "
    SELECT COUNT(*) 
    FROM information_schema.tables 
    WHERE table_schema = 'public';
" | tr -d ' ')

echo "Tables found: $TABLE_COUNT"
if [ "$TABLE_COUNT" -gt "0" ]; then
    echo "✓ Table count: PASS"
else
    echo "✗ Table count: FAIL"
fi

# Test 4: Index validity
echo "Test 4: Index validity..."
INVALID_INDEXES=$(psql -U postgres -d $DATABASE -t -c "
    SELECT COUNT(*) 
    FROM pg_index 
    WHERE NOT indisvalid;
" | tr -d ' ')

if [ "$INVALID_INDEXES" = "0" ]; then
    echo "✓ Index validity: PASS"
else
    echo "✗ Index validity: FAIL ($INVALID_INDEXES invalid indexes)"
fi

# Test 5: Foreign key constraints
echo "Test 5: Foreign key constraints..."
FK_VIOLATIONS=$(psql -U postgres -d $DATABASE -t -c "
    SELECT COUNT(*) 
    FROM information_schema.table_constraints 
    WHERE constraint_type = 'FOREIGN KEY'
      AND is_deferrable = 'NO';
" | tr -d ' ')

echo "Foreign key constraints: $FK_VIOLATIONS"

# Test 6: Sequence values
echo "Test 6: Sequence consistency..."
SEQUENCE_ISSUES=$(psql -U postgres -d $DATABASE -t -c "
    SELECT COUNT(*) 
    FROM information_schema.sequences 
    WHERE sequence_schema = 'public';
" | tr -d ' ')

echo "Sequences found: $SEQUENCE_ISSUES"

# Test 7: Application-specific validation
echo "Test 7: Application-specific validation..."
# Add application-specific validation queries here

echo "=== Recovery Validation Completed ==="
echo "Validation completed at: $(date)"
```

## 7.7 Practical Lab Exercises

### Lab 1: Complete Recovery Simulation

```sql
-- Lab Setup: Create test scenario
CREATE DATABASE recovery_lab;
\c recovery_lab;

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

-- Insert test data
INSERT INTO customers (name, email) VALUES 
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith', 'bob@example.com'),
    ('Carol Davis', 'carol@example.com');

INSERT INTO orders (customer_id, amount) VALUES 
    (1, 150.00),
    (2, 275.50),
    (3, 89.99),
    (1, 320.00);

-- Create backup
\! pg_dump -h localhost -U postgres -d recovery_lab -Fc -f /tmp/recovery_lab_backup.dump

-- Simulate disaster (data corruption)
DROP TABLE orders;
DROP TABLE customers;

-- Exercise: Perform complete recovery
-- 1. Drop database
-- 2. Recreate database
-- 3. Restore from backup
-- 4. Verify data integrity
```

### Lab 2: Point-in-Time Recovery

```bash
#!/bin/bash
# Lab 2: PITR Exercise

# Setup WAL archiving for lab
psql -U postgres << EOF
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET archive_mode = 'on';
ALTER SYSTEM SET archive_command = 'cp %p /tmp/wal_archive/%f';
SELECT pg_reload_conf();
EOF

# Create WAL archive directory
mkdir -p /tmp/wal_archive

# Take base backup
pg_basebackup -U postgres -D /tmp/base_backup_$(date +%Y%m%d_%H%M%S) -Ft -z -X stream

# Record time before problematic change
BEFORE_ERROR=$(date '+%Y-%m-%d %H:%M:%S')
echo "Time before error: $BEFORE_ERROR"

# Simulate application activity
psql -U postgres -d recovery_lab << EOF
INSERT INTO customers (name, email) VALUES ('Good Customer', 'good@example.com');
SELECT pg_switch_wal();
EOF

sleep 5

# Record time of problematic change
ERROR_TIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "Error time: $ERROR_TIME"

# Simulate problematic change
psql -U postgres -d recovery_lab << EOF
DELETE FROM customers WHERE name != 'Nonexistent Customer';
SELECT pg_switch_wal();
EOF

# Exercise: Perform PITR to time before error
echo "Perform PITR to: $BEFORE_ERROR"
```

### Lab 3: Standby Server Setup and Promotion

```bash
#!/bin/bash
# Lab 3: Standby Server Exercise

# Create replication user
psql -U postgres << EOF
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replica_pass';
EOF

# Configure pg_hba.conf for replication
echo "host replication replicator 127.0.0.1/32 md5" >> /etc/postgresql/*/main/pg_hba.conf

# Reload configuration
psql -U postgres -c "SELECT pg_reload_conf();"

# Setup standby server (simulated on same machine)
STANDBY_DIR="/tmp/standby_data"
mkdir -p $STANDBY_DIR

# Create standby using pg_basebackup
pg_basebackup -h localhost -U replicator -D $STANDBY_DIR -P -v -R -W

# Start standby (simulated with different port)
sed -i "s/#port = 5432/port = 5433/" $STANDBY_DIR/postgresql.conf

# Start standby instance
pg_ctl -D $STANDBY_DIR -l /tmp/standby.log start

# Verify replication
psql -h localhost -p 5433 -U postgres -c "SELECT pg_is_in_recovery();"

# Test promotion
psql -h localhost -p 5433 -U postgres -c "SELECT pg_promote();"

# Verify promotion
psql -h localhost -p 5433 -U postgres -c "SELECT pg_is_in_recovery();"
```

## Summary
In this module, we covered:
- Complete database recovery procedures from logical and physical backups
- Point-in-time recovery (PITR) implementation and validation
- Disaster recovery procedures and site failover
- Standby server recovery and promotion procedures
- Recovery troubleshooting and issue resolution
- Recovery validation and verification methods
- Practical exercises for hands-on recovery experience

## Next Module
[Module 8: Practical Labs and Exercises](09-practical-labs.md)
