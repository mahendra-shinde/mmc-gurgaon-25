# NGINX as a Reverse Proxy for Tomcat

## Introduction

A reverse proxy is a server that sits between clients and backend servers, forwarding client requests to the appropriate backend servers and then returning the server's response back to the client. NGINX is a popular choice for reverse proxy implementations due to its high performance, stability, and rich feature set.

In this tutorial, we'll configure NGINX as a reverse proxy to forward HTTP requests from port 80 to Apache Tomcat running on port 8080. This setup is commonly used in production environments to:

- **Hide backend server details** from clients
- **Load balance** requests across multiple Tomcat instances
- **Handle SSL termination** at the proxy level
- **Cache static content** for better performance
- **Provide additional security** layers

## Prerequisites

- Windows Subsystem for Linux (WSL) installed and configured
- Ubuntu or similar Linux distribution running in WSL
- Apache Tomcat installed and running on port 8080
- Basic understanding of Linux commands and text editors

## Architecture Overview

```
Client (Browser) → NGINX (Port 80) → Tomcat (Port 8080)
```

## Step-by-Step Implementation

### Step 1: Update Package Manager

First, ensure your package manager is up to date:

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 2: Install NGINX

Install NGINX using the APT package manager:

```bash
sudo apt install nginx -y
```

Verify the installation:

```bash
nginx -v
```

### Step 3: Check NGINX Service Status

Check if NGINX is running:

```bash
sudo systemctl status nginx
```

If not running, start the service:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Step 4: Verify Tomcat is Running

Before configuring the reverse proxy, ensure Tomcat is running on port 8080:

```bash
# Check if Tomcat is listening on port 8080
sudo netstat -tlnp | grep 8080
```

Or test with curl:

```bash
curl http://localhost:8080
```

### Step 5: Backup Default NGINX Configuration

Create a backup of the default configuration:

```bash
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
```

### Step 6: Configure NGINX as Reverse Proxy

Edit the default NGINX configuration file:

```bash
sudo nano /etc/nginx/sites-available/default
```

Replace the content with the following configuration:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    # Logging
    access_log /var/log/nginx/tomcat_access.log;
    error_log /var/log/nginx/tomcat_error.log;

    # Reverse proxy configuration
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }

    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "NGINX is healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Step 7: Test NGINX Configuration

Test the configuration for syntax errors:

```bash
sudo nginx -t
```

If the test is successful, you should see:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Step 8: Reload NGINX Configuration

Apply the new configuration:

```bash
sudo systemctl reload nginx
```

### Step 9: Test the Reverse Proxy

Test the reverse proxy setup:

```bash
# Test from command line
curl http://localhost

# Check if the request is being forwarded to Tomcat
curl -I http://localhost
```

## Configuration Explanation

### Key Proxy Directives

- **`proxy_pass`**: Specifies the backend server URL
- **`proxy_set_header Host`**: Preserves the original Host header
- **`proxy_set_header X-Real-IP`**: Passes the client's real IP address
- **`proxy_set_header X-Forwarded-For`**: Maintains the chain of forwarded IPs
- **`proxy_set_header X-Forwarded-Proto`**: Indicates the original protocol (HTTP/HTTPS)

### Buffer and Timeout Settings

- **`proxy_connect_timeout`**: Time to establish connection with backend
- **`proxy_send_timeout`**: Timeout for sending request to backend
- **`proxy_read_timeout`**: Timeout for reading response from backend
- **`proxy_buffering`**: Enables response buffering for better performance

## Troubleshooting

### Common Issues and Solutions

1. **NGINX fails to start**
   ```bash
   sudo journalctl -u nginx.service
   ```

2. **502 Bad Gateway Error**
   - Check if Tomcat is running: `sudo systemctl status tomcat`
   - Verify port 8080 is accessible: `telnet localhost 8080`
   - Check NGINX error logs: `sudo tail -f /var/log/nginx/error.log`

3. **Permission Issues**
   ```bash
   sudo chown -R www-data:www-data /var/log/nginx/
   ```

4. **Port Already in Use**
   ```bash
   sudo netstat -tlnp | grep :80
   sudo systemctl stop apache2  # If Apache is running
   ```

### Monitoring and Logs

Monitor NGINX access and error logs:

```bash
# Real-time access log monitoring
sudo tail -f /var/log/nginx/tomcat_access.log

# Real-time error log monitoring
sudo tail -f /var/log/nginx/tomcat_error.log

# Check NGINX process status
ps aux | grep nginx
```

## Advanced Configuration Options

### Load Balancing (Multiple Tomcat Instances)

```nginx
upstream tomcat_backend {
    server localhost:8080;
    server localhost:8081;
    server localhost:8082;
}

server {
    listen 80;
    location / {
        proxy_pass http://tomcat_backend;
    }
}
```

### SSL Termination

```nginx
server {
    listen 443 ssl;
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

## Performance Optimization

### Enable Gzip Compression

Add to the `http` block in `/etc/nginx/nginx.conf`:

```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
```

### Connection Caching

```nginx
location / {
    proxy_pass http://localhost:8080;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_cache_bypass $http_upgrade;
}
```

## Security Considerations

1. **Hide NGINX Version**
   ```nginx
   server_tokens off;
   ```

2. **Rate Limiting**
   ```nginx
   limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
   
   location / {
       limit_req zone=api burst=20 nodelay;
       proxy_pass http://localhost:8080;
   }
   ```

3. **IP Whitelisting**
   ```nginx
   location /admin {
       allow 192.168.1.0/24;
       deny all;
       proxy_pass http://localhost:8080;
   }
   ```

## Conclusion

You have successfully configured NGINX as a reverse proxy for Tomcat. This setup provides better performance, security, and scalability for your web applications. Monitor the logs regularly and consider implementing additional features like SSL termination, load balancing, and caching based on your specific requirements.

## Additional Resources

- [NGINX Official Documentation](https://nginx.org/en/docs/)
- [NGINX Reverse Proxy Guide](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
