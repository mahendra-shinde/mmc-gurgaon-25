# Deploying MongoDB in Docker with Docker Compose

> This tutorial explains how to deploy MongoDB using Docker and Docker Compose, including both single-node and clustered (replica set) deployments.

---

## 1. Prerequisites

- Docker installed
- Docker Compose installed

---

## 2. Deploying a Single MongoDB Instance

Create a directory for your MongoDB deployment and add a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  db:
    image: mongo:latest
    container_name: mongodb
    restart: always
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    volumes:
      - ./data:/data/db
```

**Steps:**
1. Save the above YAML as `docker-compose.yml`.
2. Run the following command in the same directory:
   ```sh
   docker-compose up -d
   ```
3. MongoDB will be available at `localhost:27017` with username `root` and password `example`.

**Connecting to MongoDB:**
```sh
docker exec -it mongodb mongosh -u root -p example
```

---

## 3. Deploying a MongoDB Replica Set (Cluster) with Docker Compose

To run a MongoDB cluster (replica set) using Docker Compose, use the following example. Here, `mongo1` will be configured as the primary instance using an initialization script.


### Important: Keyfile for Internal Authentication

MongoDB requires a keyfile for internal authentication between replica set members. Generate a keyfile and mount it into each container.

**Generate keyfile:**
```sh
openssl rand -base64 756 > mongo-keyfile
chmod 400 mongo-keyfile
# Now file is OWNED by systemd (systemctl) daemon manager
# Otherwise, docker wont be able to copy file inside the container !
chown 999:999 mongo-keyfile
```

**Updated docker-compose.yml:**
```yaml
version: '3.8'
services:
  mongo1:
    image: mongo:latest
    container_name: mongo1
    ports:
      - 27017:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    command: ["mongod", "--replSet", "rs0", "--keyFile", "/data/keyfile"]
    volumes:
      - ./data1:/data/db
      - ./mongo-keyfile:/data/keyfile:ro
      - ./init-replica.js:/docker-entrypoint-initdb.d/init-replica.js:ro

  mongo2:
    image: mongo:latest
    container_name: mongo2
    ports:
      - 27018:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    command: ["mongod", "--replSet", "rs0", "--keyFile", "/data/keyfile"]
    volumes:
      - ./data2:/data/db
      - ./mongo-keyfile:/data/keyfile:ro

  mongo3:
    image: mongo:latest
    container_name: mongo3
    ports:
      - 27019:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    command: ["mongod", "--replSet", "rs0", "--keyFile", "/data/keyfile"]
    volumes:
      - ./data3:/data/db
      - ./mongo-keyfile:/data/keyfile:ro
```

Create a file named `init-replica.js` in the same directory as your `docker-compose.yml` with the following content:

```js
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017", priority: 2 }, // Primary
    { _id: 1, host: "mongo2:27017", priority: 1 },
    { _id: 2, host: "mongo3:27017", priority: 1 }
  ]
});
```

**Steps:**
1. Save the above YAML as `docker-compose.yml`, the JavaScript file as `init-replica.js`, and generate the keyfile as `mongo-keyfile`.

2. Start the containers:
   ```sh
   docker-compose up -d
   ```
3. The replica set will be initialized automatically, with `mongo1` as the primary (highest priority).

4. Check replica set status:
   ```sh
   docker exec -it mongo1 mongosh -u root -p example --eval 'rs.status()'
   ```
---

## 4. Useful Commands

- **Stop all containers:**
  ```sh
  docker-compose down
  ```
- **View logs:**
  ```sh
  docker-compose logs -f
  ```

---

## 5. References

- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [MongoDB Replica Set Docs](https://www.mongodb.com/docs/manual/replication/)

