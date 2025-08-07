# Deploying Static Website to Apache Tomcat

## Overview

Apache Tomcat is a popular Java servlet container that can also serve static web content. This guide will walk you through deploying a static website to Tomcat using the WAR (Web Application Archive) deployment method.

## Prerequisites

Before starting, ensure you have:
- Apache Tomcat installed and configured
- Basic knowledge of HTML/CSS
- Access to command line/terminal
- Text editor for creating files

## What is a WAR File?

A WAR (Web Application Archive) file is a compressed archive format used to distribute Java web applications. It contains:
- Static web content (HTML, CSS, JavaScript, images)
- Java classes and libraries
- Configuration files
- Deployment descriptors

## Step-by-Step Deployment Process

### Step 1: Create the Website Directory Structure

First, create a proper directory structure for your web application:

```
mywebsite/
 │
 ├── index.html          # Home page / Landing page for Application
 ├── style.css           # The main CSS stylesheet (Optional)
 ├── about.html          # About page
 ├── contact.html        # Contact page
 └── WEB-INF/
     └── web.xml         # Web application deployment descriptor
```

```bash

```sh
cd ~
mkdir mywebsite
cd mywebsite
touch index.html about.html contact.html
mkdir WEB-INF
touch WEB-INF/web.xml
```

**Explanation of Structure:**
- **Root directory (`mywebsite/`)**: Contains all your web content
- **Static files**: HTML, CSS, JavaScript files go in the root or subdirectories
- **WEB-INF directory**: Special directory containing configuration files
- **web.xml**: Deployment descriptor (required for Java web applications)

### Step 2: Create the Basic HTML Files

> nano index.html

Create a simple `index.html` file:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Static Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Welcome to My Website</h1>
        <nav>
            <ul>
                <li><a href="index.html">Home</a></li>
                <li><a href="about.html">About</a></li>
                <li><a href="contact.html">Contact</a></li>
            </ul>
        </nav>
    </header>
    <main>
        <h2>Home Page</h2>
        <p>This is a sample static website deployed on Apache Tomcat.</p>
    </main>
    <footer>
        <p>&copy; 2025 My Website. All rights reserved.</p>
    </footer>
</body>
</html>
```

Create a basic `style.css` file:

```css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
    background-color: #f4f4f4;
}

header {
    background-color: #333;
    color: white;
    padding: 1rem;
    margin-bottom: 20px;
}

nav ul {
    list-style-type: none;
    padding: 0;
}

nav ul li {
    display: inline;
    margin-right: 20px;
}

nav ul li a {
    color: white;
    text-decoration: none;
}

main {
    background-color: white;
    padding: 20px;
    border-radius: 5px;
}
```

### Step 3: Create the web.xml Configuration File

Create the `WEB-INF/web.xml` file with the following minimal configuration:

> This file is provided just as a reference. 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">
    
    <display-name>My Static Website</display-name>
    <description>A simple static website deployed on Tomcat</description>
    
    <!-- Welcome file list -->
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
        <welcome-file>index.htm</welcome-file>
    </welcome-file-list>
    
</web-app>
```

**Explanation of web.xml:**
- **display-name**: Friendly name for your web application
- **description**: Brief description of your application
- **welcome-file-list**: Defines which files to serve when accessing the root URL

### Step 4: Create the WAR File

Navigate to the parent directory of your `mywebsite` folder and create a WAR file using the `tar` command:

**On Linux/macOS:**
```bash
cd ~
tar -cvf mywebsite.war -C mywebsite .
```

**Command Explanation:**
- `tar -cvf`: Creates a verbose archive file
- `mywebsite.war`: Name of the output WAR file
- `-C mywebsite`: Changes to the mywebsite directory
- `.`: Includes all contents of the current directory

### Step 5: Deploy to Tomcat

#### Method 1: Copy to webapps Directory

1. **Locate the Tomcat installation directory:**
   - Linux: Usually `/opt/tomcat` or `/usr/local/tomcat`, But in our case its in `/home/azureadmin/apache-tomcat-9.0`
   - Windows: Usually `C:\Program Files\Apache Software Foundation\Tomcat`

2. **Copy the WAR file:**
   ```bash
   cp mywebsite.war $CATALINA_HOME/webapps/
   ```

3. **Set proper permissions (Linux only):**
   ```bash
   chmod 644 $CATALINA_HOME/webapps/mywebsite.war
   ```

#### Method 2: Use Tomcat Manager (Web Interface)

1. Access Tomcat Manager at: `http://localhost:8080/manager/html`
2. Login with manager credentials
3. Scroll to "WAR file to deploy" section
4. Choose your WAR file and click "Deploy"

### Step 6: Start/Restart Tomcat

**Manual startup:**
```bash
cd $CATALINA_HOME/bin
./shutdown.sh
./startup.sh
```

### Step 7: Test Your Deployment

1. **Wait for deployment**: Tomcat will automatically extract the WAR file
2. **Check logs**: Monitor `$CATALINA_HOME/logs/catalina.out` for any errors
3. **Access your website**: Open a web browser and navigate to:
   ```
   http://localhost:8080/mywebsite
   ```

## Verification Steps

### Check Deployment Status

1. **Verify WAR extraction:**
   ```bash
   ls -la $CATALINA_HOME/webapps/
   ```
   You should see both `mywebsite.war` and `mywebsite/` directory.

2. **Check Tomcat logs:**
   ```bash
   tail -f $CATALINA_HOME/logs/catalina.out
   ```

3. **Test different pages:**
   - http://localhost:8080/mywebsite/
   - http://localhost:8080/mywebsite/about.html
   - http://localhost:8080/mywebsite/contact.html

### Common URLs to Test

- **Application root**: `http://localhost:8080/mywebsite/`
- **Static resources**: `http://localhost:8080/mywebsite/style.css`
- **Images**: `http://localhost:8080/mywebsite/images/logo.png`

## Troubleshooting

### Common Issues and Solutions

1. **404 Error - Application not found:**
   - Check if WAR file is properly deployed
   - Verify Tomcat is running
   - Check application name in URL

2. **403 Error - Access denied:**
   - Check file permissions
   - Verify web.xml configuration
   - Ensure proper directory structure

3. **500 Error - Internal server error:**
   - Check Tomcat logs for detailed error messages
   - Verify web.xml syntax
   - Check for missing files

4. **CSS/Images not loading:**
   - Verify relative paths in HTML
   - Check file permissions
   - Ensure files are in correct directories

### Useful Tomcat Commands

**Check Tomcat status:**
```bash
ps aux | grep tomcat
netstat -tulpn | grep 8080
```

**View real-time logs:**
```bash
tail -f $CATALINA_HOME/logs/catalina.out
```

**Undeploy application:**
```bash
rm -rf $CATALINA_HOME/webapps/mywebsite*
```

## Best Practices

1. **Version Control**: Keep your source code in version control (Git)
2. **Backup**: Always backup before deploying to production
3. **Testing**: Test thoroughly in development environment
4. **Security**: Remove default Tomcat applications in production
5. **Monitoring**: Set up proper logging and monitoring
6. **Updates**: Keep Tomcat updated with security patches

## Conclusion

You have successfully deployed a static website to Apache Tomcat using the WAR deployment method. This approach is suitable for small to medium static websites and provides the foundation for more complex Java web applications in the future.

