# Module 1: PostgreSQL Security Fundamentals

## Learning Objectives
- Understand PostgreSQL security architecture
- Learn about authentication methods
- Configure connection security
- Implement SSL/TLS encryption
- Understand security best practices

## 1.1 PostgreSQL Security Architecture

### Overview
PostgreSQL implements a multi-layered security model:

1. **Network Level Security**
   - Host-based authentication (pg_hba.conf)
   - SSL/TLS encryption
   - Firewall configurations

2. **Database Level Security**
   - User authentication
   - Role-based access control
   - Object-level permissions

3. **Application Level Security**
   - SQL injection prevention
   - Input validation
   - Secure coding practices

### Key Security Components

#### pg_hba.conf (Host-Based Authentication)
Controls which users can connect from which hosts using which authentication methods.

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
hostssl all             all             0.0.0.0/0               md5
```

#### postgresql.conf Security Parameters
Key security-related parameters:

```
# Connection and Authentication
listen_addresses = 'localhost'          # Restrict connections
port = 5432                            # Default port
max_connections = 100                  # Limit connections

# SSL Configuration
ssl = on                               # Enable SSL
ssl_cert_file = 'server.crt'         # SSL certificate
ssl_key_file = 'server.key'          # SSL private key

# Logging
log_connections = on                   # Log connections
log_disconnections = on               # Log disconnections
log_statement = 'all'                 # Log all statements
```

## 1.2 Authentication Methods

### Available Authentication Methods

1. **trust** - No authentication (use with caution)
2. **reject** - Reject connections
3. **md5** - MD5 password authentication
4. **scram-sha-256** - SCRAM-SHA-256 authentication (recommended)
5. **password** - Plain text password (not recommended)
6. **peer** - Use operating system user name
7. **ident** - Use operating system user name with mapping
8. **ldap** - LDAP authentication
9. **cert** - SSL certificate authentication

### Recommended Authentication Configuration

```
# pg_hba.conf - Production Configuration
local   all             postgres                                peer
local   all             all                                     scram-sha-256
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
hostssl all             all             0.0.0.0/0               scram-sha-256
```

## 1.3 SSL/TLS Configuration

### Generating SSL Certificates

```bash
# Generate private key
openssl genrsa -out server.key 2048

# Generate certificate signing request
openssl req -new -key server.key -out server.csr

# Generate self-signed certificate (for testing)
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

# Set proper permissions
chmod 600 server.key
chmod 644 server.crt
```

### SSL Configuration in postgresql.conf

```
# SSL Settings
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
ssl_ca_file = 'ca.crt'
ssl_crl_file = 'server.crl'

# SSL Cipher Configuration
ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
ssl_prefer_server_ciphers = on
ssl_ecdh_curve = 'prime256v1'
```

### Client SSL Configuration

```bash
# Connect with SSL required
psql "host=localhost dbname=mydb user=myuser sslmode=require"

# Connect with SSL and certificate verification
psql "host=localhost dbname=mydb user=myuser sslmode=verify-full sslcert=client.crt sslkey=client.key sslrootcert=ca.crt"
```

## 1.4 Security Best Practices

### 1. Network Security
- Use firewall to restrict access to PostgreSQL port
- Bind PostgreSQL to specific IP addresses
- Use SSL/TLS for all connections
- Consider VPN for remote access

### 2. Authentication Security
- Use strong authentication methods (scram-sha-256)
- Avoid trust authentication in production
- Implement password policies
- Use certificate-based authentication where possible

### 3. Configuration Security
- Regular security updates
- Secure file permissions
- Disable unnecessary features
- Regular configuration audits

### 4. Monitoring and Logging
- Enable connection logging
- Monitor failed login attempts
- Set up log rotation
- Implement alerting for security events

## 1.5 Common Security Vulnerabilities

### SQL Injection Prevention
```sql
-- Vulnerable code (DO NOT USE)
EXECUTE 'SELECT * FROM users WHERE username = ''' || user_input || '''';

-- Safe code using parameterized queries
PREPARE get_user(text) AS SELECT * FROM users WHERE username = $1;
EXECUTE get_user('john_doe');
```

### Privilege Escalation Prevention
- Follow principle of least privilege
- Regular privilege audits
- Use roles instead of direct user permissions
- Avoid using superuser accounts for applications

## 1.6 Lab Exercise: Basic Security Setup

### Exercise 1: Configure Basic Security

1. **Modify pg_hba.conf for secure authentication**
```
# Edit pg_hba.conf
sudo nano /etc/postgresql/13/main/pg_hba.conf

# Replace md5 with scram-sha-256
local   all             all                                     scram-sha-256
host    all             all             127.0.0.1/32            scram-sha-256
```

2. **Set password encryption method**
```sql
-- Set password encryption
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
SELECT pg_reload_conf();
```

3. **Create a test user with encrypted password**
```sql
-- Create user with encrypted password
CREATE USER testuser WITH PASSWORD 'SecurePass123!';
```

4. **Test connection**
```bash
# Test connection with new authentication
psql -h localhost -U testuser -d postgres
```

### Exercise 2: SSL Configuration

1. **Generate SSL certificates** (use commands from section 1.3)
2. **Configure PostgreSQL for SSL**
3. **Test SSL connection**
4. **Verify SSL is working**

```sql
-- Check SSL status
SELECT ssl, client_addr FROM pg_stat_ssl JOIN pg_stat_activity USING (pid);
```

## Summary
In this module, we covered:
- PostgreSQL security architecture
- Authentication methods and configuration
- SSL/TLS setup and configuration
- Security best practices
- Common vulnerabilities and prevention
- Hands-on lab exercises

## Next Module
[Module 2: User and Role Management](03-user-role-management.md)
