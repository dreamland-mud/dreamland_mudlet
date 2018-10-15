#!/bin/bash
set -e


SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Not on master, skipping deploy."
    exit 0
fi

REPO=`git config remote.origin.url`
SHA=`git rev-parse --verify HEAD`
echo "Repository: $REPO"
echo "SHA: $SHA"

zip dl-new.zip Dreamland.xml config.lua
SHA_NEW=`sha1sum -b dl-new.zip | cut -f1 -d " "`
wget -O "dl-old.zip" https://dreamland-mud.github.io/dreamland_mudlet/downloads/dl.zip
SHA_OLD=`sha1sum -b dl-old.zip | cut -f1 -d " "`
ls -la
echo "SHA_NEW $SHA_NEW"
echo "SHA_OLD $SHA_OLD"

if [ "$SHA_NEW" = "$SHA_OLD" ]; then
    echo "No changes, skipping deploy."
    exit 0
fi    


