
# MongoDB User Management

MongoDB uses a role-based access control (RBAC) system to manage user permissions. Users are created per database and assigned roles that define their access rights. The `admin` database is special: users created here can be granted privileges across all databases.

## Creating Users

### 1. Creating a User with Read/Write Access to a Single Database

Switch to the `admin` database and create a user with read/write access:

```js
use admin
db.createUser({
  user: "mahendra",
  pwd: "pass!1234",
  roles: [ { role: "readWrite", db: "admin" } ]
})
```

### 2. Creating a User for a Specific Database

Switch to the target database and create a user:

```js
use db2
db.createUser({
  user: "riya",
  pwd: "riya@1234",
  roles: [ { role: "readWrite", db: "db2" } ]
})
```

## Authenticating Users

To authenticate as a user, use the `mongosh` shell:

**Login as 'riya' to db2:**

```sh
mongosh "mongodb://localhost:27017/db2" -u riya -p riya@1234
```

**Login as 'riya' to admin (should fail):**

```sh
mongosh "mongodb://localhost:27017/admin" -u riya -p riya@1234
```

## Creating an Admin User with Access to All Databases

To create a user with administrative privileges on all databases, use the `userAdminAnyDatabase` and `root` roles in the `admin` database:

```js
use admin
db.createUser({
  user: "superadmin",
  pwd: "super@1234",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "root", db: "admin" }
  ]
})
```

This user can manage users and perform any administrative task across all databases.

**Login as 'superadmin':**

```sh
mongosh "mongodb://localhost:27017/admin" -u superadmin -p super@1234
```

## User Management Commands

- **List users in current database:**
  ```js
  db.getUsers()
  ```
- **Update a user's password:**
  ```js
  db.updateUser("riya", { pwd: "newpassword" })
  ```
- **Delete a user:**
  ```js
  db.dropUser("riya")
  ```

## Common Built-in Roles

- `read`: Allows read-only operations.
- `readWrite`: Allows read and write operations.
- `dbAdmin`: Database administration tasks.
- `userAdmin`: User management within a database.
- `userAdminAnyDatabase`: User management across all databases (admin only).
- `root`: Full access to all resources and operations.

Refer to the [MongoDB documentation](https://www.mongodb.com/docs/manual/core/authorization/) for more details on user management and roles.



