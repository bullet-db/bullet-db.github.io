#!/bin/sh

# This script will build the documentation from the current "src" branch and push it to the "master" branch.
# "mkdocs" must be available, and you must be in a clean git environment ("git diff" should print nothing).

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
# Carefully delete everything in this folder
rm -rf ./*
cp -r /tmp/tmp-folder-for-bullet-docs/site/ ./
rm -rf /tmp/tmp-folder-for-bullet-docs/
git add -A
git commit -m "Build at ${COMMIT}"
echo ---------------- SUCCESS --------------------
echo The documentation has been built locally
echo You are on the **master** branch
echo DO "git push" TO PUSH CHANGES TO REMOTE REPO
echo ---------------------------------------------
