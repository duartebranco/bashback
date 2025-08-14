# bashback - Backup Tool in Bash

A lightweight, incremental backup utility written in pure Bash that synchronizes directories and maintains backup integrity.

In other words, it's rsync in Bash.

## Features

- **Directory Synchronization**: Recursively processes subdirectories
- **Incremental Backup**: Only copies/updates files that have changed
- **Flexible Filtering**: Support for exclusion lists and regex pattern matching
- **Dry Run Mode**: Preview operations before executing them
- **Comprehensive Reporting**: Detailed statistics on operations performed
- **Cleanup**: Automatically removes files from backup that no longer exist in source

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bashback.git
cd bashback
```
2. Make the script executable:
```bash
chmod +x install.sh
```
3. Run the installation script:
```bash
./install.sh
```

## Usage
```bash
bashback [-c] [-b exclude_file] [-r regex_pattern] source_directory backup_directory
```
Options:
- `-c`: **Check mode** - Show what operations would be performed without executing them
- `-b exclude_file`: **Exclude file** - Specify a text file containing filenames/patterns to exclude
- `-r regex_pattern`: **Regex filter** - Only backup files matching the specified regex pattern

### Examples
```bash
# Simple backup
bashback ~/Documents ~/Backups/Documents

# Preview what will be backed up (dry run)
bashback -c ~/Documents ~/Backups/Documents

# Use exclude file to skip items
echo -e "*.tmp\n*.log\nnode_modules" > exclude.txt
bashback -b exclude.txt ~/Projects ~/Backups/Projects

# Only backup text files
bashback -r ".*\.txt$" ~/Documents ~/Backups/Documents

# Only backup images
bashback -r ".*\.(jpg|png|gif)$" ~/Pictures ~/Backups/Pictures
```

## Documentation

This project includes comprehensive documentation in the `docs/` directory:

- **`Assignment.pdf`**: Original project requirements and specifications
- **`Report.pdf`**: Detailed technical report covering implementation details, design decisions, and performance analysis

## License

This project is open source and available under the [MIT License](LICENSE).
