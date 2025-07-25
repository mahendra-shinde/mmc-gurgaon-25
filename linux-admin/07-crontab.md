# Crontab Tutorial

## Table of Contents
1. [Introduction](#introduction)
2. [What is Crontab?](#what-is-crontab)
3. [Crontab Syntax](#crontab-syntax)
4. [Time Format](#time-format)
5. [Common Crontab Commands](#common-crontab-commands)
6. [Crontab Examples](#crontab-examples)
7. [Special Characters](#special-characters)

## Introduction

Crontab (CRON Table) is a time-based job scheduler in Unix-like operating systems. It allows users to schedule jobs (commands or scripts) to run automatically at specified times and dates.

## What is Crontab?

Crontab is a configuration file that specifies shell commands to run periodically on a given schedule. The cron daemon (`crond`) reads the crontab files and executes the commands at the specified times.

### Key Features:
- **Automated execution** of scripts and commands
- **Flexible scheduling** options
- **User-specific** and system-wide cron jobs
- **No user interaction** required once set up

## Crontab Syntax

The basic syntax of a crontab entry consists of six fields:

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, where 0 and 7 are Sunday)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

## Time Format

### Field Values:
- **Minute**: 0-59
- **Hour**: 0-23 (0 = midnight, 23 = 11 PM)
- **Day of Month**: 1-31
- **Month**: 1-12 (1 = January, 12 = December)
- **Day of Week**: 0-7 (0 and 7 = Sunday, 1 = Monday, 6 = Saturday)

### Special Values:
- `*` : Any value (wildcard)
- `,` : Value list separator
- `-` : Range of values
- `/` : Step values

## Common Crontab Commands

### Managing Crontab:

```bash
# View current user's crontab
crontab -l

# Edit current user's crontab
crontab -e

# Remove current user's crontab
crontab -r

# Install crontab from a file
crontab filename

# View another user's crontab (root only)
crontab -l -u username

# Edit another user's crontab (root only)
crontab -e -u username
```

### System Crontab Files:
- `/etc/crontab` - System-wide crontab
- `/etc/cron.d/` - Directory for additional cron files
- `/var/spool/cron/` - User crontab files

## Crontab Examples

### Basic Examples:

```bash
# Run every minute
* * * * * /path/to/script.sh

# Run at 2:30 AM every day
30 2 * * * /path/to/backup.sh

# Run at 9 AM on weekdays (Monday to Friday)
0 9 * * 1-5 /path/to/workday_script.sh

# Run every Sunday at midnight
0 0 * * 0 /path/to/weekly_cleanup.sh

# Run on the 1st day of every month at 6 AM
0 6 1 * * /path/to/monthly_report.sh

# Run every 15 minutes
*/15 * * * * /path/to/frequent_check.sh

# Run every hour at minute 30
30 * * * * /path/to/hourly_task.sh

# Run twice a day (6 AM and 6 PM)
0 6,18 * * * /path/to/twice_daily.sh
```

### Advanced Examples:

```bash
# Run every 2 hours between 9 AM and 5 PM on weekdays
0 9-17/2 * * 1-5 /path/to/business_hours.sh

# Run every 5 minutes during working hours (9 AM to 5 PM)
*/5 9-17 * * 1-5 /path/to/frequent_work_check.sh

# Run at 11:30 PM on the last day of every month
30 23 28-31 * * [ $(date -d tomorrow +\%d) -eq 1 ] && /path/to/month_end.sh

# Run every quarter (Jan, Apr, Jul, Oct) on the 1st at midnight
0 0 1 1,4,7,10 * /path/to/quarterly_task.sh

# Multiple commands in one line
0 8 * * 1-5 /path/to/script1.sh && /path/to/script2.sh

# Run with specific environment variables
0 9 * * * DISPLAY=:0 /path/to/gui_app.sh
```

## Special Characters

### Asterisk (*):
Matches any value in the field
```bash
# Every minute of every hour of every day
* * * * * command
```

### Comma (,):
Separates multiple values
```bash
# Run at 9 AM, 12 PM, and 6 PM
0 9,12,18 * * * command
```

### Hyphen (-):
Specifies a range of values
```bash
# Run Monday through Friday
0 9 * * 1-5 command
```

### Slash (/):
Specifies step values
```bash
# Every 2 hours
0 */2 * * * command

# Every 10 minutes
*/10 * * * * command
```

### Special Strings:
```bash
@reboot         # Run once at startup
@yearly         # Run once a year (0 0 1 1 *)
@annually       # Same as @yearly
@monthly        # Run once a month (0 0 1 * *)
@weekly         # Run once a week (0 0 * * 0)
@daily          # Run once a day (0 0 * * *)
@midnight       # Same as @daily
@hourly         # Run once an hour (0 * * * *)
```

### Using Special Strings:
```bash
@daily /path/to/daily_backup.sh
@reboot /path/to/startup_script.sh
@hourly /path/to/hourly_check.sh
```

