# Virtualization and Hyper-V

## 1. Introduction to Virtualization

**Virtualization** is the process of creating a virtual version of something, such as hardware platforms, storage devices, or network resources. It allows multiple operating systems and applications to run on a single physical machine, improving resource utilization and flexibility.

### Benefits of Virtualization
- Better hardware utilization
- Cost savings (less hardware required)
- Easier backup and disaster recovery
- Simplified management and deployment
- Isolation between different environments

## 2. Types of Virtualization

- **Server Virtualization**: Running multiple server OS instances on a single physical server.
- **Desktop Virtualization**: Running desktop environments on a central server.
- **Application Virtualization**: Running applications in isolated containers.
- **Network Virtualization**: Abstracting network resources.

## 3. What is Hyper-V?

**Hyper-V** is Microsoft’s hardware virtualization product. It allows you to create and manage virtual machines (VMs) on Windows Server and Windows 10/11 Pro/Enterprise.

### Key Features
- Support for multiple operating systems (Windows, Linux)
- Resource allocation (CPU, memory, storage, network)
- Snapshots and checkpoints
- Live migration
- Virtual switches and network management

## 4. Hyper-V Architecture

- **Hypervisor**: The core component that manages VMs and hardware resources.
- **Parent Partition**: The main OS instance (host) that manages Hyper-V and VMs.
- **Child Partitions**: The guest VMs running on the host.

## 5. Installing Hyper-V

### On Windows Server:
1. Open **Server Manager** > **Add roles and features**.
2. Select **Hyper-V** role and follow the wizard.
3. Reboot if required.

### On Windows 10/11 Pro/Enterprise:
1. Go to **Control Panel** > **Programs and Features** > **Turn Windows features on or off**.
2. Check **Hyper-V** and click OK.
3. Reboot if required.

## 6. Creating and Managing Virtual Machines

1. Open **Hyper-V Manager**.
2. Click **New > Virtual Machine**.
3. Follow the wizard to specify name, generation, memory, network, and virtual hard disk.
4. Install the guest OS using an ISO or physical disk.

### Common VM Operations
- Start, stop, pause, reset VMs
- Take checkpoints (snapshots)
- Configure resources (CPU, RAM, disk)
- Connect to VM console

## 7. Hyper-V Networking

Hyper-V uses **virtual switches** to connect VMs to each other and to the physical network.

- **External**: Connects VMs to the physical network.
- **Internal**: Connects VMs to each other and the host only.
- **Private**: Connects VMs to each other only.

## 8. Hyper-V Storage

- **Virtual Hard Disks (VHD/VHDX)**: Files that act as disks for VMs.
- **Pass-through Disks**: Physical disks assigned directly to VMs.
- **Checkpoints**: Save the state of a VM for rollback.

## 9. Advanced Features

- **Live Migration**: Move running VMs between hosts with no downtime.
- **Replica**: Replicate VMs for disaster recovery.
- **Resource Metering**: Track resource usage per VM.

## 10. Best Practices

- Allocate resources based on workload needs.
- Use checkpoints before making major changes.
- Regularly update Hyper-V and guest OS.
- Monitor performance and resource usage.
- Secure management interfaces and VM networks.

## 11. Useful Hyper-V PowerShell Commands

```powershell
# List all VMs
Get-VM

# Start a VM
Start-VM -Name "VMName"

# Stop a VM
Stop-VM -Name "VMName"

# Create a new VM
New-VM -Name "TestVM" -MemoryStartupBytes 2GB -Generation 2 -NewVHDPath "C:\VMs\TestVM.vhdx" -NewVHDSizeBytes 40GB

# Checkpoint a VM
Checkpoint-VM -Name "VMName"
```

## 12. Additional Resources

- [Microsoft Hyper-V Documentation](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/)
- [Hyper-V PowerShell Reference](https://docs.microsoft.com/en-us/powershell/module/hyper-v/)
