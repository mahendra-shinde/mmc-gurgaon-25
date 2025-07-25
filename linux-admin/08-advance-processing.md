# Advanced Text Processing Guide: AWK, SED, and GREP

## Overview
This guide covers three powerful text processing tools in Linux:
- **GREP**: Global Regular Expression Print - for searching text patterns
- **SED**: Stream Editor - for editing text streams
- **AWK**: Pattern scanning and processing language - for complex text processing

---

## 1. GREP - Global Regular Expression Print

### Basic Usage
```bash
# Basic pattern matching
grep "pattern" file.txt
grep -i "pattern" file.txt        # Case insensitive
grep -v "pattern" file.txt        # Invert match (exclude lines)
grep -n "pattern" file.txt        # Show line numbers
grep -c "pattern" file.txt        # Count matching lines
grep -l "pattern" *.txt           # List files containing pattern
```

### Advanced Options
```bash
# Context and formatting
grep -A 3 "pattern" file.txt      # Show 3 lines after match
grep -B 3 "pattern" file.txt      # Show 3 lines before match
grep -C 3 "pattern" file.txt      # Show 3 lines around match
grep -w "word" file.txt           # Match whole word only
grep -x "line" file.txt           # Match whole line only
grep -r "pattern" /path/          # Recursive search in directory
```

### Regular Expressions with GREP
```bash
# Anchors
grep "^start" file.txt            # Lines starting with "start"
grep "end$" file.txt              # Lines ending with "end"
grep "^$" file.txt                # Empty lines

# Character classes
grep "[0-9]" file.txt             # Lines containing digits
grep "[a-zA-Z]" file.txt          # Lines containing letters
grep "[^0-9]" file.txt            # Lines NOT containing digits

# Quantifiers
grep "colou\?r" file.txt          # Match "color" or "colour"
grep "file[0-9]*" file.txt        # Match "file" followed by digits
grep "a\{3\}" file.txt            # Match exactly 3 'a's

# Extended regex (use -E flag)
grep -E "pattern1|pattern2" file.txt    # OR operation
grep -E "^(http|https)://" file.txt     # URLs starting with http/https
```

### Practical GREP Examples
```bash
# System administration
grep -i error /var/log/syslog
ps aux | grep nginx
grep -r "TODO" /home/user/projects/
netstat -tuln | grep :80
history | grep git

# Log analysis
grep "$(date +%Y-%m-%d)" /var/log/apache2/access.log
grep "Failed password" /var/log/auth.log
grep -E "ERROR|WARN|FATAL" application.log
```

---

## 2. SED - Stream Editor

### Basic Operations
```bash
# Substitution
sed 's/old/new/' file.txt                # Replace first occurrence per line
sed 's/old/new/g' file.txt               # Replace all occurrences (global)
sed 's/old/new/2' file.txt               # Replace second occurrence per line
sed 's/old/new/gi' file.txt              # Global and case insensitive

# Print operations
sed -n '5p' file.txt                     # Print line 5 only
sed -n '1,10p' file.txt                  # Print lines 1-10
sed -n '/pattern/p' file.txt             # Print lines matching pattern

# Delete operations
sed '5d' file.txt                        # Delete line 5
sed '1,10d' file.txt                     # Delete lines 1-10
sed '/pattern/d' file.txt                # Delete lines matching pattern
```

### Advanced SED Operations
```bash
# Using different delimiters
sed 's|/old/path|/new/path|g' file.txt

# Backreferences
sed 's/\(.*\)/[\1]/' file.txt            # Add brackets around entire line
sed 's/\([0-9]*\)/(\1)/' file.txt        # Put parentheses around numbers

# Line modifications
sed 's/^/    /' file.txt                  # Add 4 spaces at beginning
sed 's/$/;/' file.txt                     # Add semicolon at end
sed 's/^#//' file.txt                     # Remove comment character

# Insert, append, change
sed '2i\New line here' file.txt          # Insert line before line 2
sed '2a\New line here' file.txt          # Append line after line 2
sed '2c\Replacement line' file.txt       # Change line 2
sed '/pattern/i\New line' file.txt       # Insert before pattern match
```

