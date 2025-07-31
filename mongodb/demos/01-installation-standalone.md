# MongoDB 8.0 Standalone Installation Guide

This guide explains how to install MongoDB 8.0 on Ubuntu and RHEL/CentOS Linux systems using the provided installation scripts.


## For Ubuntu (22.04 or newer)

1. Open a terminal on your Ubuntu machine.
2. Download the [install-ubuntu.sh](install-ubuntu.sh) script to your machine.

    ```sh
    wget -O install-ubuntu.sh https://raw.githubusercontent.com/mahendra-shinde/mmc-gurgaon-25/refs/heads/main/mongodb/demos/install-ubuntu.sh
    ```

3. Make the script executable:
   ```sh
   chmod +x install-ubuntu.sh
   ```
4. Run the script with superuser privileges:
   ```sh
   sudo ./install-ubuntu.sh
   ```
5. The script will:
   - Check your Ubuntu version.
   - Install prerequisites (`gnupg`, `curl`).
   - Add the MongoDB GPG key and repository.
   - Install MongoDB 8.0.
   - Enable and start the MongoDB service.

6. After installation, check MongoDB status:
   ```sh
   sudo systemctl status mongod
   ```
7. To connect to MongoDB, use:
   ```sh
   mongosh
   ```

## For RHEL/CentOS (7 or newer)

1. Open a terminal on your RHEL/CentOS machine.
2. Download the [install-rhel.sh](install-rhel.sh) script to your machine.
   ```sh
   curl -o install-rhel.sh https://raw.githubusercontent.com/mahendra-shinde/mmc-gurgaon-25/refs/heads/main/mongodb/demos/install-rhel.sh
   ```
3. Make the script executable:
   ```sh
   chmod +x install-rhel.sh
   ```
4. Run the script with superuser privileges:
   ```sh
   sudo ./install-rhel.sh
   ```
5. The script will:
   - Check your RHEL/CentOS version.
   - Install prerequisites (`gnupg2`, `curl`).
   - Add the MongoDB repository.
   - Install MongoDB 8.0.
   - Enable and start the MongoDB service.

6. After installation, check MongoDB status:
   ```sh
   sudo systemctl status mongod
   ```
7. To connect to MongoDB, use:
   ```sh
   mongosh
   ```

---

## Troubleshoot Startup Error

If MongoDB fails to start and you see errors related to the socket file (e.g., `/tmp/mongodb-27017.sock`), it may be due to a leftover socket file from a previous run.

**Solution:**

1. Delete the MongoDB socket file:
   ```sh
   sudo rm -f /tmp/mongodb-27017.sock
   ```
2. Restart the MongoDB service:
   ```sh
   sudo systemctl restart mongod
   ```

This should resolve the startup error.

