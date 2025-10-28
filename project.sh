#!/bin/bash

#############################################
# Directory Synchronizer
# A lightweight tool to keep directories synchronized
#############################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=false
DELETE=false
VERBOSE=false
LOG_FILE=""
EXCLUDE_PATTERNS=()

# Display usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS] SOURCE DESTINATION

Directory Synchronizer - Keep your directories perfectly synchronized

OPTIONS:
    -d, --dry-run          Show what would be copied without making changes
    -D, --delete           Delete files in destination that don't exist in source
    -v, --verbose          Show detailed output
    -l, --log FILE         Write operations to log file
    -e, --exclude PATTERN  Exclude files/directories matching pattern (can be used multiple times)
    -h, --help             Show this help message

EXAMPLES:
    $0 /source/dir /backup/dir
    $0 -d -v /source/dir /backup/dir
    $0 --delete --exclude "*.tmp" --exclude ".git" /source /dest
    $0 -l sync.log /source /dest

EOF
    exit 1
}

# Log message to console and optionally to file
log_message() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Check if directory exists
check_directory() {
    local dir=$1
    local dir_type=$2
    
    if [ ! -d "$dir" ]; then
        log_message ERROR "$dir_type directory does not exist: $dir"
        exit 1
    fi
    
    if [ ! -r "$dir" ]; then
        log_message ERROR "Cannot read $dir_type directory: $dir"
        exit 1
    fi
}

# Check if file should be excluded
should_exclude() {
    local file=$1
    
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "$file" == *"$pattern"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Synchronize directories
sync_directories() {
    local source=$1
    local dest=$2
    local files_copied=0
    local files_updated=0
    local files_deleted=0
    local files_skipped=0
    
    log_message INFO "Starting synchronization..."
    log_message INFO "Source: $source"
    log_message INFO "Destination: $dest"
    
    if [ "$DRY_RUN" = true ]; then
        log_message WARNING "DRY RUN MODE - No actual changes will be made"
    fi
    
    # Create destination directory if it doesn't exist
    if [ ! -d "$dest" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$dest"
            log_message SUCCESS "Created destination directory: $dest"
        else
            log_message INFO "[DRY RUN] Would create destination directory: $dest"
        fi
    fi
    
    # Sync files from source to destination
    while IFS= read -r -d '' source_file; do
        local rel_path="${source_file#$source/}"
        local dest_file="$dest/$rel_path"
        
        # Check if file should be excluded
        if should_exclude "$rel_path"; then
            [ "$VERBOSE" = true ] && log_message INFO "Excluding: $rel_path"
            ((files_skipped++))
            continue
        fi
        
        if [ -d "$source_file" ]; then
            # Create directory in destination
            if [ ! -d "$dest_file" ]; then
                if [ "$DRY_RUN" = false ]; then
                    mkdir -p "$dest_file"
                    [ "$VERBOSE" = true ] && log_message INFO "Created directory: $rel_path"
                else
                    [ "$VERBOSE" = true ] && log_message INFO "[DRY RUN] Would create directory: $rel_path"
                fi
            fi
        else
            # Handle file
            if [ ! -f "$dest_file" ]; then
                # New file - copy it
                if [ "$DRY_RUN" = false ]; then
                    cp -p "$source_file" "$dest_file"
                    log_message SUCCESS "Copied: $rel_path"
                else
                    log_message INFO "[DRY RUN] Would copy: $rel_path"
                fi
                ((files_copied++))
            elif [ "$source_file" -nt "$dest_file" ]; then
                # Source is newer - update it
                if [ "$DRY_RUN" = false ]; then
                    cp -p "$source_file" "$dest_file"
                    log_message SUCCESS "Updated: $rel_path"
                else
                    log_message INFO "[DRY RUN] Would update: $rel_path"
                fi
                ((files_updated++))
            else
                [ "$VERBOSE" = true ] && log_message INFO "Skipped (up to date): $rel_path"
                ((files_skipped++))
            fi
        fi
    done < <(find "$source" -print0)
    
    # Delete files in destination that don't exist in source
    if [ "$DELETE" = true ]; then
        while IFS= read -r -d '' dest_file; do
            local rel_path="${dest_file#$dest/}"
            local source_file="$source/$rel_path"
            
            if [ ! -e "$source_file" ] && [ "$dest_file" != "$dest" ]; then
                if [ "$DRY_RUN" = false ]; then
                    rm -rf "$dest_file"
                    log_message WARNING "Deleted: $rel_path"
                else
                    log_message INFO "[DRY RUN] Would delete: $rel_path"
                fi
                ((files_deleted++))
            fi
        done < <(find "$dest" -print0)
    fi
    
    # Summary
    echo ""
    log_message SUCCESS "Synchronization complete!"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Files copied:    ${GREEN}$files_copied${NC}"
    echo -e "  Files updated:   ${YELLOW}$files_updated${NC}"
    [ "$DELETE" = true ] && echo -e "  Files deleted:   ${RED}$files_deleted${NC}"
    echo -e "  Files skipped:   ${BLUE}$files_skipped${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -D|--delete)
            DELETE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -e|--exclude)
            EXCLUDE_PATTERNS+=("$2")
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            if [ -z "$SOURCE" ]; then
                SOURCE="$1"
            elif [ -z "$DESTINATION" ]; then
                DESTINATION="$1"
            else
                echo "Too many arguments"
                usage
            fi
            shift
            ;;
    esac
done

# Check if source and destination are provided
if [ -z "$SOURCE" ] || [ -z "$DESTINATION" ]; then
    echo "Error: Source and destination directories are required"
    usage
fi

# Convert to absolute paths
SOURCE=$(cd "$SOURCE" && pwd)
DESTINATION=$(cd "$DESTINATION" 2>/dev/null && pwd || echo "$DESTINATION")

# Validate directories
check_directory "$SOURCE" "Source"

# Check if destination is writable
if [ -d "$DESTINATION" ] && [ ! -w "$DESTINATION" ]; then
    log_message ERROR "Cannot write to destination directory: $DESTINATION"
    exit 1
fi

# Prevent syncing a directory to itself
if [ "$SOURCE" = "$DESTINATION" ]; then
    log_message ERROR "Source and destination cannot be the same directory"
    exit 1
fi

# Start synchronization
sync_directories "$SOURCE" "$DESTINATION"
