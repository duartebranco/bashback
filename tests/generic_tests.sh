#!/bin/bash
# Generic test script for BashBack

# Setup test environment
TEST_DIR="$(pwd)/test_env"
SOURCE_DIR="$TEST_DIR/source"
BACKUP_DIR="$TEST_DIR/backup"
EXCLUDE_FILE="$TEST_DIR/exclude.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up test environment...${NC}"
    rm -rf "$TEST_DIR"
}

# Setup function
setup() {
    echo -e "${YELLOW}Setting up test environment...${NC}"
    rm -rf "$TEST_DIR"  # Clean start
    mkdir -p "$SOURCE_DIR"/{docs,images,temp}

    # Create test files
    echo "This is a text file" > "$SOURCE_DIR/test.txt"
    echo "body { color: blue; }" > "$SOURCE_DIR/style.css"
    echo "console.log('hello');" > "$SOURCE_DIR/script.js"
    echo "Document content" > "$SOURCE_DIR/docs/readme.md"
    echo "Image data" > "$SOURCE_DIR/images/photo.jpg"
    echo "Temporary data" > "$SOURCE_DIR/temp/cache.tmp"
    echo "Another temp file" > "$SOURCE_DIR/backup.tmp"

    # Create exclude file
    echo "cache.tmp" > "$EXCLUDE_FILE"
    echo "temp" >> "$EXCLUDE_FILE"
    echo "backup.tmp" >> "$EXCLUDE_FILE"

    echo -e "Created test structure:"
    find "$SOURCE_DIR" -type f | sort
    echo -e "\nExclusion list:"
    cat "$EXCLUDE_FILE"
    echo ""
}

# Verification functions
verify_file_exists() {
    if [ -f "$1" ]; then
        echo -e "  ${GREEN}✓${NC} File exists: $1"
        return 0
    else
        echo -e "  ${RED}✗${NC} File missing: $1"
        return 1
    fi
}

verify_file_not_exists() {
    if [ ! -f "$1" ]; then
        echo -e "  ${GREEN}✓${NC} File correctly excluded: $1"
        return 0
    else
        echo -e "  ${RED}✗${NC} File should not exist: $1"
        return 1
    fi
}

# Test functions
test_basic_backup() {
    echo -e "\n${YELLOW}=== Test 1: Basic Backup ===${NC}"
    rm -rf "$BACKUP_DIR"
    bashback "$SOURCE_DIR" "$BACKUP_DIR"

    echo -e "\n${YELLOW}Verification:${NC}"
    verify_file_exists "$BACKUP_DIR/test.txt"
    verify_file_exists "$BACKUP_DIR/style.css"
    verify_file_exists "$BACKUP_DIR/script.js"
    verify_file_exists "$BACKUP_DIR/docs/readme.md"
    verify_file_exists "$BACKUP_DIR/images/photo.jpg"
    verify_file_exists "$BACKUP_DIR/temp/cache.tmp"
}

test_check_mode() {
    echo -e "\n${YELLOW}=== Test 2: Check Mode ===${NC}"
    echo "This should show no operations since files already exist:"
    bashback -c "$SOURCE_DIR" "$BACKUP_DIR"
}

test_exclude_files() {
    echo -e "\n${YELLOW}=== Test 3: Exclude Files ===${NC}"
    rm -rf "$BACKUP_DIR"
    bashback -b "$EXCLUDE_FILE" "$SOURCE_DIR" "$BACKUP_DIR"

    echo -e "\n${YELLOW}Verification (should exclude cache.tmp, temp/, and backup.tmp):${NC}"
    verify_file_exists "$BACKUP_DIR/test.txt"
    verify_file_exists "$BACKUP_DIR/style.css"
    verify_file_not_exists "$BACKUP_DIR/temp/cache.tmp"
    verify_file_not_exists "$BACKUP_DIR/backup.tmp"
}

test_regex_filter() {
    echo -e "\n${YELLOW}=== Test 4: Regex Filter (CSS files only) ===${NC}"
    rm -rf "$BACKUP_DIR"
    bashback -r ".*\.css$" "$SOURCE_DIR" "$BACKUP_DIR"

    echo -e "\n${YELLOW}Verification (should only backup CSS files):${NC}"
    verify_file_exists "$BACKUP_DIR/style.css"
    verify_file_not_exists "$BACKUP_DIR/test.txt"
    verify_file_not_exists "$BACKUP_DIR/script.js"
}

test_incremental_backup() {
    echo -e "\n${YELLOW}=== Test 5: Incremental Backup ===${NC}"
    rm -rf "$BACKUP_DIR"

    echo "First backup:"
    bashback "$SOURCE_DIR" "$BACKUP_DIR"

    echo -e "\nModifying a file..."
    echo "Modified content" > "$SOURCE_DIR/test.txt"

    echo "Running incremental backup (should detect and update the modified file):"
    bashback "$SOURCE_DIR" "$BACKUP_DIR"

    echo -e "\n${YELLOW}Verification:${NC}"
    if grep -q "Modified content" "$BACKUP_DIR/test.txt"; then
        echo -e "  ${GREEN}✓${NC} File was correctly updated"
    else
        echo -e "  ${RED}✗${NC} File was not updated"
    fi
}

test_cleanup_orphaned_files() {
    echo -e "\n${YELLOW}=== Test 6: Cleanup Orphaned Files ===${NC}"

    # Add an extra file to backup that doesn't exist in source
    echo "This should be deleted" > "$BACKUP_DIR/orphaned_file.txt"
    mkdir -p "$BACKUP_DIR/orphaned_dir"
    echo "orphaned content" > "$BACKUP_DIR/orphaned_dir/file.txt"

    echo "Added orphaned files/directories to backup"
    echo "Running backup (should remove orphaned files):"
    bashback "$SOURCE_DIR" "$BACKUP_DIR"

    echo -e "\n${YELLOW}Verification:${NC}"
    verify_file_not_exists "$BACKUP_DIR/orphaned_file.txt"
    if [ ! -d "$BACKUP_DIR/orphaned_dir" ]; then
        echo -e "  ${GREEN}✓${NC} Orphaned directory correctly removed"
    else
        echo -e "  ${RED}✗${NC} Orphaned directory still exists"
    fi
}

# Run tests
echo -e "${GREEN}BashBack Test Suite${NC}"
echo "=================="

setup
test_basic_backup
test_check_mode
test_exclude_files
test_regex_filter
test_incremental_backup
test_cleanup_orphaned_files

cleanup
echo -e "\n${GREEN}All tests completed!${NC}"
