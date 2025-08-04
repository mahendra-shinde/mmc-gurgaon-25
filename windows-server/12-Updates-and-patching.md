# Updates and Patching in Windows Server

## 1. Introduction
Keeping Windows Server systems up to date is critical for security, stability, and performance. Updates and patches address vulnerabilities, fix bugs, and add new features. This guide covers the essentials of managing updates and patching in Windows Server environments.

## 2. Types of Updates
- **Security Updates:** Address vulnerabilities that could be exploited by malware or attackers.
- **Critical Updates:** Fix major issues that could affect system stability or data integrity.
- **Cumulative Updates:** Combine multiple updates into a single package.
- **Feature Updates:** Add new features or enhance existing ones.
- **Driver Updates:** Update hardware drivers for compatibility and performance.

## 3. Windows Update Mechanisms

### a. Windows Update (WU)
The built-in service for downloading and installing updates directly from Microsoft.

### b. Windows Server Update Services (WSUS)
An on-premises tool for managing and distributing updates to multiple servers and clients in a controlled manner.

### c. Microsoft Update Catalog
Manual download and installation of specific updates from [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/).

## 4. Managing Updates

### a. Using Windows Update GUI
1. Open **Settings** > **Update & Security** > **Windows Update**.
2. Click **Check for updates**.
3. Review and install available updates.

### b. Using PowerShell
```powershell
# Check for updates
Get-WindowsUpdate

# Install updates
Install-WindowsUpdate
```
*Requires the `PSWindowsUpdate` module.*

### c. Using WSUS
1. Configure WSUS server and clients.
2. Approve updates for deployment.
3. Monitor update status via WSUS console.

## 5. Best Practices
- **Test updates** in a staging environment before deploying to production.
- **Schedule maintenance windows** to minimize downtime.
- **Monitor update status** and compliance regularly.
- **Automate updates** where possible, but review critical/feature updates manually.
- **Maintain backups** before applying major updates or patches.

## 6. Troubleshooting Update Issues
- Use **Windows Update Troubleshooter**.
- Check update logs: `C:\Windows\WindowsUpdate.log`.
- Use PowerShell cmdlets like `Get-WindowsUpdateLog`.
- Ensure sufficient disk space and network connectivity.
- Review error codes and search Microsoft documentation for solutions.

## 7. Additional Resources
- [Windows Server Update Documentation](https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/get-started/windows-server-update-services-wsus)
- [PSWindowsUpdate PowerShell Module](https://github.com/microsoft/PSWindowsUpdate)
- [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/)

## 8. Lab Exercise
1. Check for updates on your Windows Server using both GUI and PowerShell.
2. Install the `PSWindowsUpdate` module and run `Get-WindowsUpdate`.
3. Review update history and identify the last security update installed.
4. (Optional) Set up a WSUS server and configure a client to receive updates from it.
