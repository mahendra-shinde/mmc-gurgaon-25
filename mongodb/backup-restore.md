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

## Notes

- Ensure MongoDB server is running before performing backup or restore.
- You may need to specify `--host` and `--port` if your MongoDB is not running on the default settings.
- For authentication, use `--username`, `--password`, and `--authenticationDatabase` as needed.

## References

- [MongoDB mongodump Documentation](https://www.mongodb.com/docs/database-tools/mongodump/)
- [MongoDB mongorestore Documentation](https://www.mongodb.com/docs/database-tools/mongorestore/)
