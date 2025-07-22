# VIM Editor Tutorial

## Introduction

VIM (Vi IMproved) is a powerful text editor used in Unix/Linux environments. It is an enhanced version of the classic `vi` editor, offering improved features for editing code and text files efficiently.

## Starting VIM

- Open a file:  
    ```
    vim filename
    ```
- Open VIM without a file:  
    ```
    vim
    ```

    > Using `vi` instead of `vim` would still launch `vim` editor on all linux machines!

## Modes in VIM

- **Normal mode**: For navigation and commands (default mode / command mode).
- **Insert mode**: For editing text.

## Basic Commands

### Switching Modes

- Enter **Insert mode**:  
    `i` (insert before cursor)  
    `a` (append after cursor)  
    `o` (open new line below)
- Return to **Normal mode**:  
    `Esc`

### Navigation

- Move left: `h`
- Move down: `j`
- Move up: `k`
- Move right: `l`
- Move to beginning of line: `0`
- Move to end of line: `$`

### Editing

- Delete character: `x`
- Delete line: `dd`
- Undo: `u`
- Redo: `Ctrl + r`
- Copy (yank) line: `yy`
- Paste: `p`

### Saving and Exiting

- Save changes: `:w`
- Save and exit: `:wq`
- Exit without saving: `:q!`

## Help

- Access help: `:help`

