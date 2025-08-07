# Web Hosting & Application Server Management 

## Table of Contents
1. [Web Servers & Application Servers](#web-servers--application-servers)
2. [Java/J2EE Application Servers](#javaj2ee-application-servers)
3. [Apache Reverse Proxy & SSL Configuration](#apache-reverse-proxy--ssl-configuration)
4. [Hardware Load Balancers](#hardware-load-balancers)
5. [Database Query Fundamentals](#database-query-fundamentals)
6. [F5 Load Balancer Configuration](#f5-load-balancer-configuration)
7. [CI/CD Pipeline Overview](#cicd-pipeline-overview)
8. [CI/CD Tools](#cicd-tools)
9. [Environment Management](#environment-management)
10. [Deployment Strategies](#deployment-strategies)

## Web Servers & Application Servers

### What are Web Servers?
Web servers are software applications that handle HTTP requests from clients (web browsers) and serve web content such as HTML pages, images, CSS, and JavaScript files.

**Key Functions:**
- Handle HTTP/HTTPS requests
- Serve static content (HTML, CSS, JS, images)
- Route requests to appropriate handlers
- Manage connections and sessions

**Popular Web Servers:**
- **Apache HTTP Server**: Open-source, highly configurable
- **Nginx**: High-performance, reverse proxy capabilities
- **IIS (Internet Information Services)**: Microsoft's web server
- **Lighttpd**: Lightweight, fast web server

### What are Application Servers?
Application servers provide a runtime environment for business applications and handle dynamic content generation.

**Key Functions:**
- Execute server-side code
- Manage database connections
- Handle business logic
- Provide middleware services
- Support various programming languages

**Differences between Web Servers and Application Servers:**
| Feature | Web Server | Application Server |
|---------|------------|-------------------|
| Content Type | Static content | Dynamic content |
| Protocols | HTTP/HTTPS | HTTP/HTTPS + others |
| Processing | Minimal | Complex business logic |
| Examples | Apache, Nginx | Tomcat, WebLogic |

---

## Java/J2EE Application Servers

### Apache Tomcat
**Overview:** Lightweight servlet container for Java web applications.

**Key Features:**
- Servlet and JSP support
- Easy deployment (WAR files)
- Embedded or standalone deployment
- Built-in management tools

**Configuration:**
```xml
<!-- server.xml example -->
<Server port="8005" shutdown="SHUTDOWN">
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1" />
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps" />
    </Engine>
  </Service>
</Server>
```

### JBoss/WildFly
**Overview:** Full Java EE application server with enterprise features.

**Key Features:**
- Full Java EE compliance
- Hot deployment
- Clustering support
- Advanced security features
- JMS messaging

### Oracle WebLogic
**Overview:** Enterprise-grade application server for large-scale applications.

**Key Features:**
- High availability and scalability
- Advanced clustering
- Web services support
- Enterprise security
- Performance monitoring

### Comparison Matrix
| Feature | Tomcat | JBoss/WildFly | WebLogic |
|---------|--------|---------------|----------|
| License | Open Source | Open Source | Commercial |
| Java EE Support | Partial | Full | Full |
| Clustering | Limited | Yes | Advanced |
| Enterprise Features | Basic | Advanced | Enterprise |

---

## Apache Reverse Proxy & SSL Configuration

### What is a Reverse Proxy?
A reverse proxy sits between clients and backend servers, forwarding client requests to backend servers and returning responses back to clients.

**Benefits:**
- Load distribution
- SSL termination
- Caching
- Security enhancement
- Compression

### Apache Reverse Proxy Configuration

**Enable Required Modules:**
```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests
```

**Basic Reverse Proxy Configuration:**
```apache
<VirtualHost *:80>
    ServerName example.com
    
    ProxyPreserveHost On
    ProxyPass / http://backend-server:8080/
    ProxyPassReverse / http://backend-server:8080/
</VirtualHost>
```

**Load Balancing Configuration:**
```apache
<Proxy balancer://mycluster>
    BalancerMember http://server1:8080
    BalancerMember http://server2:8080
    ProxySet lbmethod=byrequests
</Proxy>

ProxyPass / balancer://mycluster/
ProxyPassReverse / balancer://mycluster/
```

### SSL Configuration

**Generate SSL Certificate:**
```bash
# Self-signed certificate for testing
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/example.key \
    -out /etc/ssl/certs/example.crt
```

**SSL Virtual Host Configuration:**
```apache
<VirtualHost *:443>
    ServerName example.com
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/example.crt
    SSLCertificateKeyFile /etc/ssl/private/example.key
    
    # Security headers
    Header always set Strict-Transport-Security "max-age=63072000"
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    
    ProxyPass / http://backend-server:8080/
    ProxyPassReverse / http://backend-server:8080/
</VirtualHost>
```

---

## Hardware Load Balancers

### F5 BIG-IP
**Overview:** Enterprise-grade Application Delivery Controller (ADC) providing load balancing, security, and application acceleration.

**Key Features:**
- Layer 4-7 load balancing
- SSL offloading
- Application firewall
- Traffic management
- Health monitoring

**Load Balancing Methods:**
- **Round Robin**: Distributes requests evenly
- **Least Connections**: Routes to server with fewest connections
- **Weighted Round Robin**: Assigns weights to servers
- **IP Hash**: Routes based on client IP

### Cisco Load Balancers
**Products:**
- **Cisco Application Centric Infrastructure (ACI)**
- **Cisco Nexus Series**
- **Cisco ASR Series**

**Features:**
- High availability
- SSL acceleration
- Content switching
- Global server load balancing

### Comparison: Hardware vs Software Load Balancers
| Aspect | Hardware | Software |
|--------|----------|----------|
| Performance | Very High | High |
| Cost | Expensive | Cost-effective |
| Scalability | Limited | Highly scalable |
| Flexibility | Limited | Very flexible |
| Maintenance | Vendor-dependent | Self-managed |

---

## Database Query Fundamentals

### Basic SQL Operations

**SELECT Queries:**
```sql
-- Basic SELECT
SELECT column1, column2 FROM table_name;

-- SELECT with conditions
SELECT * FROM employees WHERE department = 'IT';

-- SELECT with sorting
SELECT * FROM employees ORDER BY salary DESC;

-- SELECT with aggregation
SELECT department, COUNT(*) as employee_count 
FROM employees 
GROUP BY department;
```

**INSERT Operations:**
```sql
-- Single row insert
INSERT INTO employees (name, department, salary) 
VALUES ('John Doe', 'IT', 75000);

-- Multiple row insert
INSERT INTO employees (name, department, salary) 
VALUES 
    ('Jane Smith', 'HR', 65000),
    ('Bob Johnson', 'Finance', 70000);
```

**UPDATE Operations:**
```sql
-- Update specific records
UPDATE employees 
SET salary = 80000 
WHERE name = 'John Doe';

-- Update with conditions
UPDATE employees 
SET salary = salary * 1.1 
WHERE department = 'IT';
```

**DELETE Operations:**
```sql
-- Delete specific records
DELETE FROM employees WHERE department = 'Temp';

-- Delete with conditions
DELETE FROM employees WHERE salary < 30000;
```

### Query Optimization Tips
- Use indexes on frequently queried columns
- Avoid SELECT * in production
- Use LIMIT for large result sets
- Optimize JOIN operations
- Use appropriate data types

---

## F5 Load Balancer Configuration

### iRules Overview
iRules are powerful scripting language (Tcl-based) for F5 devices that allow custom traffic management logic.

**Basic iRule Structure:**
```tcl
when CLIENT_ACCEPTED {
    # Code executed when client connects
}

when HTTP_REQUEST {
    # Code executed when HTTP request is received
}

when HTTP_RESPONSE {
    # Code executed when HTTP response is sent
}
```

**Common iRule Examples:**

**1. Simple Redirect:**
```tcl
when HTTP_REQUEST {
    if { [HTTP::host] equals "old-site.com" } {
        HTTP::redirect "https://new-site.com[HTTP::uri]"
    }
}
```

**2. Content-Based Routing:**
```tcl
when HTTP_REQUEST {
    if { [HTTP::uri] starts_with "/api/" } {
        pool api_servers
    } else {
        pool web_servers
    }
}
```

**3. Custom Health Check:**
```tcl
when HTTP_REQUEST {
    if { [HTTP::uri] equals "/health" } {
        HTTP::respond 200 content "OK"
    }
}
```

### F5 Configuration Components

**Virtual Servers:**
- Entry point for client traffic
- Defines IP, port, and protocol
- Associates with pools and profiles

**Pools:**
- Groups of backend servers
- Health monitoring
- Load balancing methods

**Monitors:**
- Health check mechanisms
- HTTP, TCP, ICMP monitors
- Custom monitor scripts

---

## CI/CD Pipeline Overview

### What is CI/CD?

**Continuous Integration (CI):**
- Automated building and testing
- Code integration from multiple developers
- Early detection of integration issues
- Automated quality gates

**Continuous Deployment (CD):**
- Automated deployment to environments
- Release automation
- Rollback capabilities
- Environment consistency

### CI/CD Pipeline Stages

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │    │    Build    │    │    Test     │    │   Deploy    │
│   Control   │───▶│  Compile    │───▶│  Unit/Int   │───▶│   Staging   │
│   (Git)     │    │  Package    │    │  Security   │    │ Production  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Benefits of CI/CD
- **Faster Time to Market**: Automated processes reduce deployment time
- **Higher Quality**: Automated testing catches issues early
- **Reduced Risk**: Smaller, frequent deployments
- **Better Collaboration**: Standardized processes
- **Increased Productivity**: Less manual work

### CI/CD Best Practices
- **Version Control Everything**: Code, configurations, infrastructure
- **Automate Testing**: Unit, integration, security tests
- **Keep Pipelines Fast**: Parallel execution, caching
- **Monitor Everything**: Builds, deployments, applications
- **Implement Gates**: Quality and security checkpoints

---

## CI/CD Tools

### Jenkins
**Overview:** Open-source automation server for building CI/CD pipelines.

**Key Features:**
- Extensive plugin ecosystem
- Pipeline as Code (Jenkinsfile)
- Distributed builds
- Integration with various tools

**Sample Jenkinsfile:**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'mvn deploy'
            }
        }
    }
}
```

### Nexus Repository Manager
**Overview:** Artifact repository manager for storing and managing build artifacts.

**Key Features:**
- Support for multiple formats (Maven, npm, Docker, etc.)
- Proxy remote repositories
- Security and access control
- Component vulnerability scanning

### Team Foundation Server (TFS/Azure DevOps)
**Overview:** Microsoft's integrated DevOps platform.

**Components:**
- **Azure Repos**: Git repositories
- **Azure Pipelines**: CI/CD pipelines
- **Azure Boards**: Work tracking
- **Azure Artifacts**: Package management
- **Azure Test Plans**: Testing tools

### Tool Comparison
| Tool | Type | Strengths | Best For |
|------|------|-----------|----------|
| Jenkins | CI/CD Server | Flexibility, Plugins | Custom workflows |
| Nexus | Artifact Repository | Multi-format support | Enterprise artifact management |
| Azure DevOps | Integrated Platform | Microsoft ecosystem | End-to-end DevOps |
| GitLab CI | Integrated Platform | Git integration | Git-centric workflows |

---

## Environment Management

### Environment Types

**Development (DEV):**
- **Purpose**: Active development and unit testing
- **Characteristics**: 
  - Frequent deployments
  - Latest code changes
  - Developer access
  - Minimal data protection

**Quality Assurance (QA/TEST):**
- **Purpose**: Functional and integration testing
- **Characteristics**:
  - Stable test environment
  - Test data management
  - Automated testing
  - QA team access

**User Acceptance Testing (UAT):**
- **Purpose**: Business user validation
- **Characteristics**:
  - Production-like environment
  - Business user access
  - Realistic data
  - Limited technical access

**Production (PROD):**
- **Purpose**: Live system serving end users
- **Characteristics**:
  - High availability
  - Security controls
  - Monitoring and alerting
  - Restricted access

**Disaster Recovery (DR):**
- **Purpose**: Backup production environment
- **Characteristics**:
  - Geographically separated
  - Data synchronization
  - Failover capabilities
  - Regular testing

### Environment Management Best Practices

**Infrastructure as Code:**
```yaml
# Example Terraform configuration
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1d0"
  instance_type = "t2.micro"
  
  tags = {
    Name        = "web-server-${var.environment}"
    Environment = var.environment
  }
}
```

**Configuration Management:**
- Environment-specific configurations
- Secret management
- Feature flags
- Database connection strings

**Data Management:**
- Data masking in non-production
- Test data generation
- Data synchronization strategies
- Backup and restore procedures

---

## Deployment Strategies

### Manual vs Automated Deployments

### Manual Deployments
**Characteristics:**
- Human-driven process
- Manual verification steps
- Documentation-based procedures
- Higher error probability

**When to Use:**
- Critical production releases
- Complex environment changes
- Regulatory compliance requirements
- One-time migrations

**Process:**
1. Prepare deployment package
2. Schedule maintenance window
3. Execute deployment steps
4. Verify deployment success
5. Document results

### Automated Deployments
**Characteristics:**
- Script-driven process
- Automated verification
- Consistent procedures
- Lower error probability

**When to Use:**
- Regular application updates
- Development/testing environments
- Hotfix deployments
- Rollback scenarios

**Implementation Example:**
```bash
#!/bin/bash
# Automated deployment script

# Variables
APP_NAME="myapp"
VERSION="$1"
DEPLOY_DIR="/opt/$APP_NAME"

# Backup current version
cp -r $DEPLOY_DIR $DEPLOY_DIR.backup

# Deploy new version
wget "https://releases.company.com/$APP_NAME-$VERSION.tar.gz"
tar -xzf "$APP_NAME-$VERSION.tar.gz" -C $DEPLOY_DIR

# Restart services
systemctl restart $APP_NAME

# Health check
if curl -f http://localhost:8080/health; then
    echo "Deployment successful"
    rm -rf $DEPLOY_DIR.backup
else
    echo "Deployment failed, rolling back"
    rm -rf $DEPLOY_DIR
    mv $DEPLOY_DIR.backup $DEPLOY_DIR
    systemctl restart $APP_NAME
    exit 1
fi
```

### Deployment Patterns

**Blue-Green Deployment:**
- Two identical production environments
- Switch traffic between environments
- Zero-downtime deployments
- Easy rollback

**Canary Deployment:**
- Gradual rollout to subset of users
- Monitor metrics and feedback
- Reduce risk of widespread issues
- Progressive traffic increase

**Rolling Deployment:**
- Update instances one by one
- Maintain service availability
- Gradual replacement of old version
- Resource efficient

### Deployment Checklist
- [ ] Code review completed
- [ ] Tests passing
- [ ] Security scan completed
- [ ] Backup created
- [ ] Rollback plan prepared
- [ ] Monitoring in place
- [ ] Stakeholders notified
- [ ] Documentation updated

---

## Study Tips and Practice Exercises

### Hands-on Labs
1. **Set up Apache reverse proxy** with SSL termination
2. **Configure Tomcat cluster** behind load balancer
3. **Create CI/CD pipeline** using Jenkins
4. **Write basic iRules** for F5 load balancer
5. **Practice SQL queries** on sample database

### Key Concepts to Master
- Load balancing algorithms and their use cases
- SSL/TLS configuration and troubleshooting
- CI/CD pipeline design principles
- Environment promotion strategies
- Database query optimization

### Recommended Resources
- Apache HTTP Server documentation
- F5 DevCentral for iRules examples
- Jenkins documentation and tutorials
- SQL practice platforms (SQLBolt, W3Schools)
- DevOps best practices guides

---

*This study guide provides comprehensive coverage of web hosting and application server management topics. Practice the concepts with hands-on exercises and refer to official documentation for detailed implementation guides.*
