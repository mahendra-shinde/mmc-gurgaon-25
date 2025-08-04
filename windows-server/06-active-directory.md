# Active Directory Concepts

Active Directory (AD) is a directory service developed by Microsoft for Windows domain networks. It is used for storing information about network resources and enables administrators to manage permissions and access to networked resources.

## Work Groups

A Work Group is a peer-to-peer network model where each computer is managed independently. There is no central control, and each user manages their own computer. Work Groups are suitable for small networks (typically less than 10 computers).

**Key Points:**
- No centralized authentication or management
- Each computer has its own user accounts
- Suitable for home or small office networks

## Domains

A Domain is a client/server network model where a central server (Domain Controller) manages authentication, security, and resources. Domains are scalable and suitable for large organizations.

**Key Points:**
- Centralized authentication and management
- Users and computers are managed centrally
- Suitable for medium to large organizations

## Domain Controller

A Domain Controller (DC) is a server that responds to authentication requests and verifies users on computer networks. It stores the Active Directory database and enforces security policies for a domain.

**Key Points:**
- Manages user logins and security
- Stores directory data and manages communication between users and domains
- Can be multiple DCs for redundancy

## DNS Server

The Domain Name System (DNS) Server translates domain names (like www.example.com) into IP addresses. In Active Directory, DNS is essential for locating domain controllers and other services.

**Key Points:**
- Resolves hostnames to IP addresses
- Required for Active Directory functionality
- Can be integrated with AD for dynamic updates

## DHCP Server

The Dynamic Host Configuration Protocol (DHCP) Server automatically assigns IP addresses and other network configuration parameters to devices on a network, allowing them to communicate efficiently.

**Key Points:**
- Automates IP address assignment
- Reduces configuration errors
- Can provide additional information like DNS servers and gateways