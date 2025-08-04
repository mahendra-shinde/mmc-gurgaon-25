# Common Network Services Explained

This document provides an overview of several important network services commonly used in enterprise and server environments.

## 1. FTP (File Transfer Protocol)

FTP is a standard network protocol used to transfer files between a client and a server over a network. It is not encrypted by default, so it is less secure for sensitive data.

**Ports:** 21 (control), 20 (data)

**Use Cases:** Website uploads, file sharing

## 2. SFTP (SSH File Transfer Protocol)

SFTP is a secure file transfer protocol that runs over SSH. It encrypts both commands and data, providing secure file transfer capabilities.

**Port:** 22

**Use Cases:** Secure file uploads/downloads, automated backups

## 3. SSH (Secure Shell)

SSH is a cryptographic network protocol for secure remote login and command execution. It is widely used for managing servers and network devices securely.

**Port:** 22

**Use Cases:** Remote administration, secure file transfer (SCP/SFTP), tunneling

## 4. RDP (Remote Desktop Protocol)

RDP is a proprietary protocol developed by Microsoft, allowing users to connect to another computer over a network and use its desktop interface remotely.

**Port:** 3389

**Use Cases:** Remote desktop access, remote support

## 5. LDAP (Lightweight Directory Access Protocol)

LDAP is an open, vendor-neutral protocol for accessing and maintaining distributed directory information services. It is commonly used for authentication and directory lookups.

**Port:** 389 (unencrypted), 636 (LDAPS - encrypted)

**Use Cases:** User authentication, directory services (Active Directory, OpenLDAP)

## 6. NFS (Network File System)

NFS is a distributed file system protocol allowing a user on a client computer to access files over a network as easily as if they were on local storage.

**Port:** 2049

**Use Cases:** File sharing in UNIX/Linux environments, centralized storage

## 7. Other Common Network Services

- **SMB/CIFS (Server Message Block/Common Internet File System):** Used for file and printer sharing in Windows networks. (Port 445)
- **HTTP/HTTPS:** Web services and APIs. (Ports 80/443)
- **DNS (Domain Name System):** Resolves domain names to IP addresses. (Port 53)
- **DHCP (Dynamic Host Configuration Protocol):** Assigns IP addresses to devices on a network. (Port 67/68)

## Summary Table

| Service | Protocol | Default Port | Main Use |
|---------|----------|-------------|----------|
| FTP     | FTP      | 21/20       | File transfer |
| SFTP    | SSH      | 22          | Secure file transfer |
| SSH     | SSH      | 22          | Secure remote access |
| RDP     | RDP      | 3389        | Remote desktop |
| LDAP    | LDAP     | 389/636     | Directory services |
| NFS     | NFS      | 2049        | File sharing |
| SMB     | SMB      | 445         | File/printer sharing |
| HTTP    | HTTP     | 80          | Web services |
| HTTPS   | HTTPS    | 443         | Secure web services |
| DNS     | DNS      | 53          | Name resolution |
| DHCP    | DHCP     | 67/68       | IP assignment |