### Multiple SED Commands
```bash
# Multiple operations
sed -e 's/old/new/g' -e 's/foo/bar/g' file.txt
sed 's/old/new/g; s/foo/bar/g' file.txt

# Using script file
sed -f script.sed file.txt

# In-place editing (be careful!)
sed -i 's/old/new/g' file.txt
sed -i.bak 's/old/new/g' file.txt        # Create backup
```

### Practical SED Examples
```bash
# Configuration file editing
sed -i 's/127.0.0.1/192.168.1.100/g' /etc/hosts
sed 's/^#\(.*\)/\1/' config.file         # Uncomment lines
sed 's/^/# /' file.txt                    # Comment all lines

# Data cleaning
sed 's/  */ /g'                           # Replace multiple spaces with single
sed '/^$/d' file.txt                      # Remove empty lines
sed '1d' file.txt                         # Remove header line
```

---

## 3. AWK - Pattern Scanning and Processing Language

### Basic AWK Usage
```bash
# Basic printing
awk '{print}' file.txt                    # Print all lines (same as cat)
awk '{print $1}' file.txt                 # Print first field
awk '{print $NF}' file.txt                # Print last field
awk '{print NF}' file.txt                 # Print number of fields
awk '{print NR}' file.txt                 # Print line number
awk '{print NR, $0}' file.txt             # Print line number and content
```

### Field Operations
```bash
# Field separators
awk -F: '{print $1}' /etc/passwd          # Use colon as field separator
awk -F'\t' '{print $1, $3}' file.tsv     # Tab-separated values
awk 'BEGIN{FS=":"} {print $1}' file.txt   # Set field separator in BEGIN

# Field manipulation
awk '{print $1, $3}' file.txt             # Print fields 1 and 3 with space
awk '{print $1 $3}' file.txt              # Concatenate fields 1 and 3
awk '{print $1 "-" $2}' file.txt          # Print fields with separator
```

### Pattern Matching in AWK
```bash
# Pattern-based processing
awk '/pattern/ {print}' file.txt          # Print lines matching pattern
awk '!/pattern/ {print}' file.txt         # Print lines NOT matching pattern
awk '$1 == "value" {print}' file.txt      # Print if first field equals value
awk '$3 > 100 {print}' file.txt           # Print if third field > 100
awk 'NF > 5 {print}' file.txt             # Print lines with more than 5 fields
awk 'length($0) > 50 {print}' file.txt    # Print lines longer than 50 chars
```

### AWK Built-in Variables
| Variable | Description |
|----------|-------------|
| `NR` | Number of records (current line number) |
| `NF` | Number of fields in current record |
| `FS` | Field separator (default: space/tab) |
| `RS` | Record separator (default: newline) |
| `OFS` | Output field separator |
| `ORS` | Output record separator |
| `FILENAME` | Current filename being processed |

### Mathematical Operations
```bash
# Calculations
awk '{sum += $1} END {print "Total:", sum}' file.txt
awk '{sum += $1; count++} END {print "Average:", sum/count}' file.txt
awk '{if($1 > max) max = $1} END {print "Max:", max}' file.txt
awk '{print $1, $1 * 1.1}' file.txt       # Add 10% to first column
awk '{print $1 * $2}' file.txt            # Multiply columns 1 and 2
```

### String Operations
```bash
# String functions
awk '{print toupper($1)}' file.txt        # Convert to uppercase
awk '{print tolower($1)}' file.txt        # Convert to lowercase
awk '{print length($1)}' file.txt         # Print length of first field
awk '{print substr($1, 1, 3)}' file.txt   # Print first 3 characters
awk '{gsub(/old/, "new"); print}' file.txt # Global substitution in line
```

