# PowerShell Remoting Demo

This document demonstrates how to establish a PowerShell remoting session to a remote Windows machine using HTTPS with custom session options.

## Overview

PowerShell remoting allows you to run PowerShell commands on remote computers. This demo shows how to:
- Configure session options to bypass certificate validation
- Store credentials securely
- Establish a remote PowerShell session over HTTPS

## Prerequisites

Before starting, ensure:
- PowerShell remoting is enabled on the target machine
- WinRM service is running on both local and remote machines
- Appropriate firewall rules are configured
- The target machine has HTTPS listener configured on port 5986

## Step-by-Step Process

### Step 1: Configure Session Options

Create a PowerShell session option object that skips certificate validation checks. This is useful in test environments or when using self-signed certificates.

```powershell
# Create session options to skip certificate validation
$SOPT = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
```

**Parameters explained:**
- `-SkipCACheck`: Skips the certificate authority validation
- `-SkipCNCheck`: Skips the certificate common name validation  
- `-SkipRevocationCheck`: Skips the certificate revocation list check

### Step 2: Store Credentials

Prompt for and store user credentials that will be used to authenticate with the remote machine.

```powershell
# Prompt for credentials and store in variable
$CRED = Get-Credential -UserName mahendra
```

When executed, this will prompt for:
- **Username**: `mahendra` (pre-filled)
- **Password**: User will be prompted to enter securely

**Example output:**
```
PowerShell credential request
Enter your credentials.
Password for user mahendra: ********
```

### Step 3: Establish Remote Session

Connect to the remote machine using the stored credentials and session options.

```powershell
# Connect to remote machine via HTTPS
Enter-PSSession -ConnectionUri https://20.197.4.146:5986 -Credential $CRED -SessionOption $SOPT
```

**Parameters explained:**
- `-ConnectionUri`: The HTTPS URL of the remote machine (port 5986 is default for HTTPS)
- `-Credential`: The credential object created in Step 2
- `-SessionOption`: The session options created in Step 1

### Step 4: Verify Connection

Once connected, your PowerShell prompt will change to indicate you're in a remote session:

```
[20.197.4.146]: PS C:\Users\mahendra\Documents>
```

You can now run commands on the remote machine as if you were logged in locally.

## Complete Script Example

Here's the complete script with all steps combined:

```powershell
# Step 1: Configure session options
$SOPT = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

# Step 2: Get credentials
$CRED = Get-Credential -UserName mahendra

# Step 3: Connect to remote machine
Enter-PSSession -ConnectionUri https://20.197.4.146:5986 -Credential $CRED -SessionOption $SOPT

# You are now connected to the remote machine
# Run your commands here...

# Step 4: Exit the session when done
Exit-PSSession
```

## Troubleshooting

### Common Issues and Solutions

1. **Connection Timeout**
   - Verify the target machine IP address and port
   - Check firewall rules on both machines
   - Ensure WinRM service is running

2. **Certificate Errors**
   - Use the session options shown above to skip certificate validation
   - Or install proper SSL certificates on the target machine

3. **Authentication Failures**
   - Verify username and password are correct
   - Ensure the user has permission for remote PowerShell access
   - Check if the user is in the "Remote Management Users" group

4. **WinRM Not Configured**
   ```powershell
   # Enable PowerShell remoting on target machine
   Enable-PSRemoting -Force
   
   # Configure HTTPS listener (if needed)
   winrm quickconfig -transport:https
   ```

## Security Considerations

- **Certificate Validation**: In production environments, use proper SSL certificates instead of skipping validation
- **Credentials**: Consider using more secure authentication methods like Kerberos or certificate-based authentication
- **Network Security**: Use VPN or secure network connections when possible
- **Least Privilege**: Ensure remote users have only the minimum required permissions

## Additional Commands

### Useful PowerShell Remoting Commands

```powershell
# List all active remote sessions
Get-PSSession

# Create a persistent session (doesn't enter interactive mode)
$session = New-PSSession -ConnectionUri https://20.197.4.146:5986 -Credential $CRED -SessionOption $SOPT

# Run commands in the session
Invoke-Command -Session $session -ScriptBlock { Get-Process }

# Remove session when done
Remove-PSSession $session
```

## References

- [PowerShell Remoting Documentation](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/running-remote-commands)
- [WinRM Configuration Guide](https://docs.microsoft.com/en-us/windows/win32/winrm/winrm-configuration)
- [PowerShell Security Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/learn/security)   

