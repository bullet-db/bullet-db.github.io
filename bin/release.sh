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
mkdir -p tmp-folder-for-site
mv site/ ./tmp-folder-for-site/
echo Checking out master...
git checkout master
git pull
# Delete everything except "tmp-folder-for-site", "." and files/folders beginning with "."
find . | grep -v "tmp-folder-for-site" | grep -v "^\./\." | grep -v "^\.$" | xargs rm -rf
cp -r ./tmp-folder-for-site/site/ ./
rm -rf ./tmp-folder-for-site/
git add -A
git commit -m "Build at ${COMMIT}"
git push
git checkout src
