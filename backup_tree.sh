backup_summary() {
	echo -e "While backing up $SOURCE_DIR: $errors Errors; $warnings Warnings; $updated Updated; $copied Copied ($copied_data B); $deleted Deleted ($deleted_data B)\n"
}

backup_tree() {
    local SOURCE_DIR="${1%/}"
    local BACKUP_DIR="${2%/}"
    local check_mode="$3"
    local exclude_file="$4"
    local regex_pattern="$5"

    local errors=0
    local warnings=0
    local updated=0
    local copied=0
    local copied_data=0
    local deleted=0
    local deleted_data=0


    # Read exclusions into an array if exclude_file is provided
    local exclusions=()
    # Check if exclude_file is not empty and exists as a file
    if [ -n "$exclude_file" ] && [ -f "$exclude_file" ]; then 
        # Read the lines of the file into an array
        mapfile -t exclusions < "$exclude_file"
    fi

    # First, process all files in SOURCE_DIR
    for file in "$SOURCE_DIR"/*; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            source_file="$SOURCE_DIR/$filename"
            backup_file="$BACKUP_DIR/$filename"

            # Skip if the file is in the exclusions list
            if [[ " ${exclusions[@]} " =~ " $filename " ]]; then
                echo "Skipping '$source_file' as it is in the exclude list."
                continue
            fi

            # Skip if the file does not match the regex pattern
            if [[ -n "$regex_pattern" && ! "$filename" =~ $regex_pattern ]]; then
                echo "Skipping '$source_file' as it does not match the regex pattern."
                continue
            fi

            # Check if backup file exists
            if [ -f "$backup_file" ]; then
		        # backup_check
		        # ---
                source_md5=$(md5sum "$source_file" | awk '{ print $1 }')
                backup_md5=$(md5sum "$backup_file" | awk '{ print $1 }')
                if [[ "$source_md5" != "$backup_md5" ]]; then
                    echo "$source_file and $backup_file differ."
                fi
		        # ---

                # Check if backup file is newer
                if [ "$backup_file" -nt "$source_file" ]; then
                    echo "WARNING: backup entry '$backup_file' is newer than '$source_file'; should not happen"
                    warnings=$((warnings + 1))
                fi

                # Update if source file is newer
                if [ "$source_file" -nt "$backup_file" ]; then
                    echo "'$backup_file' already exists, updating it..."
		            # NEW ALT due to Professor tests
		            # echo "cp -a '$file' '$backup_file'"
                    if [ "$check_mode" = false ]; then
                        cp -a "$file" "$backup_file" || { errors=$((errors + 1)); continue; }
                        # also NEW ALT due to Professor tests
			            # copied=$((copied + 1))
                        # copied_data=$((copied_data + $(du -b "$file" | cut -f1)))
                        updated=$((updated + 1))
                    fi
                fi
            else
                # Copy new file to backup
                echo "cp -a '$file' '$backup_file'"
                
                if [ "$check_mode" = false ]; then
                    cp -a "$file" "$backup_file" || { errors=$((errors + 1)); continue; }
                    copied=$((copied + 1))
                    copied_data=$((copied_data + $(du -b "$file" | cut -f1)))
                fi
            fi
        fi
    done



    # Check if there are files/dirs in the backup directory that are not in the source directory
    for file in "$BACKUP_DIR"/*; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            source_file="$SOURCE_DIR/$filename"
            backup_file="$BACKUP_DIR/$filename"

            # Delete file if it does not exist in the source directory
            if [ ! -f "$source_file" ]; then
                echo "rm '$backup_file'"
                
                if [ "$check_mode" = false ]; then
		            file_size=$(du -b "$file" | cut -f1)
                    rm "$backup_file" || { errors=$((errors + 1)); continue; }
                    deleted=$((deleted + 1))
		            deleted_data=$((deleted_data + file_size)) 
                fi
            fi
        elif [[ -d "$file" ]]; then
            filename=$(basename "$file")
            source_dir="$SOURCE_DIR/$filename"
            backup_dir="$BACKUP_DIR/$filename"

            # Delete directory if it does not exist in the source directory
            if [ ! -d "$source_dir" ]; then
		        dir_size=$(du -sb "$backup_dir" | cut -f1)
                echo "rm -r '$backup_dir'"
                
                if [ "$check_mode" = false ]; then
                    rm -r "$backup_dir" || { errors=$((errors + 1)); continue; }
                    deleted=$((deleted + 1))
		            deleted_data=$((deleted_data + dir_size))
                fi
            fi
        fi
    done

    backup_summary

    # Now, process all subdirectories in SOURCE_DIR
    for dir in "$SOURCE_DIR"/*; do
        if [[ -d "$dir" ]]; then
            filename=$(basename "$dir")
            source_subdir="$SOURCE_DIR/$filename"
            backup_subdir="$BACKUP_DIR/$filename"

	        # Skip if the file is in the exclusions list
            if [[ " ${exclusions[@]} " =~ " $source_subdir " ]]; then
                echo "Skipping '$source_subdir' as it is in the exclude list."
                continue
            fi

            echo -e "$source_subdir is a subdirectory"
            echo -e "Backing up '$source_subdir' to '$backup_subdir'..."
            
            if [ ! -d "$backup_subdir" ] || [ "$source_subdir" -nt "$backup_subdir" ]; then
                echo "mkdir -p '$backup_subdir'"
                
                if [ "$check_mode" = false ]; then
                    mkdir -p "$backup_subdir"
                fi
            fi
            
            # Recursively back up the subdirectory
            backup_tree "$source_subdir" "$backup_subdir" "$check_mode" "$exclude_file" "$regex_pattern"
        fi
    done
}

