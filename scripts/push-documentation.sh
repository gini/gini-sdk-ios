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

# Clean up
rm -rf docs
git clone -b docs git@github.com:gini/gini-sdk-ios.git docs
rm -rf docs/*

# Copy integration guide source files
cp -a Documentation/. docs/Documentation/

# Create api documentation
sh scripts/build-documentation-api.sh

# Push to docs
cd docs
git add -u
git add .
git diff --quiet --exit-code --cached || git commit -a -m 'Deploy Gini SDK iOS documentation to docs branch'
git push origin docs