#!/bin/sh

# This script will build the documentation from the current "src" branch. "mkdocs" must be available, and
# you must be in a clean git environment ("git diff" should print nothing). The apidocs folder currently
# in the master branch will be saved in a tmp folder and then put back to replace the corresponding folder
# built from the src branch, which is just a placeholder.

git checkout src
git pull
COMMIT=`git rev-parse HEAD | cut -c 1-7`
echo Building docs...
mkdocs build
if [ $? -ne 0 ]; then
    echo ------------------ ERROR ------------------
    echo mkdocs must be installed
    echo see README.md for more info
    echo -------------------------------------------
    exit 1;
fi
set -e
rm -rf /tmp/tmp-folder-for-bullet-docs/
mkdir -p /tmp/tmp-folder-for-bullet-docs/
mv site/ /tmp/tmp-folder-for-bullet-docs/
echo Checking out master...
git checkout master
git pull
# Save the apidocs currently in master branch
mv apidocs/ /tmp/tmp-folder-for-bullet-docs/
rm -rf ./*
cp -r /tmp/tmp-folder-for-bullet-docs/site/ ./
# Delete fake apidocs and replace with saved ones
rm -rf ./apidocs/
mv /tmp/tmp-folder-for-bullet-docs/apidocs/ ./
rm -rf /tmp/tmp-folder-for-bullet-docs/
git add -A
git commit -m "Build at ${COMMIT}"
echo ---------------- SUCCESS --------------------
echo The documentation has been built locally
echo You are on the **master** branch
echo DO "git push" TO PUSH CHANGES TO REMOTE REPO
echo ---------------------------------------------
