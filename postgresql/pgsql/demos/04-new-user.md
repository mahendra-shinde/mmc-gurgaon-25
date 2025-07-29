# Demo: Creating a New PostgreSQL User and Database

This demo shows how to:
- Create a new user (role) in PostgreSQL
- Create a new database owned by this user
- Set a password for the user
- Allow the user to log in from remote hosts

---

## 1. Connect to PostgreSQL as a Superuser

```sh
psql -U postgres
```

---

## 2. Create a New User with Password

```sql
CREATE ROLE demo_user WITH LOGIN PASSWORD 'StrongPassword123';
```

---

## 3. Create a New Database Owned by the New User

```sql
CREATE DATABASE demo_db OWNER demo_user;
```

---

## 4. Allow the User to Connect Remotely

Edit the `pg_hba.conf` file (location varies, e.g., `/etc/postgresql/16/main/pg_hba.conf`):

Add this line to allow password authentication from any IP (for demo purposes):

```
host    demo_db    demo_user    0.0.0.0/0    md5
```

> **Note:** For production, restrict the IP range as needed.

---

## 5. Allow PostgreSQL to Listen on All IP Addresses

Edit `postgresql.conf` (e.g., `/etc/postgresql/16/main/postgresql.conf`):

```
listen_addresses = '*'
```

Restart PostgreSQL to apply changes:

```sh
# On Linux (systemd)
sudo systemctl restart postgresql
```

---

## 6. Test Remote Login

From a remote machine:

```sh
psql -h localhost -U demo_user -d demo_db
```

Enter the password when prompted.

---

## Summary
- You created a new user and database
- The user owns the database and can log in with a password
- Network access is enabled for the user
