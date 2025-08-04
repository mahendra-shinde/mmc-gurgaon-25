# Windows PowerShell: Introduction, Syntax, and Scripting

## What is Windows PowerShell?

Windows PowerShell is a powerful command-line shell and scripting language developed by Microsoft, designed especially for system administration. It helps IT professionals and power users control and automate the administration of Windows operating systems and applications.

**Key Features:**
- Built on the .NET framework
- Supports both interactive command-line use and scripting
- Access to system administration tasks (file system, registry, processes, services, etc.)
- Extensible with modules and custom scripts

## PowerShell Basics

### Launching PowerShell
- Open the Start menu, type `PowerShell`, and select **Windows PowerShell** or **PowerShell 7** (if installed).
- The prompt typically looks like: `PS C:\Users\YourName>`

### Cmdlets
PowerShell commands are called **cmdlets** (pronounced "command-lets"). Cmdlets use a `Verb-Noun` naming pattern.

**Examples:**
- `Get-Process` — Lists running processes
- `Get-Service` — Lists services
- `Set-Date` — Sets the system date and time

### Basic Syntax
- **Cmdlet Structure:** `Verb-Noun -Parameter Value`
- **Example:** `Get-ChildItem -Path C:\Windows`
- **Aliases:** Many cmdlets have shorter aliases (e.g., `ls` for `Get-ChildItem`)

### Common Cmdlets
| Cmdlet            | Alias | Description                  |
|-------------------|-------|------------------------------|
| Get-Help          | help  | Shows help for cmdlets       |
| Get-Command       | gcm   | Lists available cmdlets      |
| Get-Process       | gps   | Lists running processes      |
| Get-Service       | gsv   | Lists services               |
| Set-ExecutionPolicy |      | Sets script execution policy |

### Variables
- Variables start with `$` (e.g., `$name = "Mahendra"`)
- PowerShell is case-insensitive

### Pipelining
- Output of one cmdlet can be passed to another using `|`
- Example: `Get-Process | Sort-Object CPU -Descending | Select-Object -First 5`

### Comments
- Single line: `# This is a comment`
- Multi-line: `<# This is a 
  multi-line comment #>`

## PowerShell Scripting

PowerShell scripts are text files with a `.ps1` extension. They can automate repetitive tasks, configure systems, and manage resources.

### Creating and Running Scripts
1. Open a text editor (e.g., VS Code, Notepad++)
2. Write your script and save it as `myscript.ps1`
3. Run the script in PowerShell:
   ```powershell
   .\myscript.ps1
   ```

**Note:** You may need to set the execution policy:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Script Example
```powershell
# Simple PowerShell script
$name = Read-Host "Enter your name"
Write-Host "Hello, $name!"
```

### Control Structures
- **If Statement:**
  ```powershell
  if ($a -gt 10) {
      Write-Host "a is greater than 10"
  } else {
      Write-Host "a is 10 or less"
  }
  ```
- **For Loop:**
  ```powershell
  for ($i = 1; $i -le 5; $i++) {
      Write-Host $i
  }
  ```
- **Foreach Loop:**
  ```powershell
  foreach ($item in 1..5) {
      Write-Host $item
  }
  ```

### Functions
```powershell
function Greet-User($name) {
    Write-Host "Hello, $name!"
}
Greet-User "Mahendra"
```

## Resources
- [Microsoft PowerShell Documentation](https://docs.microsoft.com/powershell/)
- Use `Get-Help` in PowerShell for built-in help
