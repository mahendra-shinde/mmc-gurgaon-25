# Shell Scripting Guide

## Table of Contents
1. [Introduction to Shell Scripts](#introduction)
2. [Creating and Executing Scripts](#creating-executing)
3. [Variables in Shell Scripts](#variables)
4. [Control Statements](#control-statements)
5. [Functions](#functions)
6. [Best Practices](#best-practices)

## Introduction to Shell Scripts {#introduction}

Shell scripting is a powerful way to automate tasks in Linux/Unix systems. A shell script is a text file containing a sequence of commands that can be executed by the shell interpreter.

### What is a Shell Script?
- A shell script is a program written for the shell (command-line interpreter)
- Scripts are written in plain text files with or without the `.sh` extension
- They contain commands that would normally be typed at the command line
- Scripts can include variables, functions, loops, and conditional statements

### Common Shell Types
- **Bash** (Bourne Again Shell) - Most common on Linux
- **Zsh** (Z Shell) - Popular alternative with enhanced features
- **Fish** (Friendly Interactive Shell) - User-friendly shell
- **Dash** (Debian Almquist Shell) - Lightweight shell

## Creating and Executing Scripts {#creating-executing}

### 1. Creating a Shell Script

```bash
# Create a new script file
touch myscript.sh

# Edit the script
nano myscript.sh
# or
vim myscript.sh
```

### 2. Shebang Line
Every shell script should start with a shebang (`#!`) line to specify the interpreter:

```bash
#!/bin/bash          # Use bash interpreter
#!/bin/sh            # Use system default shell
#!/usr/bin/env bash  # Use bash from PATH (more portable)
```

### 3. Making Scripts Executable

Use the `chmod` command to make your script executable:

```bash
chmod u+x script.sh    # Make executable for owner (user)
chmod g+x script.sh    # Make executable for group
chmod o+x script.sh    # Make executable for others
chmod +x script.sh     # Make executable for all users
chmod 755 script.sh    # Set specific permissions (rwxr-xr-x)
chmod 744 script.sh    # Owner: read/write/execute, Others: read only
```

### 4. Executing Scripts

There are several ways to execute a shell script:

```bash
# Method 1: Direct execution (script must be executable)
./script.sh

# Method 2: Using bash interpreter
bash script.sh

# Method 3: Using source command (runs in current shell)
source script.sh
# or
. script.sh

# Method 4: Full path execution
/home/user/scripts/script.sh

# Method 5: If script directory is in PATH
script.sh
```

### Example: Simple Script

```bash
#!/bin/bash
# This is a comment
echo "Hello, World!"
echo "Current date: $(date)"
echo "Current user: $(whoami)"
```

## Variables in Shell Scripts {#variables}

### 1. Variable Declaration and Assignment

```bash
#!/bin/bash

# Variable assignment (no spaces around =)
name="John Doe"
age=25
is_student=true

# Using variables
echo "Name: $name"
echo "Age: $age"
echo "Student: $is_student"
```

### 2. Types of Variables

#### Local Variables
```bash
#!/bin/bash
local_var="This is local to the script"
```

#### Environment Variables
```bash
#!/bin/bash
export GLOBAL_VAR="This is available to child processes"
echo $HOME        # Built-in environment variable
echo $USER        # Current username
echo $PATH        # System PATH
```

#### Special Variables
```bash
#!/bin/bash
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
echo "Exit status of last command: $?"
echo "Process ID: $$"
```

### 3. Variable Operations

#### String Operations
```bash
#!/bin/bash
text="Hello World"
echo "Length: ${#text}"                    # Length of string
echo "Substring: ${text:0:5}"              # Extract substring
echo "Replace: ${text/World/Universe}"     # Replace substring
echo "Uppercase: ${text^^}"               # Convert to uppercase
echo "Lowercase: ${text,,}"               # Convert to lowercase
```

#### Arithmetic Operations
```bash
#!/bin/bash
num1=10
num2=5

# Using arithmetic expansion
result=$((num1 + num2))
echo "Addition: $result"

# Using expr command
result=$(expr $num1 \* $num2)
echo "Multiplication: $result"

# Using let command
let result=num1-num2
echo "Subtraction: $result"
```

### 4. Reading User Input

```bash
#!/bin/bash
echo "Enter your name: "
read username
echo "Hello, $username!"

# Read with prompt
read -p "Enter your age: " age
echo "You are $age years old"

# Read password (hidden input)
read -s -p "Enter password: " password
echo -e "\nPassword entered"
```

### 5. Arrays

```bash
#!/bin/bash
# Declare array
fruits=("apple" "banana" "orange" "grape")

# Access elements
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[@]}"
echo "Number of fruits: ${#fruits[@]}"

# Add element
fruits+=("mango")

# Loop through array
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
```

## Control Statements {#control-statements}

### 1. Conditional Statements

#### If-Else Statement
```bash
#!/bin/bash
age=18

if [ $age -ge 18 ]; then
    echo "You are an adult"
elif [ $age -ge 13 ]; then
    echo "You are a teenager"
else
    echo "You are a child"
fi
```

#### Test Conditions
```bash
#!/bin/bash
# Numeric comparisons
if [ $num1 -eq $num2 ]; then echo "Equal"; fi
if [ $num1 -ne $num2 ]; then echo "Not equal"; fi
if [ $num1 -gt $num2 ]; then echo "Greater than"; fi
if [ $num1 -ge $num2 ]; then echo "Greater or equal"; fi
if [ $num1 -lt $num2 ]; then echo "Less than"; fi
if [ $num1 -le $num2 ]; then echo "Less or equal"; fi

# String comparisons
if [ "$str1" = "$str2" ]; then echo "Strings equal"; fi
if [ "$str1" != "$str2" ]; then echo "Strings not equal"; fi
if [ -z "$str1" ]; then echo "String is empty"; fi
if [ -n "$str1" ]; then echo "String is not empty"; fi

# File tests
if [ -f "$filename" ]; then echo "File exists"; fi
if [ -d "$dirname" ]; then echo "Directory exists"; fi
if [ -r "$filename" ]; then echo "File is readable"; fi
if [ -w "$filename" ]; then echo "File is writable"; fi
if [ -x "$filename" ]; then echo "File is executable"; fi
```

#### Case Statement
```bash
#!/bin/bash
read -p "Enter a choice (1-3): " choice

case $choice in
    1)
        echo "You chose option 1"
        ;;
    2)
        echo "You chose option 2"
        ;;
    3)
        echo "You chose option 3"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
```

### 2. Loops

#### For Loop
```bash
#!/bin/bash
# Simple for loop
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# Range-based for loop
for i in {1..10}; do
    echo "Count: $i"
done

# C-style for loop
for ((i=1; i<=5; i++)); do
    echo "Iteration: $i"
done

# Loop through files
for file in *.txt; do
    echo "Processing: $file"
done
```

#### While Loop
```bash
#!/bin/bash
counter=1
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < "input.txt"
```

#### Until Loop
```bash
#!/bin/bash
counter=1
until [ $counter -gt 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done
```

### 3. Loop Control

```bash
#!/bin/bash
for i in {1..10}; do
    if [ $i -eq 3 ]; then
        continue    # Skip iteration
    fi
    if [ $i -eq 8 ]; then
        break      # Exit loop
    fi
    echo "Number: $i"
done
```

## Functions {#functions}

### 1. Function Declaration and Usage

```bash
#!/bin/bash
# Function declaration
greet() {
    echo "Hello, $1!"
}

# Function with return value
add_numbers() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result
}

# Function usage
greet "Alice"
sum=$(add_numbers 5 3)
echo "Sum: $sum"
```

### 2. Function with Local Variables

```bash
#!/bin/bash
calculate_area() {
    local length=$1
    local width=$2
    local area=$((length * width))
    echo "Area of rectangle: $area"
    return 0
}

calculate_area 10 5
```

### 3. Function with Multiple Return Values

```bash
#!/bin/bash
get_system_info() {
    local hostname=$(hostname)
    local uptime=$(uptime | awk '{print $3,$4}')
    echo "$hostname:$uptime"
}

info=$(get_system_info)
IFS=':' read -r host up <<< "$info"
echo "Hostname: $host"
echo "Uptime: $up"
```

## Best Practices {#best-practices}

### 1. Script Structure

```bash
#!/bin/bash
# Script: backup_files.sh
# Purpose: Backup important files
# Author: Your Name
# Date: $(date)
# Version: 1.0

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Constants
readonly BACKUP_DIR="/backup"
readonly LOG_FILE="/var/log/backup.log"

# Functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Main script logic
main() {
    log_message "Starting backup process"
    # Your code here
    log_message "Backup completed"
}

# Execute main function
main "$@"
```

### 2. Error Handling

```bash
#!/bin/bash
# Check if file exists before processing
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found" >&2
    exit 1
fi

# Use trap for cleanup
cleanup() {
    rm -f "$temp_file"
    echo "Cleanup completed"
}
trap cleanup EXIT

# Validate number of arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source> <destination>" >&2
    exit 1
fi
```

### 3. Security Considerations

```bash
#!/bin/bash
# Quote variables to prevent word splitting
echo "User input: '$user_input'"

# Use full paths for commands
/bin/rm "$file"

# Validate input
if [[ ! "$input" =~ ^[a-zA-Z0-9]+$ ]]; then
    echo "Invalid input format" >&2
    exit 1
fi

# Set restrictive umask
umask 077
```

### 4. Code Organization

```bash
#!/bin/bash
# Use meaningful variable names
backup_directory="/home/user/backup"
current_timestamp=$(date +%Y%m%d_%H%M%S)

# Use functions for reusable code
create_backup_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created backup directory: $1"
    fi
}

# Comment complex operations
# Calculate disk usage and convert to human-readable format
disk_usage=$(du -sh "$directory" | awk '{print $1}')
```

### Example: Complete Script

```bash
#!/bin/bash
# File: system_monitor.sh
# Purpose: Monitor system resources and log alerts

set -euo pipefail

# Configuration
readonly LOG_FILE="/var/log/system_monitor.log"
readonly CPU_THRESHOLD=80
readonly MEMORY_THRESHOLD=90
readonly DISK_THRESHOLD=85

# Logging function
log_alert() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ALERT: $message" | tee -a "$LOG_FILE"
}

# Check CPU usage
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    cpu_usage=${cpu_usage%.*}  # Remove decimal part
    
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        log_alert "High CPU usage detected: ${cpu_usage}%"
    fi
}

# Check memory usage
check_memory() {
    local memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    
    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        log_alert "High memory usage detected: ${memory_usage}%"
    fi
}

# Check disk usage
check_disk() {
    while IFS= read -r line; do
        local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        local filesystem=$(echo "$line" | awk '{print $6}')
        
        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            log_alert "High disk usage on $filesystem: ${usage}%"
        fi
    done < <(df -h | grep -E '^/dev/')
}

# Main monitoring function
main() {
    echo "Starting system monitoring..."
    check_cpu
    check_memory
    check_disk
    echo "System monitoring completed"
}

# Execute if script is run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
```

This comprehensive guide covers the fundamentals of shell scripting, including variables, control statements, functions, and best practices for writing maintainable and secure shell scripts.
