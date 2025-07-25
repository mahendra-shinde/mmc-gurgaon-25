# PostgreSQL Security Checklist

## Pre-Deployment Security Checklist

### Network Security
- [ ] Configure firewall to restrict PostgreSQL port access
- [ ] Set `listen_addresses` to specific IP addresses, not '*'
- [ ] Use non-default port if required by security policy
- [ ] Implement VPN for remote database access
- [ ] Configure SSL/TLS certificates for encrypted connections
- [ ] Test SSL connection requirements

### Authentication and Authorization
- [ ] Remove or disable default superuser accounts not needed
- [ ] Use strong authentication methods (scram-sha-256)
- [ ] Avoid `trust` authentication method in production
- [ ] Configure pg_hba.conf with principle of least privilege
- [ ] Implement password complexity requirements
- [ ] Set password expiration policies
- [ ] Create service accounts with minimal privileges

### Role and Permission Management
- [ ] Design role hierarchy following business structure
- [ ] Implement role-based access control (RBAC)
- [ ] Grant minimum necessary privileges to each role
- [ ] Use schema-based access segregation
- [ ] Implement column-level security for sensitive data
- [ ] Configure row-level security (RLS) where appropriate
- [ ] Set up default privileges for future objects

### Database Configuration
- [ ] Configure logging for security events
- [ ] Set appropriate log levels and destinations
- [ ] Enable connection and disconnection logging
- [ ] Configure log rotation and retention
- [ ] Set up log monitoring and alerting
- [ ] Disable unnecessary extensions and functions
- [ ] Configure resource limits (connection limits, statement timeouts)

### Auditing and Monitoring
- [ ] Install and configure pg_audit extension
- [ ] Set up comprehensive audit logging
- [ ] Configure real-time monitoring for security events
- [ ] Implement alerting for failed authentication attempts
- [ ] Set up monitoring for privilege escalation attempts
- [ ] Configure log analysis tools
- [ ] Establish baseline for normal database activity

### Data Protection
- [ ] Implement encryption at rest (if required)
- [ ] Configure backup encryption
- [ ] Set up secure backup storage locations
- [ ] Implement data masking for non-production environments
- [ ] Configure secure communication channels
- [ ] Establish data retention and disposal policies

### Maintenance and Updates
- [ ] Establish regular security patch schedule
- [ ] Configure automated security updates (if appropriate)
- [ ] Plan for emergency security patches
- [ ] Document security configuration changes
- [ ] Perform regular security assessments
- [ ] Update security documentation

## Production Security Verification

### Daily Checks
- [ ] Review authentication failure logs
- [ ] Check for unusual connection patterns
- [ ] Verify backup completion and security
- [ ] Monitor privilege changes
- [ ] Review security alert notifications

### Weekly Checks
- [ ] Analyze security log patterns
- [ ] Review user account activity
- [ ] Verify SSL certificate validity
- [ ] Check for new security vulnerabilities
- [ ] Validate backup integrity and security

### Monthly Checks
- [ ] Comprehensive security log analysis
- [ ] User access review and cleanup
- [ ] Security configuration audit
- [ ] Update security documentation
- [ ] Review and test incident response procedures

### Quarterly Checks
- [ ] Full security assessment
- [ ] Penetration testing (if required)
- [ ] Disaster recovery testing
- [ ] Security training updates
- [ ] Compliance audit preparation

## Incident Response Checklist

### Security Incident Detection
- [ ] Identify the nature and scope of the security incident
- [ ] Document initial findings and timeline
- [ ] Notify appropriate stakeholders
- [ ] Preserve evidence and logs
- [ ] Assess immediate risk and impact

### Containment
- [ ] Isolate affected systems
- [ ] Revoke compromised credentials
- [ ] Block suspicious network traffic
- [ ] Prevent further data access
- [ ] Document containment actions

### Investigation
- [ ] Analyze logs and evidence
- [ ] Determine attack vector and timeline
- [ ] Assess data compromise extent
- [ ] Document investigation findings
- [ ] Coordinate with legal/compliance teams

### Recovery
- [ ] Remove malicious code or unauthorized access
- [ ] Restore systems from clean backups
- [ ] Reset all potentially compromised passwords
- [ ] Update security configurations
- [ ] Test system functionality

### Post-Incident
- [ ] Document lessons learned
- [ ] Update security procedures
- [ ] Implement additional security controls
- [ ] Provide security awareness training
- [ ] File required compliance reports

## Compliance Considerations

### SOX Compliance
- [ ] Implement segregation of duties
- [ ] Document all database access
- [ ] Establish audit trails for financial data
- [ ] Implement change management controls
- [ ] Regular access certification

### GDPR Compliance
- [ ] Implement data subject access controls
- [ ] Set up data deletion procedures
- [ ] Document data processing activities
- [ ] Implement consent management
- [ ] Establish data breach notification procedures

### HIPAA Compliance
- [ ] Implement access controls for PHI
- [ ] Set up audit trails for medical data
- [ ] Establish user authentication requirements
- [ ] Implement data encryption requirements
- [ ] Document security risk assessments

### PCI DSS Compliance
- [ ] Implement cardholder data protection
- [ ] Set up network security controls
- [ ] Establish access control measures
- [ ] Implement monitoring and testing
- [ ] Document security procedures
