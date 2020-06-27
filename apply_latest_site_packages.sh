#!/bin/bash
#

#
# This script will copy needed package files at
#
#   ./site_packages
#
#   to
#
#   ./PythonForVideoMemos/python/lib/python3.8/site-packages
#
# So, wheneven updated data in ./site_packages, should execute
#   this script.
#

# Colors
nc='\033[0m'      # No Color
r='\033[0;31m'    # Red
g='\033[0;32m'    # Green
p='\033[0;35m'    # Purple
y='\033[1;33m'    # Yellow
cyan='\033[1;36m' # Cyan

SRC_ROOT="./site_packages"
DEST_ROOT="./PythonForVideoMemos/python/lib/python3.8/site-packages"
BACKUP_ROOT="./site_packages_backups"

#
# 1. Backup files at `DEST_ROOT`
#
echo
echo -e 1. Backuping files at destination \"${cyan}$DEST_ROOT${nc}\" ...
#
# Update Build Date
#
# REF: https://www.lifewire.com/display-date-time-using-linux-command-line-4032698
#
BACKUP_FOLDER=$(date +"%F-%H%M%S") # e.g. "2020-06-25-140559"

backup_from="$DEST_ROOT/*"
backup_to="$BACKUP_ROOT/$BACKUP_FOLDER"

mkdir -p $backup_to
cp -rf $backup_from $backup_to
echo -e ${g}Backup Succeed.${nc}
echo

#
# 2. Delete files at `DEST_ROOT`
#
echo -e 2. Deleting files at destination \"${cyan}$DEST_ROOT${nc}\" ...

trash $backup_from
echo -e ${g}Delete Succeed.${nc}
echo

#
# 3. Copy latest site packages
#
echo -e 3. Copying latest site packages from \"${cyan}$SRC_ROOT${nc}\" to \"${cyan}$DEST_ROOT${nc}\" ...

#
# 3.1. Copy pkg: "video_memos"
#
pkg_name="video_memos"
echo -e  - Copying pkg: ${y}$pkg_name${nc} ...

pkg_dest="$DEST_ROOT/$pkg_name"
mkdir -p $pkg_dest

cp $SRC_ROOT/$pkg_name/*.py $pkg_dest/

#
# 3.2. Copy pkg: "you_get"
#
pkg_name="you_get"
echo -e  - Copying pkg: ${y}$pkg_name${nc} ...

mkdir -p $pkg_dest

pkg_src="$SRC_ROOT/you-get/src/you_get"
cd $pkg_src
echo -e Enter folder: ${cyan}$pkg_src${nc}

pkg_dest="../../../../$DEST_ROOT/$pkg_name"

for file in `find . ! -name '*.pyc' | sed 's/^.\///'`
  do if [ -d "./$file" ]; then
    mkdir -p "$pkg_dest/$file"
    echo "- d: $file > $pkg_dest/$file"
  else
    cp $file $pkg_dest/$file
    echo "- f: $file > $pkg_dest/$file"
  fi
done

#cp $pkg_src_root/*.py $DEST_ROOT/$pkg_name/

echo -e ${g}Copy files Succeed.${nc}
echo

