# File Operations in Detail

## 1. Creating Directories and Subdirectories

To organize files, you often need to create directories (folders) and subdirectories.

- **Command Line (Linux):**
    ```sh
    mkdir project
    mkdir project/src
    ```

## 2. Creating Files

You can create files using command line tools or programmatically.

- **Command Line:**
    - Linux/macOS: `touch project/src/file.txt`

## 3. Copying Files Between Directories

Copying files helps duplicate content or backup data.

- **Command Line (Linux):**
    ```sh
    cp project-1/file.txt project-2/src/file.txt
    ```

## 4. Moving Files Using Relative Paths

Moving files transfers them from one location to another, possibly between sibling directories.

- **Directory Structure Example:**
    ```
    parentDir/
        ├── dirA/
        │     └── file.txt
        └── dirB/
    ```
- **Command Line (Linux/macOS):**
    ```sh
    mv parentDir/dirA/file.txt parentDir/dirB/
    ```

**Relative Path:**  
When moving from `dirA` to sibling `dirB`, use `../dirB/` as the relative path from inside `dirA`.

- **Example:**
    ```sh
    mv file.txt ../dirB/
    ```
