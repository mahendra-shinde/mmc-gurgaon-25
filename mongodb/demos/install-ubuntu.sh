# Detect Ubuntu version and codename
source /etc/os-release
UBUNTU_VERSION=${VERSION_ID}
CODENAME=${VERSION_CODENAME}

# Minimum supported version is 22.04
MIN_VERSION=22.04
if [ "$(printf '%s\n' "$MIN_VERSION" "$UBUNTU_VERSION" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
    echo "Error: Ubuntu $MIN_VERSION or newer is required. Detected: $UBUNTU_VERSION ($CODENAME). Exiting."
    exit 1
fi
# Install MongoDB 8.0
echo "Installing MongoDB 8.0 on Ubuntu $UBUNTU_VERSION ($CODENAME)..."
apt update -y
# Install prerequisites
apt-get -y install gnupg curl
# Add MongoDB GPG key and repository
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
# Add MongoDB repository to sources list
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $CODENAME/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
# Update package list and install MongoDB
apt update -y
# Install MongoDB packages
apt install -y mongodb-org

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