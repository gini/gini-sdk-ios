#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

gem install jazzy
jazzy -v

jazzy \
  --objc \
  --clean \
  --sdk iphonesimulator \
  --umbrella-header $TRAVIS_BUILD_DIR/Gini-iOS-SDK/GiniSDK.h \
  --framework-root $TRAVIS_BUILD_DIR \
  --readme $TRAVIS_BUILD_DIR/README.md \
  --author Gini \
  --author_url https://gini.net \
  --github_url https://github.com/gini/gini-sdk-ios \
  --root-url http://developer.gini.net/gini-sdk-ios/api/ \
  --module Gini-iOS-SDK \
  --output $TRAVIS_BUILD_DIR/docs/api/ \
  --theme fullwidth \