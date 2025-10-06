# 📁 Directory Synchronizer

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-success.svg)
![Platform](https://img.shields.io/badge/platform-linux-orange.svg)

**A lightweight shell script to keep your directories perfectly synchronized**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Examples](#-examples) • [Contributing](#-contributing)

</div>

---

## 🌟 Features

- **🔄 Bidirectional Sync** - Keep two directories perfectly in sync
- **⚡ Lightning Fast** - Native Linux shell performance
- **📊 Detailed Logging** - Track every change with comprehensive logs
- **🛡️ Safe Operations** - Built-in safeguards to prevent data loss
- **🚀 Zero Dependencies** - Pure bash, works out of the box
- **📝 Dry Run Mode** - Preview changes before applying them
- **🎯 Selective Sync** - Filter files by extension or pattern
- **💾 Lightweight** - Minimal resource usage

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/directory-synchronizer.git

# Navigate to the project directory
cd directory-synchronizer

# Make the script executable
chmod +x sync.sh

# Optional: Add to PATH
sudo cp sync.sh /usr/local/bin/dirsync
```

### Basic Usage

```bash
# Synchronize two directories
./sync.sh /path/to/dirA /path/to/dirB

# Dry run to preview changes
./sync.sh /path/to/dirA /path/to/dirB --dry-run

# Sync with detailed output
./sync.sh /path/to/dirA /path/to/dirB --verbose
```

---

## 💡 How It Works

```
┌─────────────────┐                          ┌─────────────────┐
│    Directory A  │                          │    Directory B  │
│                 │                          │                 │
│  📄 file1.txt   │  ───────────────────→    │  📄 file1.txt   │
│  📄 file2.txt   │                          │  📄 file3.txt   │
│  📄 new.txt     │                          │                 │
│                 │  ←───────────────────    │                 │
└─────────────────┘                          └─────────────────┘
       ↓                                              ↓
       └──────────────── SYNCHRONIZED ────────────────┘
```

### Process Flow

1. **🔍 Scan**: Analyzes both directories and their contents
2. **🔎 Compare**: Identifies differences using timestamps and checksums
3. **📋 Plan**: Creates list of files to copy/update
4. **✅ Execute**: Performs synchronization operations
5. **✔️ Verify**: Confirms all operations completed successfully

---

## 📖 Detailed Usage

### Command Line Syntax

```bash
./sync.sh <source_dir> <target_dir> [options]
```

### Available Options

| Option | Short | Description |
|--------|-------|-------------|
| `--dry-run` | `-d` | Preview changes without modifying files |
| `--verbose` | `-v` | Show detailed operation logs |
| `--exclude PATTERN` | `-e` | Exclude files matching pattern |
| `--include PATTERN` | `-i` | Only sync files matching pattern |
| `--bidirectional` | `-b` | Sync in both directions |
| `--backup` | `-B` | Create backup before syncing |
| `--checksum` | `-c` | Use MD5 checksums for comparison |
| `--delete` | `-D` | Delete files in target not in source |
| `--quiet` | `-q` | Suppress all output except errors |
| `--help` | `-h` | Display help message |

---

## 🎯 Examples

### Example 1: Basic One-Way Sync

```bash
./sync.sh ~/Documents/ProjectA ~/Backup/ProjectA
```

**Before:**
```
Documents/ProjectA/          Backup/ProjectA/
├── file1.txt (modified)     ├── file1.txt (old)
├── file2.txt                └── file3.txt
└── new_file.txt
```

**Output:**
```
[INFO] Starting synchronization...
[COPY] file2.txt → ~/Backup/ProjectA/
[UPDATE] file1.txt → ~/Backup/ProjectA/
[COPY] new_file.txt → ~/Backup/ProjectA/
[SUCCESS] 3 files synchronized
```

**After:**
```
Documents/ProjectA/          Backup/ProjectA/
├── file1.txt               ├── file1.txt ✓
├── file2.txt               ├── file2.txt ✓
└── new_file.txt            ├── file3.txt
                            └── new_file.txt ✓
```

### Example 2: Bidirectional Sync

```bash
./sync.sh ~/DirA ~/DirB --bidirectional
```

Both directories will have identical contents after synchronization.

### Example 3: Dry Run with Verbose Output

```bash
./sync.sh ~/source ~/target --dry-run --verbose
```

**Output:**
```
[DRY-RUN] Scanning directories...
[WOULD COPY] document.pdf (2.4 MB)
[WOULD UPDATE] report.txt (newer in source)
[WOULD SKIP] temp.log (excluded by pattern)
[DRY-RUN] Summary: 2 files would be copied, 1 updated, 1 skipped
```

### Example 4: Filtered Sync (Images Only)

```bash
./sync.sh ~/Photos ~/PhotoBackup --include "*.jpg,*.png,*.gif"
```

Only image files will be synchronized.

### Example 5: Sync with Checksums

```bash
./sync.sh ~/Important ~/Backup --checksum --backup
```

Uses MD5 checksums for accurate comparison and creates backups before overwriting.

---

## 🔧 Configuration

### Using a Config File

Create `.syncrc` in your home directory or project root:

```bash
# Default synchronization mode
SYNC_MODE="bidirectional"

# Automatically create backups
AUTO_BACKUP=true

# Log level (ERROR, WARN, INFO, DEBUG)
LOG_LEVEL="INFO"

# Excluded patterns (comma-separated)
EXCLUDE_PATTERNS="*.tmp,*.cache,.DS_Store,*.swp,*~"

# Maximum file size to sync (in MB)
MAX_FILE_SIZE=100

# Use checksums for comparison
USE_CHECKSUM=false
```

### Environment Variables

```bash
export SYNC_BACKUP_DIR="$HOME/.sync_backups"
export SYNC_LOG_FILE="/var/log/sync.log"
export SYNC_VERBOSE=1
```

---

## 📊 Advanced Features

### Smart File Comparison

The script uses multiple criteria to determine which files need updating:

```bash
# Compare by modification time
if [ file1 -nt file2 ]; then
    # file1 is newer
fi

# Compare by file size
size1=$(stat -c%s file1)
size2=$(stat -c%s file2)

# Compare by MD5 checksum (optional)
md5sum file1 file2 | awk '{print $1}'
```

### Conflict Resolution Strategies

When both files have been modified since last sync:

1. **Prompt Mode**: Ask user which version to keep
2. **Newer Wins**: Keep the file with the latest timestamp
3. **Backup Both**: Save both versions with timestamps
4. **Skip**: Leave both files unchanged

### Logging System

```bash
# Logs are written to:
~/.sync_logs/sync_YYYYMMDD_HHMMSS.log

# View recent logs
tail -f ~/.sync_logs/sync_*.log

# Search logs
grep "ERROR" ~/.sync_logs/*.log
```

---

## 🛠️ Script Structure

```
directory-synchronizer/
├── sync.sh              # Main synchronization script
├── lib/
│   ├── compare.sh      # File comparison functions
│   ├── copy.sh         # File copy operations
│   ├── logging.sh      # Logging utilities
│   └── utils.sh        # Helper functions
├── config/
│   └── .syncrc         # Default configuration
├── tests/
│   ├── test_basic.sh   # Basic functionality tests
│   └── test_edge.sh    # Edge case tests
├── README.md           # This file
└── LICENSE             # MIT License
```

---

## 🧪 Testing

### Run All Tests

```bash
# Make test scripts executable
chmod +x tests/*.sh

# Run test suite
./tests/run_all_tests.sh
```

### Manual Testing

```bash
# Create test directories
mkdir -p /tmp/test_{source,target}

# Add test files
echo "test content" > /tmp/test_source/file1.txt

# Run sync
./sync.sh /tmp/test_source /tmp/test_target --verbose

# Verify results
diff -r /tmp/test_source /tmp/test_target
```

---

## 📋 Requirements

- **OS**: Linux (tested on Ubuntu, Debian, CentOS, Arch)
- **Shell**: Bash 4.0 or higher
- **Tools**: Standard GNU coreutils (`cp`, `find`, `stat`, `md5sum`)

Check your bash version:
```bash
bash --version
```

---

## 🐛 Troubleshooting

### Permission Denied

```bash
# If you get permission errors
chmod +x sync.sh

# For system-wide installation
sudo ./sync.sh /source /target
```

### Script Not Found

```bash
# Add to PATH temporarily
export PATH=$PATH:$(pwd)

# Or use full path
/full/path/to/sync.sh /source /target
```

### Large Directory Performance

```bash
# For very large directories, use parallel processing
./sync.sh /source /target --parallel 4
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
# Fork and clone
git clone https://github.com/yourusername/directory-synchronizer.git
cd directory-synchronizer

# Create feature branch
git checkout -b feature/awesome-feature

# Make changes and test
./tests/run_all_tests.sh

# Commit and push
git commit -m "Add awesome feature"
git push origin feature/awesome-feature
```

### Code Style

- Use 2 spaces for indentation
- Follow [shellcheck](https://www.shellcheck.net/) recommendations
- Add comments for complex logic
- Keep functions under 50 lines

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by `rsync` and `unison`
- Built with native Linux utilities
- Thanks to the open-source community!

---

## 📚 Additional Resources

- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [rsync Documentation](https://rsync.samba.org/)
- [Linux File System Hierarchy](https://www.pathname.com/fhs/)

---

## 📬 Support

Having issues or questions?

- 🐛 [Report a Bug](https://github.com/Pushkarmehra/directory-synchronizer/issues)
- 💡 [Request a Feature](https://github.com/Pushkarmehra/directory-synchronizer/issues)
- 📧 Email: pushkaroops@gmail.com
- 💬 Discussions: [GitHub Discussions](https://github.com/Pushkarmehra/directory-synchronizer/discussions)

---

<div align="center">

**⚡ Built with Bash | Made with ❤️ for Linux**

⭐ Star this repository if you find it helpful!

[![GitHub stars](https://img.shields.io/github/stars/Pushkarmehra/directory-synchronizer.svg?style=social)](https://github.com/Pushkarmehra/directory-synchronizer/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Pushkarmehra/directory-synchronizer.svg?style=social)](https://github.com/Pushkarmehra/directory-synchronizer/network/members)

</div>
