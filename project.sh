#!/bin/sh
S=""
D=""

menu() {
    printf '\n=== File Sync ===\n'
    echo "1. Set source"
    echo "2. Set destination"
    echo "3. View paths"
    echo "4. Copy files"
    echo "5. Clean sync"
    echo "6. Mirror sync"
    echo "7. Exit"
    echo "Choice [1-7]:"
}

check() {
    if [ -z "$S" ] || [ -z "$D" ]; then
        echo "Error: Set both paths!"
        return 1
    elif [ ! -d "$S" ]; then
        echo "Error: Source not found!"
        return 1
    else
        return 0
    fi
}

set_source() {
    echo "Source path:"
    read -r S
    echo "Set: $S"
}

set_dest() {
    echo "Dest path:"
    read -r D
    echo "Set: $D"
}

view_paths() {
    printf '\nSource: %s\n' "${S:-[NOT SET]}"
    printf 'Dest: %s\n' "${D:-[NOT SET]}"
}

copy_files() {
    check || return
    echo "Copy? (y/n):"
    read -r x

    if [ "$x" = "y" ]; then
        mkdir -p "$D"
        cp -rp "$S"/* "$D"/
        echo "Done!"
    else
        echo "Copy cancelled."
    fi
}

clean_sync() {
    check || return

    echo "DELETE dest first? (y/n):"
    read -r x

    if [ "$x" = "y" ]; then
        # Delete existing files from destination
        rm -rf "$D"/*

        # Make sure destination directory exists
        mkdir -p "$D"

        # Copy files from source to destination
        cp -rp "$S"/* "$D"/

        echo "Done!"
    else
        echo "Clean sync cancelled."
    fi
}

mirror_sync() {
    check || return

    echo "Mirror (delete destination and copy again)? (y/n):"
    read -r x

    if [ "$x" = "y" ]; then
        rm -rf "$D"        # Delete destination folder completely
        mkdir -p "$D"      # Recreate destination folder
        cp -r "$S"/* "$D"/ # Copy everything from source to destination
        echo "Done!"
    else
        echo "Mirror cancelled."
    fi
}

while true; do
    menu
    read -r c

    case "$c" in
        1) set_source ;;
        2) set_dest ;;
        3) view_paths ;;
        4) copy_files ;;
        5) clean_sync ;;
        6) mirror_sync ;;
        7) echo "Bye!"; exit 0 ;;
        *) echo "Invalid!" ;;
    esac

    printf '\nPress Enter...'
    read -r
done
