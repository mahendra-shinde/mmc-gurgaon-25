
# Deploying MongoDB with Docker & Docker Compose

This guide explains how to deploy MongoDB using Docker and Docker Compose, covering both single-node and replica set deployments.

---

## Prerequisites

- **Docker** installed
- **Docker Compose** installed

---

## Deploying a Single MongoDB Instance

1. **Create a deployment directory:**
   ```sh
   mkdir mongo-docker1
   cd mongo-docker1
   ```

2. **Create a `docker-compose.yml` file** with the following contents:
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

3. **Start MongoDB using Docker Compose:**
   ```sh
   docker-compose up -d
   ```

4. **Access MongoDB:**
   - MongoDB will be available at `localhost:27017`.
   - Username: `root`, Password: `example`

5. **Connect to MongoDB shell:**
   ```sh
   docker exec -it mongodb mongosh -u root -p example
   test> db.hello()
   ```

---

## References

- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [MongoDB Replica Set Documentation](https://www.mongodb.com/docs/manual/replication/)
