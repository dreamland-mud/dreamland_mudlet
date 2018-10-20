#!/bin/bash
set -e

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
    echo "Not on master, skipping deploy."
    exit 0
fi

REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

git clone --depth=10 --branch=gh-pages $REPO gh-pages
cd gh-pages/downloads && unzip dl.zip
if diff Dreamland.xml ../../Dreamland.xml && diff config.lua ../../config.lua; then
    echo "No changes to zip file, skipping deploy."
    exit 0
fi

echo "Updating dl.zip"
(cd ../.. && zip gh-pages/downloads/dl.zip Dreamland.xml config.lua)

ver=`cat version`
echo $((ver+1)) > version
echo "Updating version to "`cat version`
 
git config user.name "Travis CI"
git config user.email "ruffina.koza@gmail.com"
git add -A .
git commit -m "Deploy to GitHub Pages: ${SHA}"

chmod 600 ../deploy_key
eval `ssh-agent -s`
ssh-add ../deploy_key

git push $SSH_REPO gh-pages
