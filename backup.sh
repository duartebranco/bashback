#!/bin/bash


# HELP
usage() {
    echo "Usage: bashback [-c] [-b tfile] [-r regexpr] source_directory backup_directory"
    exit 1
}

check_mode=false
exclude_file=""
regex_pattern=""

# Parse options using getopts
while getopts ":cb:r:" opt; do
    case ${opt} in
        c )
            check_mode=true
            ;;
        b )
            exclude_file=$OPTARG
            if [ ! -f "$exclude_file" ] || ! file "$exclude_file" | grep -q "text"; then
                usage
            fi
            ;;
        r )
            regex_pattern=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Checking the remaining arguments
if [ "$#" -ne 2 ]; then
    usage
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"


# Check if source dir exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Create backup dir if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "Backup directory '$BACKUP_DIR' does not exist. Creating it...\n"
    if [ "$check_mode" = false ]; then
        mkdir -p "$BACKUP_DIR"
    fi
fi

# Include hidden files
shopt -s dotglob

# Get the directory where this script is located and source backup_tree.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/backup_tree.sh"

echo "$SOURCE_DIR is a directory"
echo "Backing up '$SOURCE_DIR' to '$BACKUP_DIR'..."
backup_tree "$SOURCE_DIR" "$BACKUP_DIR" "$check_mode" "$exclude_file" "$regex_pattern"
