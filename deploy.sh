#!/bin/bash
set -e

set

#TRAVIS_PULL_REQUEST="false"
#TRAVIS_BRANCH="master"

PACKAGED="Dreamland.xml config.lua"
ARCHIVE="gh-pages/downloads/dl.zip"
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
    echo "Not on master, skipping deploy."
    exit 0
fi

echo "Checking for changes..."
git clone --depth=10 --branch=gh-pages $REPO gh-pages
unzip -o $ARCHIVE
if git diff --quiet -- $PACKAGED; then
    echo "No changes to zip file, skipping deploy."
    exit 0
fi
echo "Changes found."

echo "Updating archive..."
git checkout -- $PACKAGED
zip $ARCHIVE $PACKAGED
echo "Done"

echo "Incrementing version..."
cd `dirname $ARCHIVE` 
ver=`cat version`
echo $((ver+1)) > version
echo "Done: new version "`cat version`

echo "Pushing changes to GitHub..." 
git config user.name "Travis CI"
git config user.email "ruffina.koza@gmail.com"
git add -A .
git commit -m "Deploy to GitHub Pages: ${SHA}"
git push $SSH_REPO gh-pages
echo "Done"
