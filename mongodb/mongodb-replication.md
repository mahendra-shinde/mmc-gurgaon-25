# MongoDB Replica Set

A MongoDB replica set is a group of MongoDB instances that maintain the same dataset, providing high availability and redundancy. Replica sets are the foundation for MongoDB's replication and fault tolerance features.

## Key Components of a Replica Set

1. **Primary Node**: Handles all write operations and replicates data to secondary nodes.
2. **Secondary Nodes**: Replicate data from the primary node and can serve read operations if configured.
3. **Arbiter Node**: Participates in elections but does not store data. Used to break ties during primary elections.

## Benefits of Replica Sets

- **High Availability**: Ensures data is accessible even if the primary node fails.
- **Data Redundancy**: Protects against data loss by replicating data across multiple nodes.
- **Automatic Failover**: Automatically elects a new primary node if the current one fails.

## Setting Up a Replica Set Using Docker Compose

Below is an example `docker-compose.yml` file to set up a MongoDB replica set:

```yaml
version: '3.8'

services:
    mongo1:
        image: mongo:latest
        container_name: mongo1
        ports:
            - "27017:27017"
        command: ["mongod", "--replSet", "rs0"]

    mongo2:
        image: mongo:latest
        container_name: mongo2
        ports:
            - "27018:27017"
        command: ["mongod", "--replSet", "rs0"]

    mongo3:
        image: mongo:latest
        container_name: mongo3
        ports:
            - "27019:27017"
        command: ["mongod", "--replSet", "rs0"]

```

## Steps to Initialize the Replica Set

1. **Start the Containers**:
     Run the following command to start the containers:
     ```bash
     docker-compose up -d
     ```

2. **Access the Primary Node**:
     Connect to the `mongo1` container:
     ```bash
     docker exec -it mongo1 mongosh
     ```

3. **Initiate the Replica Set**:
     Run the following command inside the MongoDB shell:
     ```javascript
     rs.initiate({
         _id: "rs0",
         members: [
             { _id: 0, host: "mongo1:27017" },
             { _id: 1, host: "mongo2:27017" },
             { _id: 2, host: "mongo3:27017" }
         ]
     });
     ```

4. **Verify the Replica Set**:
     Check the status of the replica set:
     ```javascript
     rs.status();
     ```

## Notes

- Ensure the `docker-compose.yml` file is placed in the `demos` folder.
- The `rs.initiate()` command configures the replica set with three members.
- You can scale the replica set by adding more nodes or configuring read preferences.

By following the steps above, you can set up and manage a MongoDB replica set using Docker Compose.