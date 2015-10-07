#!/bin/sh
#
# Copyright (c) 2014-present Gini GmbH
#

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. Not publishing documentation."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. Not publishing documentation."
  exit 0
fi

cd $TRAVIS_BUILD_DIR 

git clone --branch=gh-pages https://$GH_TOKEN@github.com/gini/gini-sdk-ios.git gh-pages > /dev/null > /dev/null

cd gh-pages
git rm -rf *
cp -Rf $TRAVIS_BUILD_DIR/integration_guide/build/html/* .
rm -rf $TRAVIS_BUILD_DIR/integration_guide

mkdir appledocs
cp -Rf $TRAVIS_BUILD_DIR/docs/html/* appledocs/

touch .nojekyll
git add -f .
git commit -m "Update SDK documentation (Travis build $TRAVIS_BUILD_NUMBER)"
git push -fq origin gh-pages > /dev/null

