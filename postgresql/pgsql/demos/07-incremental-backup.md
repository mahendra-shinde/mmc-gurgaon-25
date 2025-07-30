# Incremental Backup and Point-in-Time Recovery (PITR) in PostgreSQL (CLI, Linux)

## 1. Introduction

PostgreSQL offers robust backup and recovery options. Two important features are **Incremental Backup** (using Write-Ahead Logging, WAL) and **Point-in-Time Recovery (PITR)**. These allow you to restore your database to a specific moment, minimizing data loss.

## 2. Incremental Backup in PostgreSQL

### What is Incremental Backup?
Incremental backup in PostgreSQL is achieved by archiving WAL (Write-Ahead Log) files. Instead of backing up the entire database every time, you only back up changes (WAL segments) since the last base backup.

### Steps to Set Up Incremental Backup

#### 2.1. Enable WAL Archiving
Edit `postgresql.conf`:
```conf
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/16/main/wal_archive/%f'
```
Create the archive directory:
```bash
sudo mkdir -p /var/lib/postgresql/16/wal_archive
sudo chown postgres:postgres /var/lib/postgresql/16/main/wal_archive
```
Reload PostgreSQL:
```bash
sudo systemctl reload postgresql
```

#### 2.2. Take a Base Backup
Use `pg_basebackup`:
```bash
sudo -u postgres pg_basebackup -D /var/lib/postgresql/16/main/base_backup -Ft -z -P
```
This creates a compressed base backup.

#### 2.3. Archive WAL Files
WAL files are automatically copied to the archive directory as transactions occur.

---

## 3. Point-in-Time Recovery (PITR)

PITR allows you to restore your database to a specific point in time using a base backup and archived WAL files.

### Steps for PITR

#### 3.1. Stop PostgreSQL
```bash
sudo systemctl stop postgresql
```

#### 3.2. Restore the Base Backup
```bash
sudo rm -rf /var/lib/postgresql/16/main/*
sudo tar -xzf /var/lib/postgresql/16/main/base_backup/base.tar.gz -C /var/lib/postgresql/16/main/
```

#### 3.3. Create a recovery.signal File and recovery.conf Settings
Create a `recovery.signal` file in the data directory (PostgreSQL 12+):
```bash
sudo touch /var/lib/postgresql/16/main/recovery.signal
```
Edit `postgresql.conf` to add:
```conf
restore_command = 'cp /var/lib/postgresql/16/main/wal_archive/%f %p'
recovery_target_time = 'YYYY-MM-DD HH:MI:SS'
```
Replace with your desired recovery timestamp.

#### 3.4. Start PostgreSQL
```bash
sudo systemctl start postgresql
```
PostgreSQL will replay WAL files up to the specified time and then exit recovery mode.

---

## 4. Example Workflow

1. **Enable WAL archiving** and take a base backup.
2. **Perform regular backups** of WAL files.
3. **If recovery is needed:**
    - Restore the base backup.
    - Copy archived WAL files.
    - Set the recovery target time.
    - Start PostgreSQL to perform PITR.

---

## 5. Useful Commands

- Check WAL archiving status:
  ```bash
  sudo -u postgres psql -c "SELECT * FROM pg_stat_archiver;"
  ```
- List archived WAL files:
  ```bash
ls /var/lib/postgresql/16/main/wal_archive/
  ```

---

## 6. References

- [PostgreSQL Documentation: Continuous Archiving and PITR](https://www.postgresql.org/docs/current/continuous-archiving.html)
- [pg_basebackup](https://www.postgresql.org/docs/current/app-pgbasebackup.html)

---

**Note:** Always test your backup and recovery procedures in a non-production environment before relying on them in production.
