#!/bin/bash
#
# Xcode run script for version, whenever build a new version,
#   can choose to increase bundle version, update build date
#   & git latest commit hash.
#
#
# Usage:
#
#   $ chmod +x update_frameworks.sh
#
# Update all frameworks
#
#   $ ./update_frameworks.sh
#
# Update specific framwork, e.g. "Foo"
#
#   $ ./update_frameworks.sh Foo
#
# Note:
#
#   $ carthage help update
# 

#flags="--use-submodules --use-ssh --no-use-binaries --platform iOS,watchOS,macOS"
#flags="--use-submodules --no-use-binaries --platform iOS,watchOS,macOS"
flags="--use-submodules --no-use-binaries --platform iOS --verbose"

if [ $# -eq 0 ]; then
    cmd="carthage update $flags"
else
    cmd="carthage update $1 $flags"
fi 

echo $cmd
$cmd

