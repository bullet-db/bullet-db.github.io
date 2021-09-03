#!/bin/sh

# This script is supposed to run from the directory of the maven project for the docs for and takes 3 arguments:
# 1. The name of the project: e.g. bullet-core
# 2. The tag to build docs for: e.g 1.2.0
# 3. The directory to copy containing the master branch of the bullet-db.github.io git repository
# It will clean and checkout the repo at the tag, build the docs and copy the docs into the appropriate javadocs folder
# (creating it if necessary) in the bullet-db.github.io git repository

function build_docs() {
  local PROJECT=$1
  local VERSION=$2
  local TAG="${PROJECT}-${VERSION}"

  echo "Checking out repo at ${TAG}..."
  git checkout $TAG
  echo "Building docs..."
  make doc
  git checkout master
}

function copy_docs() {
  local PROJECT=$1
  local VERSION=$2
  local DEST=$3

  local TARGET="${DEST}/apidocs/${PROJECT}/${VERSION}"
  echo "Deleting ${TARGET} if it exists..."
  rm -rf ${TARGET}

  echo "Making ${TARGET} if necessary..."
  mkdir -p $TARGET

  echo "Copying docs to ${TARGET}..."
  cp -r target/site/*docs/* $TARGET/
}

build_docs $1 $2
copy_docs $1 $2 $3
