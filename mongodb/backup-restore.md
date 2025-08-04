# MongoDB Backup and Restore

## Introduction

Backing up and restoring data is a critical part of database administration. MongoDB provides simple and effective tools to perform backup and restore operations, ensuring data safety and business continuity.

## Backup in MongoDB

MongoDB offers several ways to back up your data:

- **mongodump**: Creates a binary export of the contents of a database.
- **File System Snapshots**: Useful for large deployments, but require filesystem-level access.
- **Cloud Backups**: Managed solutions like MongoDB Atlas provide automated backups.

For most CLI-based scenarios, `mongodump` is the standard tool.

## Restore in MongoDB

To restore data, MongoDB provides the `mongorestore` tool, which imports content from a binary database dump into a MongoDB instance.

## Demo: Backup and Restore using CLI

Let's see a simple demo using `mongodump` and `mongorestore`.

### 1. Backup a Database

Suppose you have a database named `contacts` running on the default port (27017).

```sh
mongodump --db contacts --out /path/to/backup/
```

**Explanation:**
- `mongodump`: The backup tool.
- `--db contacts`: Specifies the database to back up.
- `--out /path/to/backup/`: Directory where the backup will be stored.

This command creates a folder `/path/to/backup/contacts` containing BSON files for each collection.

### 2. Restore a Database

To restore the `contacts` database from the backup:

```sh
mongorestore --db contacts /path/to/backup/contacts
```

**Explanation:**
- `mongorestore`: The restore tool.
- `--db contacts`: Specifies the target database for restore.
- `/path/to/backup/contacts`: Path to the backup data.

### 3. Additional Options

- To back up all databases:
  ```sh
  mongodump --out /path/to/backup/
  ```
- To restore all databases:
  ```sh
  mongorestore /path/to/backup/
  ```

## File System Backup

File system backup is an alternative approach that involves creating snapshots or copies of the MongoDB data files directly at the operating system level. This method is particularly useful for large deployments and can provide faster backup and restore operations.

### Prerequisites

Before performing file system backups, ensure:
- MongoDB is running with journaling enabled (default in most configurations)
- You have appropriate file system permissions
- The storage system supports consistent snapshots (LVM, ZFS, or cloud storage snapshots)

### Methods

#### 1. Hot Backup (MongoDB Running)

For a consistent backup while MongoDB is running:

```sh
# Step 1: Lock the database to ensure consistency
mongosh --eval "db.fsyncLock()"

# Step 2: Create snapshot or copy data files
cp -r /var/lib/mongodb /backup/mongodb-$(date +%Y%m%d_%H%M%S)
# OR use filesystem snapshot
# It WON'T work in WSL Environment 
# lvcreate -L1G -s -n mongodb-backup /dev/vg0/mongodb-lv

# Step 3: Unlock the database
mongosh --eval "db.fsyncUnlock()"
```

#### 2. Cold Backup (MongoDB Stopped)

For guaranteed consistency, stop MongoDB first:

```sh
# Step 1: Stop MongoDB service
sudo systemctl stop mongod

# Step 2: Copy data files
cp -r /var/lib/mongodb /backup/mongodb-$(date +%Y%m%d_%H%M%S)

# Step 3: Start MongoDB service
sudo systemctl start mongod
```

#### 3. Using LVM Snapshots

> DO NOT TRY THIS ON WSL (Windows)

If using LVM (Logical Volume Manager):

```sh
# Create snapshot
sudo lvcreate -L1G -s -n mongodb-snapshot-$(date +%Y%m%d) /dev/vg0/mongodb-lv

# Mount and backup
sudo mkdir /mnt/mongodb-snapshot
sudo mount /dev/vg0/mongodb-snapshot-$(date +%Y%m%d) /mnt/mongodb-snapshot
cp -r /mnt/mongodb-snapshot/* /backup/mongodb-$(date +%Y%m%d_%H%M%S)/

# Cleanup
sudo umount /mnt/mongodb-snapshot
sudo lvremove -f /dev/vg0/mongodb-snapshot-$(date +%Y%m%d)
```

### Restore from File System Backup

To restore from a file system backup:

```sh
# Step 1: Stop MongoDB
sudo systemctl stop mongod

# Step 2: Remove current data (backup first if needed)
sudo mv /var/lib/mongodb /var/lib/mongodb.old

# Step 3: Restore from backup
sudo cp -r /backup/mongodb-20240804_143000 /var/lib/mongodb

# Step 4: Fix permissions
sudo chown -R mongod:mongod /var/lib/mongodb

# Step 5: Start MongoDB
sudo systemctl start mongod
```

### Advantages and Considerations

**Advantages:**
- Faster for large datasets
- Creates point-in-time snapshots
- Can backup the entire MongoDB instance including configuration
- Works well with automation scripts

**Considerations:**
- Requires file system level access
- May need database locking for hot backups
- Backup size equals the full data directory
- Less granular than mongodump (can't easily restore single collections)

## Notes

- Ensure MongoDB server is running before performing backup or restore.
- You may need to specify `--host` and `--port` if your MongoDB is not running on the default settings.
- For authentication, use `--username`, `--password`, and `--authenticationDatabase` as needed.

## References

- [MongoDB mongodump Documentation](https://www.mongodb.com/docs/database-tools/mongodump/)
- [MongoDB mongorestore Documentation](https://www.mongodb.com/docs/database-tools/mongorestore/)
