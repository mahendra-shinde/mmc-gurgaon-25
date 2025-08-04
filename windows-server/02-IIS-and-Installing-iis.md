# Installing Windows OS and IIS on Windows Server

## 1. Installing Windows Operating System

### Prerequisites
- Windows Server installation media (DVD/ISO/USB)
- Hardware that meets minimum requirements

### Steps
1. **Insert Installation Media**: Insert the Windows Server DVD, USB, or mount the ISO file.
2. **Boot from Media**: Restart the server and boot from the installation media. You may need to change the boot order in BIOS/UEFI.
3. **Start Installation**:
    - Select language, time, and keyboard preferences.
    - Click **Install Now**.
4. **Enter Product Key**: Enter your Windows Server product key if prompted.
5. **Select Edition**: Choose the appropriate Windows Server edition (e.g., Standard, Datacenter).
6. **Accept License Terms**: Read and accept the license agreement.
7. **Choose Installation Type**:
    - **Custom**: For a fresh installation.
    - **Upgrade**: To upgrade an existing installation.
8. **Partition Disks**: Select the disk/partition where Windows will be installed. Create or format partitions as needed.
9. **Begin Installation**: Click **Next** to start the installation. The system will copy files and restart several times.
10. **Initial Setup**:
    - Set the Administrator password.
    - Log in for the first time.

## 2. Installing IIS (Internet Information Services)

IIS is a web server role in Windows Server used to host websites and web applications.

### Method 1: Using Server Manager (GUI)
1. **Open Server Manager**: Click the Start menu, search for **Server Manager**, and open it.
2. **Add Roles and Features**:
    - Click **Manage** > **Add Roles and Features**.
    - Click **Next** through the wizard until you reach **Server Roles**.
3. **Select Web Server (IIS)**:
    - Check **Web Server (IIS)**.
    - Add required features if prompted.
4. **Continue Wizard**:
    - Click **Next** through Features and Web Server Role Services (select additional services if needed).
    - Click **Install**.
5. **Complete Installation**:
    - Wait for the installation to finish.
    - Click **Close** when done.
6. **Verify IIS**:
    - Open a web browser and go to `http://localhost`. You should see the IIS welcome page.

### Method 2: Using PowerShell
1. **Open PowerShell as Administrator**
2. **Run the following command:**
    ```powershell
    Install-WindowsFeature -name Web-Server -IncludeManagementTools
    ```
3. **Verify Installation:**
    - Run: `Get-WindowsFeature Web-Server`
    - Open a browser and visit `http://localhost`.

---

**Note:** After installing IIS, you can further configure it to host websites, add features, or secure your server as needed.
