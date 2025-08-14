#!/bin/bash
# It only works on my exact directory structure,
# so it is not a general tests file and its not meant to be run by anyone else.

cd ~/media/0d6fbdf3-baad-4eb1-8af8-4e74a766a723/Documents/UA/SO/Projects/

# ARGS TESTS
./backup.sh -c "Personal_web" "Personal_backup"
./backup.sh -c -b "exc" "Personal_web" "Personal_backup" # Should exclude art.html; Personal_web/Drawings
./backup.sh -c -r ".*\.css" "Personal_web" "Personal_backup" # Should only backup css files
./backup.sh -c -b "exc" -r ".*\.css" "Personal_web" "Personal_backup" # Should do the two things above

# BACKUP TESTS
echo "FIRST BACKUP"
./backup.sh "Personal_web" "Personal_backup"
echo "SECOND BACKUP"
./backup.sh "Personal_web" "Personal_backup"

# DELETED FILES TESTS
touch "Personal_backup/NEWFILE"
mkdir -p "Personal_backup/NEWFOLDER/"
rm "Personal_web/aboutme.html"
./backup.sh "Personal_web" "Personal_backup"
# Should delete NEWFILE and NEWFOLDER and aboutme.html

# backup check
echo "TEST" | cat > "Personal_web/art.html"
./backup.sh "Personal_web" "Personal_backup" # Should update art.html
echo "TEST" | cat > "Personal_backup/cv.html"
./backup.sh "Personal_web" "Personal_backup" # Should get a warning