### Advanced AWK Examples
```bash
# BEGIN and END blocks
awk 'BEGIN{print "Header"} {print} END{print "Footer"}' file.txt

# Arrays and counting
awk '{a[$1]++} END {for(i in a) print i, a[i]}' file.txt

# Conditional processing
awk '{if($3 > 50) print $1 " is high"; else print $1 " is low"}' file.txt

# Multiple files
awk '{print FILENAME, NR, $0}' *.txt
```

---

## 4. Combining AWK, SED, and GREP

### Powerful Command Combinations
```bash
# Extract and process
grep "ERROR" log.txt | awk '{print $1, $2}'           # Error timestamps
ps aux | grep nginx | awk '{print $2}'                # Nginx process IDs
cat file.txt | sed 's/old/new/g' | awk '{print NR, $0}' # Process and number

# Clean and filter
grep -v "^#" config.file | sed '/^$/d' | awk '{print}' # Remove comments/empty
netstat -tuln | grep :80 | awk '{print $4}'           # Extract listening addresses
df -h | grep -v "tmpfs" | awk '$5+0 > 80 {print $6}'  # Filesystems > 80% full
```

---

## 5. Practical Use Cases

### Log File Analysis
```bash
# Daily request count
grep "$(date +%Y-%m-%d)" /var/log/apache2/access.log | wc -l

# Top IP addresses
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10

# 404 errors by URL
grep "404" access.log | awk '{print $7}' | sort | uniq -c | sort -nr

# Error rate by hour
grep ERROR app.log | awk '{print substr($2,1,2)}' | sort | uniq -c
```

### System Administration
```bash
# High CPU processes
ps aux | awk '$3 > 5.0 {print $2, $11, $3}' | sort -k3 -nr

# Disk usage alerts
df -h | awk '$5+0 > 90 {print "WARNING:", $6, "is", $5, "full"}'

# Network connections by state
netstat -an | awk '{print $6}' | sort | uniq -c | sort -nr

# Failed login attempts
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c
```

### Data Processing
```bash
# CSV/TSV processing
awk -F',' '{sum += $3} END {print "Total sales:", sum}' sales.csv
awk -F'\t' 'NR>1 {print $1, $2}' data.tsv  # Skip header in TSV

# Report generation
awk 'BEGIN{print "Name\tScore\tGrade"} {grade=($2>=90)?"A":($2>=80)?"B":"C"; print $1"\t"$2"\t"grade}' scores.txt
```

---

## 6. Best Practices and Tips

### Performance Tips
- Use `grep` to filter data before processing with `awk` or `sed`
- Use `awk` for complex field operations, `sed` for simple substitutions
- Consider using `-F` option in `awk` for different field separators
- Test complex patterns on small datasets first

### Common Pitfalls
- AWK fields start from 1, not 0
- Be careful with special characters in regex patterns
- Use proper quoting to avoid shell interpretation
- Test `sed -i` commands on copies first

### Debugging Tips
- Use `sed -n` for testing without output
- Print intermediate results to verify logic
- Break complex pipelines into steps
- Use simple patterns first, then increase complexity

---

## Sample Commands for Practice

Try these commands with the provided sample data:

```bash
# Basic operations
grep "Manager" employees.tsv
sed 's/IT/Technology/g' employees.tsv
awk -F'\t' '{print $2, $4}' employees.tsv

# Advanced operations
awk -F'\t' 'NR>1 {sum+=$4; count++} END {print "Average salary:", sum/count}' employees.tsv
grep -v "Intern" employees.tsv | awk -F'\t' '$4 > 50000 {print $2, $4}'
sed '1d' employees.tsv | awk -F'\t' '{dept[$3]++} END {for(d in dept) print d, dept[d]}'
```

---

*This guide provides a comprehensive foundation for text processing in Linux. Practice with real data to master these powerful tools!*