# MongoDB Import/Export Demo

## Objective
Learn how to import data from CSV files into MongoDB and export data from MongoDB collections.

## Prerequisites
- MongoDB server running locally or accessible remotely
- MongoDB tools installed (mongoimport, mongoexport)
- Sample CSV file: `products.csv`

## Demo: Importing Products Data

### Step 1: Examine the CSV File Structure

First, let's look at our sample `products.csv` file:

```csv
productId,name,category,price,stock,description,brand,rating,isActive,createdDate
1,"Wireless Bluetooth Headphones","Electronics",2499.99,50,"High-quality wireless headphones with noise cancellation and 30-hour battery life","SoundMax",4.5,true,"2024-01-15"
2,"Organic Green Tea","Food & Beverages",299.50,100,"Premium organic green tea leaves sourced from Darjeeling hills","TeaGarden",4.2,true,"2024-02-10"
3,"Gaming Mechanical Keyboard","Electronics",4999.00,25,"RGB backlit mechanical keyboard with blue switches for gaming enthusiasts","GameTech",4.8,true,"2024-01-20"
```

**File Structure Analysis:**
- **Headers**: productId, name, category, price, stock, description, brand, rating, isActive, createdDate
- **Data Types**: Mixed (numbers, strings, booleans, dates)
- **Total Records**: 8 products (excluding header)

### Step 2: Create the Target Database

Before importing, let's create our target database and verify MongoDB connection:

```bash
# Connect to MongoDB
mongosh

# Create and switch to 'shop' database
use shop

# Verify we're in the correct database
db.getName()
quit
```

### Step 3: Import CSV Data using mongoimport

#### Basic Import Command

```bash
mongoimport --db shop --collection products --type csv --headerline products.csv
```

**Command Breakdown:**
- `--db shop`: Target database name
- `--collection products`: Target collection name (required!)
- `--type csv`: Specify file type as CSV
- `--headerline`: Treat first line as field names (headers)
- ` products.csv`: Source CSV file path

> **Note**: When using `--headerline`, all data will be imported as strings. For proper data types, see Step 5 below.

#### Advanced Import with Additional Options

```bash
mongoimport --host localhost:27017 --db shop \
  --type csv \
  --headerline \
  --file products.csv \
  --drop \
  --verbose
```

**Additional Options:**
- `--host localhost:27017`: Specify MongoDB host and port
- `--drop`: Drop collection before importing (if exists)
- `--verbose`: Show detailed import progress

### Step 4: Verify the Import

After importing, verify the data in MongoDB:

```javascript
// Connect to MongoDB shell
mongosh

// Switch to shop database
use shop

// Count total documents
db.products.countDocuments()

// Display all products
db.products.find().pretty()

// Display first 3 products
db.products.find().limit(3).pretty()

// Check data types
db.products.findOne()
```

### Step 5: Data Type Considerations

#### Issue: All Fields Imported as Strings

By default, mongoimport treats all CSV values as strings. To handle proper data types:

> **Important Note**: `--headerline` and `--fields` cannot be used together in mongoimport!

**Option 1: Use Field Mapping (WITHOUT --headerline)**
```bash
# First, manually specify field names with types
mongoimport \
  --db shop \
  --collection products \
  --type csv \
  --file products.csv \
  --columnsHaveTypes \
  --fields "productId.int32(),name.string(),category.string(),price.double(),stock.int32(),description.string(),brand.string(),rating.double(),isActive.boolean(),createdDate.date(2006-01-02)"
```
> In this example above command would fail as It tries to convert Row-0 "productId" to Int32 !!

**Option 2: Two-Step Process**
```bash
# Step 1: Import with headerline (strings only)
mongoimport \
  --db shop \
  --type csv \
  --headerline \
  --file products.csv
```

# Step 2: Post-Import Data Transformation

```javascript
// Update data types after import
db.products.updateMany(
  {},
  [
    {
      $set: {
        productId: { $toInt: "$productId" },
        price: { $toDouble: "$price" },
        stock: { $toInt: "$stock" },
        rating: { $toDouble: "$rating" },
        isActive: { $toBool: "$isActive" },
        createdDate: { $dateFromString: { dateString: "$createdDate" } }
      }
    }
  ]
)
```

**Option 3: Prepare CSV Without Headers**

```bash
# Remove header line from CSV first, then use field mapping
tail -n +2 products.csv > products_no_header.csv

mongoimport \
  --db shop \
  --type csv \
  --file products_no_header.csv \
  --columnsHaveTypes \
  --fields "productId.int32(),name.string(),category.string(),price.double(),stock.int32(),description.string(),brand.string(),rating.double(),isActive.boolean(),createdDate.date(2006-01-02)"
```
### Recommended Approach for Beginners

For most use cases, especially when learning, use this **two-step approach**:

1. **Import with --headerline** (simple and reliable):
```bash
mongoimport --db shop --collection products --type csv --headerline --file products.csv
```

2. **Convert data types in MongoDB**:
```javascript
// Connect to MongoDB
mongosh

// Switch to shop database
use shop

// Convert data types
db.products.updateMany(
  {},
  [
    {
      $set: {
        productId: { $toInt: "$productId" },
        price: { $toDouble: "$price" },
        stock: { $toInt: "$stock" },
        rating: { $toDouble: "$rating" },
        isActive: { $toBool: "$isActive" },
        createdDate: { $dateFromString: { dateString: "$createdDate" } }
      }
    }
  ]
)

// Verify the conversion
db.products.findOne()
```

