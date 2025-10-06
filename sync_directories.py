#!/usr/bin/env python3
"""
Directory Synchronizer
Compares two directories and makes them identical by copying missing or newer files.
"""

import os
import shutil
import argparse
from pathlib import Path
from datetime import datetime


def get_file_info(file_path):
    """Get file modification time."""
    return os.path.getmtime(file_path)


def sync_directory(source_dir, target_dir, verbose=False):
    """
    Synchronize files from source_dir to target_dir.
    Copies missing files and updates files that are newer in source.
    
    Args:
        source_dir: Source directory path
        target_dir: Target directory path
        verbose: Print detailed information
    
    Returns:
        dict: Statistics about the sync operation
    """
    stats = {
        'copied': 0,
        'updated': 0,
        'skipped': 0
    }
    
    source_path = Path(source_dir).resolve()
    target_path = Path(target_dir).resolve()
    
    if not source_path.exists():
        raise ValueError(f"Source directory does not exist: {source_dir}")
    
    if not source_path.is_dir():
        raise ValueError(f"Source path is not a directory: {source_dir}")
    
    # Create target directory if it doesn't exist
    target_path.mkdir(parents=True, exist_ok=True)
    
    # Walk through source directory
    for root, dirs, files in os.walk(source_path):
        # Calculate relative path from source
        rel_path = Path(root).relative_to(source_path)
        target_root = target_path / rel_path
        
        # Create subdirectories in target if they don't exist
        target_root.mkdir(parents=True, exist_ok=True)
        
        # Process each file
        for filename in files:
            source_file = Path(root) / filename
            target_file = target_root / filename
            
            # Check if file needs to be copied or updated
            if not target_file.exists():
                # File doesn't exist in target, copy it
                shutil.copy2(source_file, target_file)
                stats['copied'] += 1
                if verbose:
                    print(f"Copied: {source_file.relative_to(source_path)} -> {target_file.relative_to(target_path)}")
            else:
                # File exists, check if source is newer
                source_mtime = get_file_info(source_file)
                target_mtime = get_file_info(target_file)
                
                if source_mtime > target_mtime:
                    # Source file is newer, update target
                    shutil.copy2(source_file, target_file)
                    stats['updated'] += 1
                    if verbose:
                        print(f"Updated: {source_file.relative_to(source_path)} -> {target_file.relative_to(target_path)}")
                else:
                    stats['skipped'] += 1
                    if verbose:
                        print(f"Skipped: {source_file.relative_to(source_path)} (up to date)")
    
    return stats


def bidirectional_sync(dir_a, dir_b, verbose=False):
    """
    Perform bidirectional synchronization between two directories.
    Makes both directories identical by syncing in both directions.
    
    Args:
        dir_a: First directory path
        dir_b: Second directory path
        verbose: Print detailed information
    """
    print(f"Synchronizing directories:")
    print(f"  Directory A: {dir_a}")
    print(f"  Directory B: {dir_b}")
    print()
    
    # Sync A -> B
    print("Phase 1: Syncing A -> B")
    stats_a_to_b = sync_directory(dir_a, dir_b, verbose)
    print(f"  Copied: {stats_a_to_b['copied']} files")
    print(f"  Updated: {stats_a_to_b['updated']} files")
    print(f"  Skipped: {stats_a_to_b['skipped']} files")
    print()
    
    # Sync B -> A
    print("Phase 2: Syncing B -> A")
    stats_b_to_a = sync_directory(dir_b, dir_a, verbose)
    print(f"  Copied: {stats_b_to_a['copied']} files")
    print(f"  Updated: {stats_b_to_a['updated']} files")
    print(f"  Skipped: {stats_b_to_a['skipped']} files")
    print()
    
    total_operations = (stats_a_to_b['copied'] + stats_a_to_b['updated'] + 
                       stats_b_to_a['copied'] + stats_b_to_a['updated'])
    
    print(f"Synchronization complete! Total operations: {total_operations}")


def main():
    parser = argparse.ArgumentParser(
        description='Compare two directories and make them identical by copying missing or newer files.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Sync from dirA to dirB (one-way)
  %(prog)s dirA dirB
  
  # Sync bidirectionally (make both directories identical)
  %(prog)s dirA dirB --bidirectional
  
  # Verbose output
  %(prog)s dirA dirB -v
        """
    )
    
    parser.add_argument('source', help='Source directory (or first directory for bidirectional sync)')
    parser.add_argument('target', help='Target directory (or second directory for bidirectional sync)')
    parser.add_argument('-b', '--bidirectional', action='store_true',
                       help='Perform bidirectional sync (make both directories identical)')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Print detailed information about each file operation')
    
    args = parser.parse_args()
    
    try:
        if args.bidirectional:
            bidirectional_sync(args.source, args.target, args.verbose)
        else:
            print(f"Synchronizing from {args.source} to {args.target}")
            print()
            stats = sync_directory(args.source, args.target, args.verbose)
            print(f"Synchronization complete!")
            print(f"  Copied: {stats['copied']} files")
            print(f"  Updated: {stats['updated']} files")
            print(f"  Skipped: {stats['skipped']} files")
    except Exception as e:
        print(f"Error: {e}")
        return 1
    
    return 0


if __name__ == '__main__':
    exit(main())
