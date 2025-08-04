
# PowerShell Remoting

PowerShell Remoting is a feature in Windows PowerShell that allows administrators to run commands on remote computers. It is built on top of Windows Remote Management (WinRM), which is Microsoft’s implementation of the WS-Management protocol.

## Key Concepts

- **Remote Sessions:** Allows you to create persistent connections to remote computers.
- **One-to-One Remoting:** Run a command on a single remote computer.
- **One-to-Many Remoting:** Run a command on multiple remote computers simultaneously.
- **Implicit Remoting:** Import commands from a remote session to use them as if they were local.

## Enabling PowerShell Remoting

On the computer you want to manage remotely, open PowerShell as Administrator and run:

```powershell
Enable-PSRemoting -Force
```

This command:
- Starts the WinRM service
- Sets the service to start automatically
- Creates a firewall rule to allow remote access

## Basic Usage

### 1. Running a Command on a Remote Computer

```powershell
Invoke-Command -ComputerName SERVER01 -ScriptBlock { Get-Process }
```

### 2. Entering an Interactive Remote Session

```powershell
Enter-PSSession -ComputerName SERVER01
# To exit the session:
Exit-PSSession
```

### 3. Running Commands on Multiple Computers

```powershell
Invoke-Command -ComputerName SERVER01,SERVER02 -ScriptBlock { Get-Service }
```

### 4. Using Credentials

```powershell
$cred = Get-Credential
Invoke-Command -ComputerName SERVER01 -Credential $cred -ScriptBlock { hostname }
```

## Implicit Remoting

Import commands from a remote session:

```powershell
$session = New-PSSession -ComputerName SERVER01
Import-PSSession $session -Module ActiveDirectory
```

## Security Considerations

- By default, remoting is enabled only on private and domain networks.
- Communication is encrypted using Kerberos (domain) or NTLM (workgroup).
- Use HTTPS for added security (requires certificate setup).
- Always use strong credentials and restrict access via firewall rules.

## Troubleshooting

- Ensure WinRM service is running: `Get-Service WinRM`
- Check firewall rules: `Get-NetFirewallRule -Name *winrm*`
- Use `Test-WsMan SERVER01` to verify connectivity.

## References

- [Microsoft Docs: PowerShell Remoting](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/)
- [Enable-PSRemoting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting)
