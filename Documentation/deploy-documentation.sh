#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. Not publishing documentation."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. Not publishing documentation."
  exit 0
fi

cd Documentation
virtualenv ./virtualenv
source virtualenv/bin/activate
pip install -r requirements.txt

make clean
make html

cd build
rm -rf gh-pages
git clone -b gh-pages git@github.com:gini/gini-sdk-ios.git gh-pages

rm -rf gh-pages/*
mkdir gh-pages/docs
cp -a html/. gh-pages/docs/

mkdir gh-pages/api
cp -a ../../Api/. gh-pages/api/

cd gh-pages
touch .nojekyll

git config user.name "Travis CI"
git config user.email "hello@gini.net" # Use Schorschis Account
git add -u
git add .
git diff --quiet --exit-code --cached || git commit -a -m 'Deploy Gini SDK iOS documentation to Github Pages'
git push