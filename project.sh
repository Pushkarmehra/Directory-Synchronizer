#!/bin/sh
S=""
D=""

menu() {
    echo "\n=== File Sync ==="
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
    [ -z "$S" ] || [ -z "$D" ] && echo "Error: Set both paths!" && return 1
    [ ! -d "$S" ] && echo "Error: Source not found!" && return 1
    return 0
}

set_source() {
    echo "Source path:"
    read S
    echo "Set: $S"
}

set_dest() {
    echo "Dest path:"
    read D
    echo "Set: $D"
}

view_paths() {
    echo "\nSource: ${S:-[NOT SET]}"
    echo "Dest: ${D:-[NOT SET]}"
}

copy_files() {
    check || return
    echo "Copy? (y/n):"
    read x
    [ "$x" = "y" ] && mkdir -p "$D" && cp -rp "$S"/* "$D"/ && echo "Done!"
}

clean_sync() {
    check || return
    echo "DELETE dest first? (y/n):"
    read x
    [ "$x" = "y" ] && rm -rf "$D"/* && mkdir -p "$D" && cp -rp "$S"/* "$D"/ && echo "Done!"
}

mirror_sync() {
    check || return
    echo "Mirror (delete extras)? (y/n):"
    read x
    if [ "$x" = "y" ]; then
        mkdir -p "$D"
        if command -v rsync >/dev/null 2>&1; then
            rsync -a --delete "$S"/ "$D"/
        else
            cp -rp "$S"/* "$D"/
            cd "$D"
            for f in *; do
                [ ! -e "$S/$f" ] && rm -rf "$f"
            done
        fi
        echo "Done!"
    fi
}

while true; do
    menu
    read c
    
    case $c in
        1) set_source ;;
        2) set_dest ;;
        3) view_paths ;;
        4) copy_files ;;
        5) clean_sync ;;
        6) mirror_sync ;;
        7) echo "Bye!"; exit 0 ;;
        *) echo "Invalid!" ;;
    esac
    
    echo "\nPress Enter..."
    read
done
