#!/bin/bash
set -e


SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy."
    exit 0
fi

REPO=`git config remote.origin.url`
SHA=`git rev-parse --verify HEAD`
echo "Repository: $REPO"
echo "SHA: $SHA"
ls $HOME
exit 0

#TEMPDIR="$HOME/tmp/" 
#mkdir -p "$TEMPDIR"
#wget -O "$TEMPDIR/dl-current.zip" https://dreamland-mud.github.io/dreamland_mudlet/downloads/dl.zip

