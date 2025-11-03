#!/bin/sh
# Advanced Menu-Driven File Sync Script

SOURCE=""
DEST=""
LOG_FILE="sync_log.txt"
FILTER=""
EXCLUDE=""

# Function to display main menu
show_menu() {
    echo ""
    echo "======= File Sync Menu ======="
    echo "1.  Set source folder"
    echo "2.  Set destination folder"
    echo "3.  View current settings"
    echo "4.  Basic copy (preserve existing)"
    echo "5.  Clean sync (delete dest first)"
    echo "6.  Incremental sync (newer only)"
    echo "7.  Mirror sync (exact copy)"
    echo "8.  Show file count & size"
    echo "9.  Preview changes"
    echo "10. Backup destination"
    echo "11. Set file type filter"
    echo "12. Set exclude pattern"
    echo "13. Compare folders"
    echo "14. Compress and copy"
    echo "15. Verify copied files"
    echo "16. Show copy progress"
    echo "17. View sync history"
    echo "18. Clear sync history"
    echo "19. Exit"
    echo "=============================="
    echo "Enter your choice [1-19]:"
}

# Function to log operations
log_operation() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to set source
set_source() {
    echo "Enter source folder path:"
    read SOURCE
    if [ -z "$SOURCE" ]; then
        echo "Error: Source cannot be empty!"
        SOURCE=""
    elif [ ! -d "$SOURCE" ]; then
        echo "Warning: Source folder '$SOURCE' does not exist!"
        echo "Do you want to keep this path anyway? (y/n):"
        read confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            SOURCE=""
        fi
    else
        echo "Source set to: $SOURCE"
        log_operation "Source set to: $SOURCE"
    fi
}

# Function to set destination
set_destination() {
    echo "Enter destination folder path:"
    read DEST
    if [ -z "$DEST" ]; then
        echo "Error: Destination cannot be empty!"
        DEST=""
    else
        echo "Destination set to: $DEST"
        log_operation "Destination set to: $DEST"
    fi
}

# Function to view settings
view_settings() {
    echo ""
    echo "Current Settings:"
    echo "----------------"
    if [ -z "$SOURCE" ]; then
        echo "Source: [NOT SET]"
    else
        echo "Source: $SOURCE"
    fi
    if [ -z "$DEST" ]; then
        echo "Destination: [NOT SET]"
    else
        echo "Destination: $DEST"
    fi
    if [ -n "$FILTER" ]; then
        echo "File filter: $FILTER"
    fi
    if [ -n "$EXCLUDE" ]; then
        echo "Exclude pattern: $EXCLUDE"
    fi
    echo "----------------"
}

