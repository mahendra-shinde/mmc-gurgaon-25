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

To run a MongoDB cluster (replica set) using Docker Compose, use the following example:

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
    command: ["mongod", "--replSet", "rs0"]
    volumes:
      - ./data1:/data/db

  mongo2:
    image: mongo:latest
    container_name: mongo2
    ports:
      - 27018:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    command: ["mongod", "--replSet", "rs0"]
    volumes:
      - ./data2:/data/db

  mongo3:
    image: mongo:latest
    container_name: mongo3
    ports:
      - 27019:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    command: ["mongod", "--replSet", "rs0"]
    volumes:
      - ./data3:/data/db
```

**Steps:**
1. Save the above YAML as `docker-compose.yml`.
2. Start the containers:
   ```sh
   docker-compose up -d
   ```
3. Initialize the replica set:
   ```sh
   docker exec -it mongo1 mongosh -u root -p example --eval 'rs.initiate({ _id: "rs0", members: [ { _id: 0, host: "mongo1:27017" }, { _id: 1, host: "mongo2:27017" }, { _id: 2, host: "mongo3:27017" } ] })'
   ```
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

