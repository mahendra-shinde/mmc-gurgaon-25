#!/bin/bash
# Detect RHEL/CentOS version
source /etc/os-release
RHEL_VERSION=${VERSION_ID%%.*}

# Minimum supported version is 7
MIN_VERSION=7
if [ "$RHEL_VERSION" -lt "$MIN_VERSION" ]; then
    echo "Error: RHEL/CentOS $MIN_VERSION or newer is required. Detected: $VERSION_ID ($NAME). Exiting."
    exit 1
fi

# Install MongoDB 8.0
echo "Installing MongoDB 8.0 on $NAME $VERSION_ID..."

# Install prerequisites
yum install -y gnupg2 curl

# Add MongoDB repository
cat <<EOF | tee /etc/yum.repos.d/mongodb-org-8.0.repo
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$RHEL_VERSION/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc
EOF

# Install MongoDB packages
yum install -y mongodb-org

# Enable and start MongoDB service
systemctl enable mongod
systemctl start mongod

echo "+--------------------------------------------------------------------+"
echo "| MongoDB 8.0 installation completed.                                |"
echo "| ------------------------------------------------------------------ |"
echo "| You can check the status of MongoDB with:                          |"
echo "|   sudo systemctl status mongod                                          |"
echo "| To connect to MongoDB, use: mongosh                                |"
echo "+--------------------------------------------------------------------+"