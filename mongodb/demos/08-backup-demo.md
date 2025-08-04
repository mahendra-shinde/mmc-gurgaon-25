# MongoDB Backup and Restore Demo

This demo will guide you through creating sample data in MongoDB and then backing it up using `mongodump`.

## Prerequisites
- MongoDB installed and running
- MongoDB shell (mongosh) available
- mongodump utility available

## Step 1: Configure MongoDB (Disable Security)

Edit the MongoDB configuration file to disable authorization:

```bash
# Edit mongod.conf (location varies by OS)
# Linux: /etc/mongod.conf
sudo nano /etc/mongod.conf
```

Ensure the security section is commented out or disabled:
```yaml
#security:
#  authorization: enabled
```

## Step 2: Restart MongoDB Service

```bash
# Linux/macOS
sudo systemctl restart mongod

## Step 3: Connect to MongoDB

```bash
mongosh
```

## Step 4: Create HR Database and Switch to It

```javascript
use hr
```

## Step 5: Create Employees Collection and Insert Sample Data

```javascript
// Insert 10 sample employees
db.employees.insertMany([
  {
    "empId": "E001",
    "name": "John Doe",
    "position": "Software Engineer",
    "department": "IT",
    "salary": 75000,
    "joinDate": new Date("2022-01-15")
  },
  {
    "empId": "E002",
    "name": "Jane Smith",
    "position": "Project Manager",
    "department": "IT",
    "salary": 85000,
    "joinDate": new Date("2021-03-10")
  },
  {
    "empId": "E003",
    "name": "Mike Johnson",
    "position": "Data Analyst",
    "department": "Analytics",
    "salary": 65000,
    "joinDate": new Date("2022-06-20")
  },
  {
    "empId": "E004",
    "name": "Sarah Wilson",
    "position": "HR Specialist",
    "department": "HR",
    "salary": 55000,
    "joinDate": new Date("2021-11-05")
  },
  {
    "empId": "E005",
    "name": "David Brown",
    "position": "Marketing Manager",
    "department": "Marketing",
    "salary": 70000,
    "joinDate": new Date("2020-09-12")
  },
  {
    "empId": "E006",
    "name": "Emily Davis",
    "position": "Financial Analyst",
    "department": "Finance",
    "salary": 68000,
    "joinDate": new Date("2022-02-28")
  },
  {
    "empId": "E007",
    "name": "Robert Miller",
    "position": "Sales Representative",
    "department": "Sales",
    "salary": 50000,
    "joinDate": new Date("2021-07-18")
  },
  {
    "empId": "E008",
    "name": "Lisa Garcia",
    "position": "UX Designer",
    "department": "Design",
    "salary": 72000,
    "joinDate": new Date("2022-04-03")
  },
  {
    "empId": "E009",
    "name": "Thomas Anderson",
    "position": "DevOps Engineer",
    "department": "IT",
    "salary": 80000,
    "joinDate": new Date("2021-12-01")
  },
  {
    "empId": "E010",
    "name": "Maria Rodriguez",
    "position": "Quality Assurance",
    "department": "QA",
    "salary": 60000,
    "joinDate": new Date("2022-05-15")
  }
])
```

## Step 6: Create Departments Collection and Insert Sample Data

```javascript
// Insert 5 departments
db.departments.insertMany([
  {
    "deptId": "D001",
    "name": "Information Technology",
    "code": "IT",
    "budget": 500000,
    "manager": "John Doe"
  },
  {
    "deptId": "D002",
    "name": "Human Resources",
    "code": "HR",
    "budget": 150000,
    "manager": "Sarah Wilson"
  },
  {
    "deptId": "D003",
    "name": "Marketing",
    "code": "MKT",
    "budget": 200000,
    "manager": "David Brown"
  },
  {
    "deptId": "D004",
    "name": "Finance",
    "code": "FIN",
    "budget": 300000,
    "manager": "Emily Davis"
  },
  {
    "deptId": "D005",
    "name": "Sales",
    "code": "SAL",
    "budget": 250000,
    "manager": "Robert Miller"
  }
])
```

## Step 7: Create Branches Collection and Insert Sample Data

```javascript
// Insert 5 branches
db.branches.insertMany([
  {
    "branchId": "B001",
    "name": "Headquarters",
    "location": "New York, NY",
    "address": "123 Main Street, New York, NY 10001",
    "phone": "+1-555-0101",
    "established": new Date("2015-01-01")
  },
  {
    "branchId": "B002",
    "name": "West Coast Office",
    "location": "San Francisco, CA",
    "address": "456 Tech Avenue, San Francisco, CA 94102",
    "phone": "+1-555-0102",
    "established": new Date("2017-06-15")
  },
  {
    "branchId": "B003",
    "name": "Central Office",
    "location": "Chicago, IL",
    "address": "789 Business Blvd, Chicago, IL 60601",
    "phone": "+1-555-0103",
    "established": new Date("2018-03-20")
  },
  {
    "branchId": "B004",
    "name": "Southern Office",
    "location": "Austin, TX",
    "address": "321 Innovation Drive, Austin, TX 73301",
    "phone": "+1-555-0104",
    "established": new Date("2019-09-10")
  },
  {
    "branchId": "B005",
    "name": "European Office",
    "location": "London, UK",
    "address": "555 Global Street, London, UK EC1A 1BB",
    "phone": "+44-20-1234-5678",
    "established": new Date("2020-11-05")
  }
])
```

## Step 8: Verify Data Creation

```javascript
// Check collections in hr database
show collections

// Count documents in each collection
db.employees.countDocuments()
db.departments.countDocuments()
db.branches.countDocuments()

// Sample queries to verify data
db.employees.findOne()
db.departments.findOne()
db.branches.findOne()
```

## Step 9: Exit MongoDB Shell

```javascript
exit
```

## Step 10: Backup the HR Database using mongodump

```bash
# Create backup directory
cd ~
mkdir -p mongodb_backups

# Backup the entire hr database
mongodump --db hr --out mongodb_backups/

# Alternative: Backup with timestamp
mongodump --db hr --out mongodb_backups/backup_$(date +%Y%m%d_%H%M%S)/
```

## Step 11: Verify Backup

```bash
# List backup contents
ls -la mongodb_backups/
ls -la mongodb_backups/hr/

# Check backup files
ls -la mongodb_backups/hr/*.bson
ls -la mongodb_backups/hr/*.json
```

## Expected Output

After successful backup, you should see the following files in `mongodb_backups/hr/`:
- `employees.bson` and `employees.metadata.json`
- `departments.bson` and `departments.metadata.json`
- `branches.bson` and `branches.metadata.json`

## Optional: Restore Demo

To test the restore functionality:

```bash
# Drop the hr database (BE CAREFUL!)
mongosh --eval "use hr; db.dropDatabase()"

# Restore from backup
mongorestore mongodb_backups/

# Verify restoration
mongosh --eval "use hr; show collections; db.employees.countDocuments()"
```

## Notes

- Always test backup and restore procedures in a non-production environment first
- Consider using `--gzip` option with mongodump for compressed backups
- For production environments, implement proper authentication and use appropriate connection strings
- Schedule regular backups using cron jobs or task scheduler
