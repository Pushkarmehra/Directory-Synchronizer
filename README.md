# Directory-Synchronizer

Compare two directories and make them identical by copying missing or newer files. Example: If dirA has file1.txt and dirB doesn't, the script will copy it over.

## Features

- **One-way sync**: Copy missing or newer files from source to target directory
- **Bidirectional sync**: Make both directories identical by syncing in both directions
- **Preserves directory structure**: Subdirectories are automatically created
- **Smart file comparison**: Only copies files that are missing or have newer modification times
- **Verbose mode**: See detailed information about each file operation

## Requirements

- Python 3.x
- Linux/Unix environment (also works on macOS and Windows)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/Pushkarmehra/Directory-Synchronizer.git
cd Directory-Synchronizer
```

2. Make the script executable:
```bash
chmod +x sync_directories.py
```

## Usage

### One-way synchronization
Sync files from source directory to target directory:
```bash
python3 sync_directories.py /path/to/source /path/to/target
```

### Bidirectional synchronization
Make both directories identical:
```bash
python3 sync_directories.py /path/to/dirA /path/to/dirB --bidirectional
```

### Verbose output
See detailed information about each file operation:
```bash
python3 sync_directories.py /path/to/source /path/to/target -v
```

### Combined options
```bash
python3 sync_directories.py /path/to/dirA /path/to/dirB --bidirectional --verbose
```

## Examples

**Example 1**: Copy missing files from dirA to dirB
```bash
# Initial state:
# dirA/: file1.txt, file2.txt
# dirB/: file2.txt

python3 sync_directories.py dirA dirB

# Result:
# dirA/: file1.txt, file2.txt
# dirB/: file1.txt, file2.txt  (file1.txt was copied)
```

**Example 2**: Update newer files
```bash
# If dirA/file1.txt is newer than dirB/file1.txt
python3 sync_directories.py dirA dirB -v

# Output:
# Updated: file1.txt -> file1.txt
```

**Example 3**: Bidirectional sync
```bash
# Initial state:
# dirA/: fileA.txt, shared.txt
# dirB/: fileB.txt, shared.txt

python3 sync_directories.py dirA dirB --bidirectional

# Result:
# dirA/: fileA.txt, fileB.txt, shared.txt
# dirB/: fileA.txt, fileB.txt, shared.txt
```

## How It Works

1. **One-way sync** (source → target):
   - Walks through all files in the source directory
   - For each file:
     - If it doesn't exist in target: copies it
     - If it exists but source is newer: updates it
     - Otherwise: skips it

2. **Bidirectional sync**:
   - Performs one-way sync from A to B
   - Then performs one-way sync from B to A
   - Result: both directories contain all files with the newest versions

## Command-line Options

```
positional arguments:
  source               Source directory (or first directory for bidirectional sync)
  target               Target directory (or second directory for bidirectional sync)

options:
  -h, --help           Show help message and exit
  -b, --bidirectional  Perform bidirectional sync (make both directories identical)
  -v, --verbose        Print detailed information about each file operation
```

## License

This project is open source and available for use and modification.