This approach is:
- ✅ Simple and beginner-friendly
- ✅ Uses actual CSV headers
- ✅ Allows data type conversion
- ✅ Easy to troubleshoot

### Step 6: Query the Imported Data

Test various queries on the imported data:

```javascript
// Find electronics products
db.products.find({ category: "Electronics" })

// Find products with rating > 4.0
db.products.find({ rating: { $gt: 4.0 } })

// Find products in stock
db.products.find({ stock: { $gt: 0 } })

// Find products by price range
db.products.find({ 
  price: { 
    $gte: 500, 
    $lte: 2000 
  } 
})

// Count products by category
db.products.aggregate([
  { $group: { _id: "$category", count: { $sum: 1 } } }
])
```

## Demo: Exporting Data

### Export Collection to CSV

```bash
mongoexport \
  --db shop \
  --collection products \
  --type csv \
  --fields productId,name,category,price,stock,rating \
  --out exported_products.csv
```

### Export with Query Filter

```bash
mongoexport \
  --db shop \
  --collection products \
  --type csv \
  --fields productId,name,category,price \
  --query '{"category":"Electronics"}' \
  --out electronics_products.csv
```

### Export to JSON

```bash
mongoexport \
  --db shop \
  --collection products \
  --out products_backup.json \
  --pretty
```

## Best Practices

### 1. Data Preparation
- Clean CSV data before import
- Ensure consistent date formats
- Handle special characters properly
- Validate data types

### 2. Import Strategy
- Use `--drop` carefully in production
- Test with small datasets first
- Backup existing data before import
- Monitor import performance

### 3. Performance Tips
- Use `--numInsertionWorkers` for large files
- Consider batch size with `--batchSize`
- Import during low-traffic periods

```bash
# Performance optimized import
mongoimport \
  --db shop \
  --collection products \
  --type csv \
  --headerline \
  --file large_products.csv \
  --numInsertionWorkers 4 \
  --batchSize 1000
```

## Common Issues and Solutions

### Issue 1: Cannot Use --headerline and --fields Together

**Problem**: MongoDB's `mongoimport` doesn't allow using `--headerline` and `--fields` simultaneously.

**Solutions**:

**Solution A: Use --headerline (Recommended for beginners)**
```bash
# Simple import with string data types
mongoimport --db shop --collection products --type csv --headerline --file products.csv

# Then convert data types in MongoDB
mongosh shop --eval "
db.products.updateMany(
  {},
  [
    {
      \$set: {
        productId: { \$toInt: '\$productId' },
        price: { \$toDouble: '\$price' },
        stock: { \$toInt: '\$stock' },
        rating: { \$toDouble: '\$rating' },
        isActive: { \$toBool: '\$isActive' },
        createdDate: { \$dateFromString: { dateString: '\$createdDate' } }
      }
    }
  ]
)
"
```

**Solution B: Use --fields without headers**
```bash
# Skip the header line and define fields manually
mongoimport \
  --db shop \
  --collection products \
  --type csv \
  --file products.csv \
  --skip 1 \
  --columnsHaveTypes \
  --fields "productId.int32(),name.string(),category.string(),price.double(),stock.int32(),description.string(),brand.string(),rating.double(),isActive.boolean(),createdDate.date(2006-01-02)"
```

**Solution C: Create a headerless CSV file**
```bash
# Windows PowerShell
Get-Content products.csv | Select-Object -Skip 1 | Out-File products_no_header.csv

# Then import with field mapping
mongoimport \
  --db shop \
  --collection products \
  --type csv \
  --file products_no_header.csv \
  --columnsHaveTypes \
  --fields "productId.int32(),name.string(),category.string(),price.double(),stock.int32(),description.string(),brand.string(),rating.double(),isActive.boolean(),createdDate.date(2006-01-02)"
```

### Issue 2: File Path Problems
```bash
# Use absolute path
mongoimport --db shop --collection products --type csv --headerline --file "C:\data\products.csv"

# Or navigate to file directory first
cd /path/to/csv/files
mongoimport --db shop --collection products --type csv --headerline --file products.csv
```

### Issue 2: Authentication Required
```bash
mongoimport \
  --host localhost:27017 \
  --username admin \
  --password secret \
  --authenticationDatabase admin \
  --db shop \
  --collection products \
  --type csv \
  --headerline \
  --file products.csv
```

### Issue 3: Connection Issues
```bash
# Specify full connection string
mongoimport \
  --uri "mongodb://username:password@localhost:27017/shop" \
  --collection products \
  --type csv \
  --headerline \
  --file products.csv
```

## Summary

You have successfully learned:
1. ✅ How to import CSV data into MongoDB
2. ✅ Using `--headerline` to treat first row as field names
3. ✅ Handling data types during import
4. ✅ Exporting data from MongoDB collections
5. ✅ Best practices for import/export operations

## Next Steps
- Practice with different CSV formats
- Learn about importing JSON data
- Explore bulk operations for data transformation
- Study MongoDB backup and restore procedures