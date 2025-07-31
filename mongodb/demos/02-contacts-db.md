
# MongoDB Demo: Contacts Collection

This demo shows how to create a `contacts` collection, insert 10 random documents with varied attributes, and perform basic CRUD operations using MongoSH.

## 1. Start MongoSH and Use Database

```sh
mongosh
use demo
```

## 2. Insert 10 Random Contacts

```js
db.contacts.insertMany([
  { name: "Alice Smith", email: "alice@example.com", phone: "555-1234", city: "Delhi" },
  { name: "Bob Lee", email: "bob.lee@example.com", age: 29, company: "Acme Corp" },
  { name: "Charlie Patel", phone: "555-5678", address: "123 Main St", tags: ["friend", "gym"] },
  { name: "Diana Chen", email: "diana.chen@example.com", birthday: "1990-05-12" },
  { name: "Ethan Brown", phone: "555-8765", city: "Gurgaon", company: "Techies" },
  { name: "Fatima Khan", email: "fatima.k@example.com", tags: ["work", "project"] },
  { name: "George Singh", phone: "555-4321", age: 35, address: "456 Park Ave" },
  { name: "Hina Das", email: "hina.das@example.com", city: "Noida", birthday: "1988-11-23" },
  { name: "Ivan Roy", phone: "555-2468", company: "StartUpX", tags: ["startup"] },
  { name: "Jaya Mehta", email: "jaya.mehta@example.com", city: "Delhi", age: 27 }
])
```

## 3. Find All Contacts

```js
db.contacts.find()
```

## 4. Find Contacts from Delhi

```js
db.contacts.find({ city: "Delhi" })
```

## 5. Update a Contact (Add/Change Attribute)

```js
// Add a new field 'status' to one contact
db.contacts.updateOne(
  { name: "Alice Smith" },
  { $set: { status: "active" } }
)

// Update phone number for Bob Lee
db.contacts.updateOne(
  { name: "Bob Lee" },
  { $set: { phone: "555-9999" } }
)

// Update city to 'Delhi NCR' for all contacts in Delhi
db.contacts.updateMany(
  { city: "Delhi" },
  { $set: { city: "Delhi NCR" } }
)
```

## 6. Delete a Contact

```js
db.contacts.deleteOne({ name: "Ivan Roy" })
```

## 7. Find Contacts with Tag 'work'

```js
db.contacts.find({ tags: "work" })
```
