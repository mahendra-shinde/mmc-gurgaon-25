# MongoDB ReplicaSet Cluster with Docker Compose

This guide walks you through deploying a MongoDB ReplicaSet cluster using Docker Compose. Follow each step carefully for a successful setup.

---

## 1. Prepare Your Environment

Open a terminal and create a new directory for the demo:

```sh
cd ~
mkdir mongo-docker2
cd mongo-docker2
```

## 2. Generate the MongoDB Keyfile

MongoDB uses a keyfile for internal authentication between replica set members. Generate and set permissions for the keyfile:

```sh
openssl rand -base64 756 > mongo-keyfile
chmod 400 mongo-keyfile
chown 999:999 mongo-keyfile  # Ensure docker can access the file
```

**Note:** The `chown 999:999` command sets the file owner to the default MongoDB user inside the container. This is required for proper access.

## 3. Download the Docker Compose File

Download or copy the contents of [`compose.yaml`](./compose.yaml) into your working directory:

```sh
wget -O compose.yaml https://raw.githubusercontent.com/mahendra-shinde/mmc-gurgaon-25/refs/heads/main/mongodb/demos/mongo-replica/compose.yaml
# Or copy manually from the repository
```

## 4. Start MongoDB Containers

Use Docker Compose to start all MongoDB instances:

```sh
docker-compose config   # Validate configuration
docker-compose up -d    # Start containers in detached mode
```

## 5. Verify Container Status

Check that all three MongoDB nodes are running:

```sh
docker-compose ps
```

## 6. Initialize the ReplicaSet

Enter the `mongo1` container to begin initialization:

```sh
docker-compose exec mongo1 bash
mongosh admin -u root -p example
```

Check replica set status (should show 'Not Yet Initialized'):

```js
rs.status()
```

## 7. Initiate the ReplicaSet

In the `mongosh` shell, run:

```js
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017", priority: 2 }, // Primary
    { _id: 1, host: "mongo2:27017", priority: 1 },
    { _id: 2, host: "mongo3:27017", priority: 1 }
  ]
})
```

## 8. Check ReplicaSet Status on Other Nodes

Open a new terminal for each node. For `mongo2`:

```sh
cd ~/mongo-docker2
docker-compose exec mongo2 bash
mongosh admin -u root -p example
rs.status()
```

Repeat for `mongo3`:

```sh
cd ~/mongo-docker2
docker-compose exec mongo3 bash
mongosh admin -u root -p example
rs.status()
```

## 9. Test Replication

Switch back to the `mongo1` shell and insert a document:

```js
db.books.insertOne({ title: "Java Primer" })
```

On `mongo2` (and `mongo3`), verify the document is replicated:

```js
db.books.find()
```

You should see the document inserted from `mongo1` available on all nodes.

---

## Troubleshooting & Tips

- Ensure the keyfile permissions and ownership are correct (`chmod 400`, `chown 999:999`).
- If containers fail to start, check Docker logs for errors.
- Command to view logs from service mongo1 : `docker-compose logs mongo1`
- Replace `mongo1` with `mongo2` or `mongo3` to view respective service logs.
- Use `rs.status()` to verify replica set health.
- To clean and run a fresh instance, use following commands:

    ```sh
    docker-compose down
    sudo rm -rf data{1..3}
    docker-compose up -d
    ```
- For more details, see the official [MongoDB ReplicaSet documentation](https://docs.mongodb.com/manual/replication/).





