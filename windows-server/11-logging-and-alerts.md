# Windows Server: Logging and Alerts

## 1. Introduction
Server logging and alerting are critical for monitoring, troubleshooting, and securing Windows Server environments. Proper configuration helps administrators detect issues, respond to incidents, and maintain compliance.

## 2. Windows Server Logging Overview

### What is Logging?
Logging is the process of recording events, activities, and errors that occur on a server. These logs provide valuable information for:
- Troubleshooting problems
- Auditing user activity
- Detecting security incidents
- Ensuring system health

### Key Windows Server Log Types
- **System Logs**: Hardware and system-level events
- **Application Logs**: Events from installed applications
- **Security Logs**: Authentication, authorization, and audit events
- **Setup Logs**: Installation and setup events
- **Forwarded Events**: Logs collected from other servers

## 3. Event Viewer

### What is Event Viewer?
Event Viewer is the built-in Windows tool for viewing and managing event logs.

#### How to Open Event Viewer
1. Press `Win + R`, type `eventvwr.msc`, and press Enter.
2. Or, search for "Event Viewer" in the Start menu.

#### Navigating Event Viewer
- **Windows Logs**: Application, Security, Setup, System, Forwarded Events
- **Applications and Services Logs**: Logs from specific services or applications

#### Viewing and Filtering Logs
- Use the left pane to select a log category
- Use the right pane to filter, search, or export logs

#### Common Tasks
- **Filter Current Log**: Find specific events
- **Create Custom Views**: Save frequently used filters
- **Export Logs**: Save logs for analysis or archiving

## 4. Configuring Logging

### Log Retention and Size
- Set maximum log size to prevent disk space issues
- Configure log retention policies (overwrite, archive, etc.)

### Security Auditing
- Enable auditing for logon events, file access, policy changes, etc.
- Use Group Policy: `gpedit.msc` > Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration

### Forwarding Logs
- Use **Windows Event Forwarding (WEF)** to collect logs from multiple servers to a central collector
- Configure via Group Policy or PowerShell

## 5. Alerts and Notifications

### Why Set Up Alerts?
Alerts notify administrators of critical events, allowing for quick response to issues such as failed logins, service failures, or security breaches.

### Methods for Alerts
- **Event Viewer Tasks**: Attach tasks to specific events (e.g., send email, run script)
- **Task Scheduler**: Trigger actions based on event logs
- **Third-Party Tools**: Solutions like SolarWinds, Nagios, or SCOM for advanced alerting

#### Example: Creating an Alert for Failed Logins
1. Open Event Viewer
2. Navigate to Security log
3. Find the event ID for failed logins (e.g., 4625)
4. Right-click > Attach Task to This Event
5. Choose action (send email, display message, run program)

## 6. PowerShell for Logging and Alerts

### Viewing Logs with PowerShell
```powershell
Get-EventLog -LogName System -Newest 10
Get-WinEvent -LogName Security | Where-Object { $_.Id -eq 4625 }
```

### Creating Alerts with PowerShell
You can use `Register-ObjectEvent` or scheduled tasks to automate responses to log events.

## 7. Best Practices
- Regularly review logs for unusual activity
- Secure log files and restrict access
- Set up centralized logging for large environments
- Automate alerts for critical events
- Archive logs for compliance and audits

## 8. Additional Resources
- [Microsoft Docs: Event Viewer](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-viewer)
- [Windows Security Auditing](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-security-audit-policies)
- [PowerShell Logging Cmdlets](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/)
 