# Function to check if paths are set
check_paths() {
    if [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
        echo "Error: Both source and destination must be set!"
        return 1
    fi
    
    if [ ! -d "$SOURCE" ]; then
        echo "Error: Source folder '$SOURCE' not found!"
        return 1
    fi
    return 0
}

# Function for basic copy
basic_copy() {
    check_paths || return
    
    echo ""
    echo "Ready to copy from '$SOURCE' to '$DEST'"
    echo "Continue? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        mkdir -p "$DEST"
        echo "Copying files..."
        if [ -n "$FILTER" ]; then
            find "$SOURCE" -name "$FILTER" -exec cp --parents {} "$DEST" \; 2>/dev/null || cp -rp "$SOURCE"/*"$FILTER" "$DEST"/ 2>/dev/null
        else
            cp -rp "$SOURCE"/* "$DEST"/
        fi
        echo "Done! Files copied successfully."
        log_operation "Basic copy completed: $SOURCE -> $DEST"
    else
        echo "Copy cancelled."
    fi
}

# Function for clean sync
clean_sync() {
    check_paths || return
    
    echo ""
    echo "WARNING: This will DELETE all files in '$DEST' first!"
    echo "Continue? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        if [ -d "$DEST" ]; then
            echo "Deleting destination contents..."
            rm -rf "$DEST"/*
        fi
        mkdir -p "$DEST"
        echo "Copying files..."
        cp -rp "$SOURCE"/* "$DEST"/
        echo "Done! Clean sync completed."
        log_operation "Clean sync completed: $SOURCE -> $DEST"
    else
        echo "Clean sync cancelled."
    fi
}

# Function for incremental sync
incremental_sync() {
    check_paths || return
    
    echo ""
    echo "Syncing newer files from '$SOURCE' to '$DEST'"
    echo "Continue? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        mkdir -p "$DEST"
        echo "Copying newer files..."
        cp -rup "$SOURCE"/* "$DEST"/
        echo "Done! Incremental sync completed."
        log_operation "Incremental sync completed: $SOURCE -> $DEST"
    else
        echo "Incremental sync cancelled."
    fi
}

# Function for mirror sync
mirror_sync() {
    check_paths || return
    
    echo ""
    echo "This will make '$DEST' exactly match '$SOURCE'"
    echo "Files in destination that don't exist in source will be DELETED!"
    echo "Continue? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        mkdir -p "$DEST"
        echo "Mirroring folders..."
        
        # Use rsync if available, otherwise use cp and manual cleanup
        if command -v rsync >/dev/null 2>&1; then
            rsync -a --delete "$SOURCE"/ "$DEST"/
        else
            # Copy all from source
            cp -rp "$SOURCE"/* "$DEST"/
            
            # Remove files from dest that don't exist in source
            for file in "$DEST"/*; do
                filename=$(basename "$file")
                if [ ! -e "$SOURCE/$filename" ]; then
                    rm -rf "$file"
                    echo "Deleted: $filename"
                fi
            done
        fi
        echo "Done! Mirror sync completed."
        log_operation "Mirror sync completed: $SOURCE -> $DEST"
    else
        echo "Mirror sync cancelled."
    fi
}

# Function to show file count and size
show_stats() {
    check_paths || return
    
    echo ""
    echo "Source Statistics:"
    echo "------------------"
    src_count=$(find "$SOURCE" -type f | wc -l)
    src_size=$(du -sh "$SOURCE" 2>/dev/null | cut -f1)
    echo "Files: $src_count"
    echo "Total size: $src_size"
    
    if [ -d "$DEST" ]; then
        echo ""
        echo "Destination Statistics:"
        echo "-----------------------"
        dest_count=$(find "$DEST" -type f | wc -l)
        dest_size=$(du -sh "$DEST" 2>/dev/null | cut -f1)
        echo "Files: $dest_count"
        echo "Total size: $dest_size"
    else
        echo ""
        echo "Destination does not exist yet."
    fi
}

# Function to preview changes
preview_changes() {
    check_paths || return
    
    echo ""
    echo "Preview of changes:"
    echo "-------------------"
    
    if [ ! -d "$DEST" ]; then
        echo "Destination doesn't exist - all files will be copied:"
        find "$SOURCE" -type f
    else
        echo "New files to be copied:"
        for file in $(find "$SOURCE" -type f); do
            rel_path="${file#$SOURCE/}"
            if [ ! -e "$DEST/$rel_path" ]; then
                echo "  + $rel_path"
            fi
        done
        
        echo ""
        echo "Files that will be updated (newer in source):"
        for file in $(find "$SOURCE" -type f); do
            rel_path="${file#$SOURCE/}"
            if [ -e "$DEST/$rel_path" ] && [ "$file" -nt "$DEST/$rel_path" ]; then
                echo "  ~ $rel_path"
            fi
        done
    fi
}

# Function to backup destination
backup_dest() {
    check_paths || return
    
    if [ ! -d "$DEST" ]; then
        echo "Destination doesn't exist yet. Nothing to backup."
        return
    fi
    
    backup_name="${DEST}_backup_$(date +%Y%m%d_%H%M%S)"
    echo ""
    echo "Creating backup: $backup_name"
    echo "Continue? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        cp -rp "$DEST" "$backup_name"
        echo "Done! Backup created at: $backup_name"
        log_operation "Backup created: $backup_name"
    else
        echo "Backup cancelled."
    fi
}

# Function to set file type filter
set_filter() {
    echo "Enter file pattern to filter (e.g., *.txt, *.jpg) or leave empty to clear:"
    read FILTER
    if [ -z "$FILTER" ]; then
        echo "Filter cleared."
    else
        echo "Filter set to: $FILTER"
    fi
    log_operation "Filter set to: $FILTER"
}

# Function to set exclude pattern
set_exclude() {
    echo "Enter pattern to exclude (e.g., *.tmp, test*) or leave empty to clear:"
    read EXCLUDE
    if [ -z "$EXCLUDE" ]; then
        echo "Exclude pattern cleared."
    else
        echo "Exclude pattern set to: $EXCLUDE"
    fi
    log_operation "Exclude pattern set to: $EXCLUDE"
}

# Function to compare folders
compare_folders() {
    check_paths || return
    
    if [ ! -d "$DEST" ]; then
        echo "Destination doesn't exist yet. Cannot compare."
        return
    fi
    
    echo ""
    echo "Comparing folders..."
    echo "--------------------"
    
    echo ""
    echo "Files only in SOURCE:"
    for file in $(find "$SOURCE" -type f); do
        rel_path="${file#$SOURCE/}"
        if [ ! -e "$DEST/$rel_path" ]; then
            echo "  $rel_path"
        fi
    done
    
    echo ""
    echo "Files only in DESTINATION:"
    for file in $(find "$DEST" -type f); do
        rel_path="${file#$DEST/}"
        if [ ! -e "$SOURCE/$rel_path" ]; then
            echo "  $rel_path"
        fi
    done
    
    echo ""
    echo "Files that differ (newer in source):"
    for file in $(find "$SOURCE" -type f); do
        rel_path="${file#$SOURCE/}"
        if [ -e "$DEST/$rel_path" ] && [ "$file" -nt "$DEST/$rel_path" ]; then
            echo "  $rel_path"
        fi
    done
}

# Function to compress and copy
compress_copy() {
    check_paths || return
    
    archive_name="${DEST}_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo ""
    echo "Creating compressed archive: $archive_name"
    echo "Continue? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo "Compressing..."
        tar -czf "$archive_name" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
        echo "Done! Archive created: $archive_name"
        log_operation "Compressed archive created: $archive_name"
    else
        echo "Compression cancelled."
    fi
}

# Function to verify copied files
verify_files() {
    check_paths || return
    
    if [ ! -d "$DEST" ]; then
        echo "Destination doesn't exist yet. Nothing to verify."
        return
    fi
    
    echo ""
    echo "Verifying files..."
    echo "------------------"
    
    mismatches=0
    for file in $(find "$SOURCE" -type f); do
        rel_path="${file#$SOURCE/}"
        if [ -e "$DEST/$rel_path" ]; then
            if command -v md5sum >/dev/null 2>&1; then
                src_hash=$(md5sum "$file" | cut -d' ' -f1)
                dest_hash=$(md5sum "$DEST/$rel_path" | cut -d' ' -f1)
                if [ "$src_hash" != "$dest_hash" ]; then
                    echo "  MISMATCH: $rel_path"
                    mismatches=$((mismatches + 1))
                fi
            else
                # Fallback to size comparison
                src_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
                dest_size=$(stat -f%z "$DEST/$rel_path" 2>/dev/null || stat -c%s "$DEST/$rel_path")
                if [ "$src_size" != "$dest_size" ]; then
                    echo "  SIZE MISMATCH: $rel_path"
                    mismatches=$((mismatches + 1))
                fi
            fi
        else
            echo "  MISSING: $rel_path"
            mismatches=$((mismatches + 1))
        fi
    done
    
    if [ $mismatches -eq 0 ]; then
        echo "All files verified successfully!"
    else
        echo ""
        echo "Found $mismatches mismatches or missing files."
    fi
}

# Function to show progress during copy
progress_copy() {
    check_paths || return
    
    echo ""
    echo "Copying with progress from '$SOURCE' to '$DEST'"
    echo "Continue? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        mkdir -p "$DEST"
        echo "Copying files..."
        
        total=$(find "$SOURCE" -type f | wc -l)
        current=0
        
        find "$SOURCE" -type f | while read file; do
            rel_path="${file#$SOURCE/}"
            dest_file="$DEST/$rel_path"
            mkdir -p "$(dirname "$dest_file")"
            cp -p "$file" "$dest_file"
            current=$((current + 1))
            echo "[$current/$total] Copied: $rel_path"
        done
        
        echo "Done! All files copied with progress."
        log_operation "Progress copy completed: $SOURCE -> $DEST"
    else
        echo "Copy cancelled."
    fi
}

# Function to view sync history
view_history() {
    echo ""
    if [ -f "$LOG_FILE" ]; then
        echo "Sync History:"
        echo "-------------"
        cat "$LOG_FILE"
    else
        echo "No sync history found."
    fi
}

# Function to clear history
clear_history() {
    echo ""
    echo "Are you sure you want to clear sync history? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        > "$LOG_FILE"
        echo "Sync history cleared."
    else
        echo "Clear cancelled."
    fi
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) set_source ;;
        2) set_destination ;;
        3) view_settings ;;
        4) basic_copy ;;
        5) clean_sync ;;
        6) incremental_sync ;;
        7) mirror_sync ;;
        8) show_stats ;;
        9) preview_changes ;;
        10) backup_dest ;;
        11) set_filter ;;
        12) set_exclude ;;
        13) compare_folders ;;
        14) compress_copy ;;
        15) verify_files ;;
        16) progress_copy ;;
        17) view_history ;;
        18) clear_history ;;
        19)
            echo "Exiting... Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice! Please enter 1-19."
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read dummy
done
