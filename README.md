# 📁 File Sync Tool

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-sh-success.svg)
![Platform](https://img.shields.io/badge/platform-linux%20%7C%20unix-orange.svg)

**A lightweight, interactive shell script for simple directory synchronization**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Examples](#-examples) • [Safety](#-safety)

</div>

---

## 🌟 Features

- **🎯 Interactive Menu** - Easy-to-use text-based interface
- **⚡ Lightweight** - Pure POSIX shell, works everywhere
- **🔄 Multiple Sync Modes** - Copy, clean sync, or mirror operations
- **🛡️ Confirmation Prompts** - Safety confirmations before destructive operations
- **📂 Flexible Path Management** - Set and view source/destination paths
- **🚀 Zero Dependencies** - Works with basic Unix tools
- **💾 Minimal Footprint** - Ultra-lightweight script

---

## 🚀 Quick Start

### Installation

```bash
# Download or create the script
wget https://example.com/filesync.sh
# OR
curl -O https://example.com/filesync.sh

# Make it executable
chmod +x filesync.sh

# Optional: Move to PATH for system-wide access
sudo mv filesync.sh /usr/local/bin/filesync
```

### Basic Usage

```bash
# Run the script
./filesync.sh

# Or if installed to PATH
filesync
```

---

## 💡 How It Works

```
┌─────────────────────────────────────────────┐
│          FILE SYNC MENU                     │
│                                             │
│  1. Set source      → Define source dir     │
│  2. Set destination → Define target dir     │
│  3. View paths      → Check current paths   │
│  4. Copy files      → Basic copy operation  │
│  5. Clean sync      → Clear then copy       │
│  6. Mirror sync     → Complete mirror       │
│  7. Exit            → Quit program          │
└─────────────────────────────────────────────┘
```

### Sync Modes Explained

| Mode | Description | Use Case |
|------|-------------|----------|
| **Copy Files** | Copies files from source to destination, preserves existing files | Incremental backup |
| **Clean Sync** | Deletes destination contents, then copies source files | Fresh sync |
| **Mirror Sync** | Removes entire destination directory and recreates it | Exact replica |

---

## 📖 Detailed Usage

### Starting the Program

```bash
./filesync.sh
```

You'll see the interactive menu:

```
=== File Sync ===
1. Set source
2. Set destination
3. View paths
4. Copy files
5. Clean sync
6. Mirror sync
7. Exit
Choice [1-7]:
```

### Step-by-Step Workflow

#### Step 1: Set Source Directory

```
Choice [1-7]: 1
Source path: /home/user/Documents
Set: /home/user/Documents
```

#### Step 2: Set Destination Directory

```
Choice [1-7]: 2
Dest path: /home/user/Backup
Set: /home/user/Backup
```

#### Step 3: View Configured Paths

```
Choice [1-7]: 3

Source: /home/user/Documents
Dest: /home/user/Backup
```

#### Step 4: Choose Sync Operation

Select option 4, 5, or 6 based on your needs.

---

## 🎯 Menu Options Explained

### 1. Set Source

Sets the source directory from which files will be copied.

```bash
Source path: /path/to/source
Set: /path/to/source
```

**Note**: The source directory must exist before syncing.

### 2. Set Destination

Sets the destination directory where files will be copied to.

```bash
Dest path: /path/to/destination
Set: /path/to/destination
```

**Note**: Destination will be created automatically if it doesn't exist.

### 3. View Paths

Displays currently configured paths.

```
Source: /home/user/Projects
Dest: /backup/Projects
```

If paths aren't set:
```
Source: [NOT SET]
Dest: [NOT SET]
```

### 4. Copy Files

Copies all files from source to destination, preserving existing destination files.

```bash
Copy? (y/n): y
Done!
```

**What happens:**
- Destination directory is created if needed
- Files are copied recursively
- Permissions and timestamps are preserved (`cp -rp`)
- Existing files in destination remain unless overwritten

### 5. Clean Sync

Deletes all contents from destination, then performs a fresh copy.

```bash
DELETE dest first? (y/n): y
Done!
```

**What happens:**
- All files/folders inside destination are removed (`rm -rf "$D"/*`)
- Destination directory structure is recreated
- Fresh copy of all source files

**⚠️ Warning**: This removes all existing files from destination directory.

### 6. Mirror Sync

Creates an exact mirror by removing the entire destination directory and recreating it.

```bash
Mirror (delete destination and copy again)? (y/n): y
Done!
```

**What happens:**
- Entire destination directory is removed (`rm -rf "$D"`)
- Destination directory is recreated
- Complete copy of source is made

**⚠️ Warning**: This completely removes the destination directory.

### 7. Exit

Exits the program gracefully.

```bash
Bye!
```

---

## 🎨 Examples

### Example 1: Basic Backup

**Scenario**: Backup your documents folder

```bash
$ ./filesync.sh

=== File Sync ===
Choice [1-7]: 1
Source path: /home/user/Documents
Set: /home/user/Documents

Choice [1-7]: 2
Dest path: /home/user/Backup/Documents
Set: /home/user/Backup/Documents

Choice [1-7]: 4
Copy? (y/n): y
Done!
```

**Result**: Documents copied to backup location, existing backups preserved.

### Example 2: Fresh Project Sync

**Scenario**: Create a clean copy of a project

```bash
Choice [1-7]: 1
Source path: /home/dev/project-alpha
Set: /home/dev/project-alpha

Choice [1-7]: 2
Dest path: /mnt/backup/project-alpha
Set: /mnt/backup/project-alpha

Choice [1-7]: 5
DELETE dest first? (y/n): y
Done!
```

**Result**: Old backup deleted, fresh copy created.

### Example 3: USB Drive Mirror

**Scenario**: Create exact mirror on USB drive

```bash
Choice [1-7]: 1
Source path: /home/user/Photos
Set: /home/user/Photos

Choice [1-7]: 2
Dest path: /media/usb/Photos
Set: /media/usb/Photos

Choice [1-7]: 6
Mirror (delete destination and copy again)? (y/n): y
Done!
```

**Result**: USB drive contains exact mirror of Photos folder.

---

## 🛡️ Safety Features

### Built-in Validations

1. **Path Validation**: Script checks if paths are set before operations
2. **Source Existence Check**: Verifies source directory exists
3. **Confirmation Prompts**: Asks for confirmation before destructive operations
4. **Clear Error Messages**: Provides helpful feedback

### Error Handling

```bash
# If paths not set
Error: Set both paths!

# If source doesn't exist
Error: Source not found!

# If user cancels
Copy cancelled.
Clean sync cancelled.
Mirror cancelled.
```

### Safety Tips

✅ **DO:**
- Always verify paths with option 3 before syncing
- Test with non-critical data first
- Keep important backups elsewhere
- Type 'n' if unsure during confirmations

❌ **DON'T:**
- Set same directory as source and destination
- Sync system directories without understanding consequences
- Skip reading confirmation prompts
- Use on critical data without testing first

---

## 🔧 Technical Details

### Command Line Operations

The script uses these standard Unix commands:

```bash
# Copy with preservation
cp -rp "$SOURCE"/* "$DEST"/
# -r: recursive
# -p: preserve permissions, ownership, timestamps

# Remove files
rm -rf "$DIRECTORY"
# -r: recursive
# -f: force (no prompts)

# Create directory
mkdir -p "$DIRECTORY"
# -p: create parents if needed, no error if exists
```

### Script Flow

```
START
  ↓
Display Menu
  ↓
Read User Choice
  ↓
┌─────────────────────────────────┐
│ 1-2: Set Paths                  │
│ 3: Display Current Paths        │
│ 4-6: Validate → Confirm → Sync │
│ 7: Exit                         │
└─────────────────────────────────┘
  ↓
Return to Menu
  ↓
(Loop Until Exit)
```

---

## 📋 Requirements

### System Requirements

- **OS**: Linux, Unix, macOS, or any POSIX-compliant system
- **Shell**: Any POSIX shell (`sh`, `bash`, `dash`, `ash`, etc.)
- **Tools**: Standard Unix utilities (`cp`, `rm`, `mkdir`, `printf`)

### Checking Compatibility

```bash
# Check shell
echo $SHELL

# Check if script runs
sh -n filesync.sh

# Test in current directory
./filesync.sh
```

---

## 🐛 Troubleshooting

### Common Issues

#### Permission Denied

**Problem**: Cannot execute script
```bash
bash: ./filesync.sh: Permission denied
```

**Solution**:
```bash
chmod +x filesync.sh
```

#### Source Not Found

**Problem**: "Error: Source not found!"

**Solution**:
- Check source path spelling
- Ensure source directory exists
- Use absolute paths for clarity

#### Insufficient Permissions

**Problem**: Cannot write to destination

**Solution**:
```bash
# Run with sudo if needed (be careful!)
sudo ./filesync.sh

# Or change destination to user-writable location
```

#### Script Freezes

**Problem**: Script appears stuck

**Solution**:
- Press Ctrl+C to cancel
- Check if large file transfer in progress
- Verify disk space with `df -h`

---

## ⚙️ Advanced Usage

### Running from Anywhere

Add script location to PATH:

```bash
# Add to ~/.bashrc or ~/.profile
export PATH="$PATH:/path/to/script/directory"

# Or create alias
alias filesync='/path/to/filesync.sh'
```

### Automating Sync (Scripted Usage)

For automated backups, modify script or use expect/here-docs:

```bash
#!/bin/bash
# Automated sync example
{
    echo "1"              # Set source
    echo "/home/user/data"
    echo "2"              # Set destination
    echo "/backup/data"
    echo "4"              # Copy files
    echo "y"              # Confirm
    echo "7"              # Exit
} | ./filesync.sh
```

---

## 📊 Comparison with Other Tools

| Feature | File Sync | rsync | cp command |
|---------|-----------|-------|------------|
| Interactive | ✅ | ❌ | ❌ |
| User-friendly | ✅ | ❌ | ⚠️ |
| Incremental sync | ❌ | ✅ | ❌ |
| Network sync | ❌ | ✅ | ❌ |
| Progress display | ❌ | ✅ | ❌ |
| Confirmation prompts | ✅ | ❌ | ❌ |
| Learning curve | Low | High | Low |
| Best for | Simple local backups | Complex sync tasks | Quick copies |

---

## 🤝 Contributing

Contributions welcome! Here are some ideas:

### Potential Enhancements

- [ ] Progress indicators for large transfers
- [ ] Exclude patterns (ignore certain files)
- [ ] Incremental sync (only changed files)
- [ ] Backup before destructive operations
- [ ] Logging to file
- [ ] Dry-run mode
- [ ] Timestamp-based sync

### How to Contribute

```bash
# Fork and modify
git clone https://github.com/yourusername/filesync.git
cd filesync

# Make changes
vim filesync.sh

# Test thoroughly
./filesync.sh

# Submit pull request
```

---

## 📝 License

This project is released under the MIT License.

```
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

---

## 🙏 Acknowledgments

- Built with standard POSIX shell commands
- Inspired by rsync and unison tools
- Thanks to the Unix/Linux community

---

## 📚 Additional Resources

- [POSIX Shell Guide](https://pubs.opengroup.org/onlinepubs/9699919799/)
- [Bash Scripting Tutorial](https://www.gnu.org/software/bash/manual/)
- [Unix File Operations](https://www.man7.org/linux/man-pages/)

---

## 📬 Support

Need help or found a bug?

- 🐛 [Report Issues](https://github.com/yourusername/filesync/issues)
- 💡 [Request Features](https://github.com/yourusername/filesync/issues)
- 📧 Email: pushkaroops@gmail.com
- 💬 [Discussions](https://github.com/yourusername/filesync/discussions)

---

<div align="center">

**⚡ Simple, Safe, Effective**

Made with ❤️ for the Unix community

⭐ Star this project if you find it useful!

[![GitHub](https://img.shields.io/badge/GitHub-filesync-blue?style=flat&logo=github)](https://github.com/yourusername/filesync)

</div>
