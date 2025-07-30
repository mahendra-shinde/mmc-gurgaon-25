# Introduction to MongoDB

## 1. Introduction to NoSQL Databases

NoSQL databases are a category of database management systems that provide a mechanism for storage and retrieval of data that is modeled in means other than the tabular relations used in relational databases (RDBMS). NoSQL stands for "Not Only SQL" and includes a wide variety of database technologies such as document, key-value, column-family, and graph databases.

## 2. Need for NoSQL Databases

- **Scalability:** Traditional RDBMS can struggle with scaling horizontally (across many servers). NoSQL databases are designed to scale out easily.
- **Flexible Data Models:** NoSQL databases allow storage of unstructured, semi-structured, or structured data, making them ideal for rapidly changing data models.
- **Big Data & Real-Time Applications:** NoSQL databases are optimized for large volumes of data and high-velocity operations, which are common in modern web, mobile, and IoT applications.
- **High Availability:** Many NoSQL databases are designed with built-in replication and distribution for high availability and fault tolerance.

## 3. Introduction to MongoDB

MongoDB is a popular open-source NoSQL database that stores data in flexible, JSON-like documents. It is classified as a document-oriented database, which means data is stored as documents in collections rather than rows in tables.

- **Data Format:** BSON (Binary JSON)
- **Schema-less:** Collections do not enforce document structure, allowing for flexible and dynamic schemas.
- **Cross-Platform:** Available on Windows, Linux, and macOS.
- **Open Source:** Free to use with enterprise options available.

## 4. Benefits of MongoDB and Use Cases

### Benefits
- **Flexible Schema:** Easily adapt to changing application requirements.
- **Horizontal Scalability:** Built-in sharding for distributing data across multiple servers.
- **High Performance:** Optimized for read and write operations.
- **Rich Query Language:** Supports ad-hoc queries, indexing, and aggregation.
- **Strong Community & Ecosystem:** Extensive documentation and tooling.

### Use Cases
- Content management systems
- Real-time analytics
- Internet of Things (IoT) applications
- Catalogs and inventory management
- Mobile and social networking applications

## 5. Basic Demo

Below is a simple demonstration of basic MongoDB operations using the `mongo` shell:

```shell
# Start the MongoDB shell
$ mongosh

# Create or switch to a database
> use mydb

# Insert a document into a collection
> db.users.insertOne({ name: "Alice", age: 25, email: "alice@example.com" })

# Find documents in a collection
> db.users.find({})

# Update a document
> db.users.updateOne({ name: "Alice" }, { $set: { age: 26 } })

# Delete a document
> db.users.deleteOne({ name: "Alice" })
```

> All the commands with "\$" as prefix are executed on Linux Shell but without the "\$" symbole

> All the commands with "\>" as prefix are executed in "Mongo Shell" but without the "\>" symbole.

This demo shows how to create a database, insert, query, update, and delete documents in MongoDB.
