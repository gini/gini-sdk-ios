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

git clone --branch=gh-pages https://${GH_TOKEN}@${GH_REF} gh-pages > /dev/null > /dev/null

cd gh-pages

mkdir appledocs
cp -Rf $TRAVIS_BUILD_DIR/docs/html/* appledocs/

touch .nojekyll
git add -f .
git commit -m "Appledoc documentation updated (Travis build $TRAVIS_BUILD_NUMBER)"
git push -fq origin gh-pages > /dev/null
