# PostgreSQL Authentication Demo

This guide demonstrates how to connect to a PostgreSQL server running on your local system using both the default Linux user (`postgres`) and a database user. It also explains how to switch between peer and password authentication methods.

---

## 1. Connect as the Linux `postgres` User

This method is recommended for database administrators.

```bash
sudo -u postgres psql
```

---

## 2. Attempt to Connect Using the Database User

Try connecting as the `postgres` database user:

```bash
psql -U postgres
```

> **Note:** You may encounter an error if password authentication is not enabled.

---

## 3. Locate PostgreSQL Configuration Files

Navigate to the PostgreSQL configuration directory (version may vary):

```bash
cd /etc/postgresql/16/main
```

---

## 4. Edit `pg_hba.conf` to Allow Trust Authentication

Open the `pg_hba.conf` file:

```bash
sudo vi pg_hba.conf
```

Find the following line:

```
local   all             postgres         peer
```

Replace `peer` with `trust`:

```
local   all             postgres         trust
```

Save and close the file (`ESC :wq` in `vi`).

---

## 5. Restart PostgreSQL

Apply the changes by restarting the PostgreSQL service:

```bash
sudo systemctl restart postgresql
```

---

## 6. Connect as the Database User

Now, try connecting again:

```bash
psql -U postgres
```

You should connect successfully.

---

## 7. Set a Password for the `postgres` User

Once connected, set a password for the `postgres` user:

```sql
\password postgres
```

Follow the prompts to enter and confirm the new password (e.g., `Pass@1234`).

Exit `psql`:

```sql
\q
```

---

## 8. Enable Password Authentication (`md5`)

Edit the `pg_hba.conf` file again:

```bash
sudo vi pg_hba.conf
```

Find the line:

```
local   all             postgres         trust
```

Replace `trust` with `md5`:

```
local   all             postgres         md5
```

Save and close the file.

---

## 9. Restart PostgreSQL Again

```bash
sudo systemctl restart postgresql
```

---

## 10. Connect Using Password Authentication

Now, connect using the password you set:

```bash
psql -U postgres
```

When prompted, enter the password (e.g., `Pass@1234`).

> **Success!** You are now authenticated using password-based authentication.