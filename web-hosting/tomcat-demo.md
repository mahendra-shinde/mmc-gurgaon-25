# Installing and Running Apache Tomcat in WSL/Ubuntu

This guide will walk you through the process of installing and running Apache Tomcat on Windows Subsystem for Linux (WSL) or Ubuntu.

## Prerequisites

- WSL2 with Ubuntu distribution installed on Windows 10/11, or a native Ubuntu system
- Terminal access to your Ubuntu environment
- Internet connection to download required packages

## Step 1: Update System Packages

First, update your package list to ensure you have access to the latest versions:

```bash
sudo apt update -y
```

## Step 2: Install Java Development Kit (JDK)

Tomcat requires Java to run. Install OpenJDK 11:

```bash
sudo apt install openjdk-11-jdk-headless -y
```

Verify the Java installation:

```bash
java -version
javac -version
```

## Step 3: Download Apache Tomcat

Navigate to your home directory and download the latest Tomcat 9 release:

```bash
cd ~
wget -O apache-tomcat-9.0.tar.gz https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.108/bin/apache-tomcat-9.0.108.tar.gz
```

> **Note**: Check the [Apache Tomcat Downloads page](https://tomcat.apache.org/download-90.cgi) for the latest version URL.

## Step 4: Extract and Setup Tomcat

Extract the downloaded tarball:

```bash
tar -xzf apache-tomcat-9.0.tar.gz
```

Rename the directory for easier management:

```bash
mv apache-tomcat-9.0.108 apache-tomcat-9.0
cd apache-tomcat-9.0
```

Set the `JAVA_HOME` and `CATALINA_HOME` environment variables:

```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> ~/.bashrc
export CATALINA_HOME=$PWD
echo "export CATALINA_HOME=$PWD" >> ~/.bashrc
```

> **Note:** The `.bashrc` file is crucial for setting up environment variables and customizing your shell environment. Changes made here, such as adding `JAVA_HOME` and `CATALINA_HOME`, ensure these variables are automatically set each time you open a new terminal session. This helps avoid manual configuration and potential errors when running Tomcat commands.


## Step 5: Configure Tomcat Permissions

Make the Tomcat scripts executable:

```bash
chmod +x bin/*.sh
```

## Step 6: Start Tomcat Server

Start the Tomcat server:

```bash
cd $CATALINA_HOME
./bin/startup.sh
```

You should see output indicating that Tomcat has started successfully.

## Step 7: Access Tomcat Web Interface

Open a web browser and navigate to:

```
http://localhost:8080
```

You should see the Tomcat welcome page, confirming that the server is running correctly.

## Step 8: Stop Tomcat Server

To stop the Tomcat server when needed:

```bash
cd $CATALINA_HOME
./bin/shutdown.sh
```

## Optional: Configure Tomcat Manager (Admin Interface)

To access the Tomcat Manager application, you need to configure admin users:

1. Edit the `tomcat-users.xml` file:

```bash
nano conf/tomcat-users.xml
```

2. Add the following lines before the closing `</tomcat-users>` tag:

```xml
<role rolename="manager-gui"/>
<role rolename="admin-gui"/>
<user username="admin" password="password" roles="manager-gui,admin-gui"/>
```

3. Save the file and restart Tomcat:

```bash
cd $CATALINA_HOME
./bin/shutdown.sh
./bin/startup.sh
```

4. Access the Manager at: `http://localhost:8080/manager/html`

## Troubleshooting

### Common Issues:

1. **Port 8080 already in use**: 
   - Check if another service is using port 8080: `sudo netstat -tlnp | grep :8080`
   - Kill the process or change Tomcat's port in `conf/server.xml`

2. **Permission denied errors**:
   - Ensure scripts have execute permissions: `chmod +x bin/*.sh`

3. **Java not found**:
   - Verify Java installation: `which java`
   - Set JAVA_HOME if needed: `export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64`

### Checking Tomcat Logs:

View the Tomcat logs for debugging:

```bash
cd $CATALINA_HOME
tail -f logs/catalina.out
```

## WSL-Specific Considerations

When running in WSL:

1. **Firewall**: Windows Firewall might block connections. Add an exception for port 8080 if needed.

2. **Memory**: WSL has memory limitations. Monitor usage with `free -h` and adjust if necessary.

3. **File Permissions**: WSL handles Linux file permissions differently. Ensure proper permissions are set.

4. **Network Access**: You can access Tomcat from Windows browsers using `localhost:8080` or the WSL IP address.

## Next Steps

- Deploy web applications to the `webapps` directory
- Configure SSL/TLS for production use
- Set up automatic startup with systemd (for native Ubuntu)
- Configure database connections and other enterprise features

