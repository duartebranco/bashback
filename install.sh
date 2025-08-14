#!/bin/bash
# BashBack Installation Script

set -e  # Exit on error

SCRIPT_NAME="bashback"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_usage() {
    echo "BashBack Installation Script"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --system      Install system-wide (requires sudo)"
    echo "  --user        Install for current user only"
    echo "  --help        Show this help message"
    echo ""
    echo "If no option is specified, the script will choose the best option based on permissions."
}

install_system() {
    local bin_dir="/usr/local/bin"
    local lib_dir="/usr/local/lib/bashback"

    echo -e "${YELLOW}Installing BashBack system-wide...${NC}"

    # Create lib directory for supporting files
    sudo mkdir -p "$lib_dir"

    # Copy files
    sudo cp backup.sh "$bin_dir/$SCRIPT_NAME"
    sudo cp backup_tree.sh "$lib_dir/"

    # Make executable
    sudo chmod +x "$bin_dir/$SCRIPT_NAME"

    # Update the script to look for backup_tree.sh in the lib directory
    sudo sed -i "s|source \"\$SCRIPT_DIR/backup_tree.sh\"|source \"$lib_dir/backup_tree.sh\"|" "$bin_dir/$SCRIPT_NAME"

    echo -e "${GREEN}✓ BashBack installed system-wide${NC}"
    echo -e "${GREEN}✓ Available as: $SCRIPT_NAME${NC}"
}

install_user() {
    local bin_dir="$HOME/.local/bin"
    local lib_dir="$HOME/.local/lib/bashback"

    echo -e "${YELLOW}Installing BashBack for current user...${NC}"

    # Create directories
    mkdir -p "$bin_dir" "$lib_dir"

    # Copy files
    cp backup.sh "$bin_dir/$SCRIPT_NAME"
    cp backup_tree.sh "$lib_dir/"

    # Make executable
    chmod +x "$bin_dir/$SCRIPT_NAME"

    # Update the script to look for backup_tree.sh in the lib directory
    sed -i "s|source \"\$SCRIPT_DIR/backup_tree.sh\"|source \"$lib_dir/backup_tree.sh\"|" "$bin_dir/$SCRIPT_NAME"

    echo -e "${GREEN}✓ BashBack installed for current user${NC}"
    echo -e "${GREEN}✓ Available as: $SCRIPT_NAME${NC}"

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo -e "${YELLOW}⚠ $HOME/.local/bin is not in your PATH${NC}"
        echo -e "${YELLOW}Add this to your ~/.bashrc or ~/.zshrc:${NC}"
        echo -e "${YELLOW}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
}

# Check if required files exist
if [ ! -f "backup.sh" ] || [ ! -f "backup_tree.sh" ]; then
    echo -e "${RED}Error: backup.sh or backup_tree.sh not found in current directory${NC}"
    echo "Please run this script from the BashBack repository root."
    exit 1
fi

# Parse command line arguments
case "${1:-}" in
    --system)
        if [ "$EUID" -eq 0 ]; then
            echo -e "${RED}Error: Don't run with sudo. The script will ask for sudo when needed.${NC}"
            exit 1
        fi
        install_system
        ;;
    --user)
        install_user
        ;;
    --help|-h)
        print_usage
        ;;
    "")
        # Auto-detect best installation method
        if [ "$EUID" -eq 0 ]; then
            echo -e "${RED}Error: Don't run as root. The script will ask for sudo when needed.${NC}"
            exit 1
        elif groups | grep -q '\bsudo\b\|wheel\b' 2>/dev/null && command -v sudo >/dev/null 2>&1; then
            echo -e "${YELLOW}Auto-detected: Installing system-wide (you have sudo access)${NC}"
            install_system
        else
            echo -e "${YELLOW}Auto-detected: Installing for current user only${NC}"
            install_user
        fi
        ;;
    *)
        echo -e "${RED}Error: Unknown option '$1'${NC}"
        print_usage
        exit 1
        ;;
esac

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${GREEN}Try: $SCRIPT_NAME --help${NC}"
