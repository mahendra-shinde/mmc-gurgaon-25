# MongoDB Query Examples: Using `find` with Conditions and Operators

## Sample Data

```js
db.inventory.insertMany([
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
]);
```

---

## Logical AND Condition

Find documents matching **all** conditions:

```js
db.inventory.find({ status: "A", qty: { $lt: 30 } })
```

---

## Logical OR Condition

Find documents matching **any** of the conditions:

```js
db.inventory.find({ $or: [ { status: "A" }, { qty: { $lt: 30 } } ] })
```

---

## Using Comparison Operators

- `$lt`: less than
- `$lte`: less than or equal
- `$gt`: greater than
- `$gte`: greater than or equal
- `$ne`: not equal
- `$eq`: equal (rarely needed, as `{ field: value }` is equivalent)

**Examples:**

```js
// Find items with quantity greater than 40
db.inventory.find({ qty: { $gt: 40 } })

// Find items with status not equal to "A"
db.inventory.find({ status: { $ne: "A" } })

// Find items with quantity between 30 and 80 (inclusive)
db.inventory.find({ qty: { $gte: 30, $lte: 80 } })
```

---

## Using the `$in` and `$nin` Operators

- `$in`: matches any value in the array
- `$nin`: matches none of the values in the array

**Examples:**

```js
// Find items with status either "A" or "D"
db.inventory.find({ status: { $in: ["A", "D"] } })

// Find items where status is not "A" or "D"
db.inventory.find({ status: { $nin: ["A", "D"] } })
```

---

## Querying Embedded Documents and Fields

**Examples:**

```js
// Find items where size.uom is "cm"
db.inventory.find({ "size.uom": "cm" })

// Find items where size.h is less than 15
db.inventory.find({ "size.h": { $lt: 15 } })
```

---

## Combining Multiple Operators

**Example:**

```js
// Find items with status "A" and quantity between 20 and 50
db.inventory.find({ status: "A", qty: { $gte: 20, $lte: 50 } })
```

---

## References
- [MongoDB Query and Projection Operators](https://www.mongodb.com/docs/manual/reference/operator/query/)