#!/bin/bash
# BashBack Uninstallation Script

set -e

SCRIPT_NAME="bashback"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Uninstalling BashBack...${NC}"

removed=false

# Remove system installation
if [ -f "/usr/local/bin/$SCRIPT_NAME" ]; then
    echo -e "${YELLOW}Removing system-wide installation...${NC}"
    sudo rm -f "/usr/local/bin/$SCRIPT_NAME"
    sudo rm -rf "/usr/local/lib/bashback"
    echo -e "${GREEN}✓ Removed system-wide installation${NC}"
    removed=true
fi

# Remove user installation  
if [ -f "$HOME/.local/bin/$SCRIPT_NAME" ]; then
    echo -e "${YELLOW}Removing user installation...${NC}"
    rm -f "$HOME/.local/bin/$SCRIPT_NAME"
    rm -rf "$HOME/.local/lib/bashback"
    echo -e "${GREEN}✓ Removed user installation${NC}"
    removed=true
fi

if [ "$removed" = false ]; then
    echo -e "${RED}✗ BashBack installation not found${NC}"
    exit 1
fi

echo -e "\n${GREEN}BashBack successfully uninstalled!${NC}"
