#!/bin/bash

gem install jazzy
jazzy -v

jazzy \
  --objc \
  --clean \
  --sdk iphonesimulator \
  --umbrella-header Gini-iOS-SDK/GiniSDK.h \
  --framework-root . \
  --readme README.md \
  --author Gini \
  --author_url https://gini.net \
  --github_url https://github.com/gini/gini-sdk-ios \
  --root-url http://developer.gini.net/gini-sdk-ios/api/ \
  --module Gini-iOS-SDK \
  --output Documentation/Api/ \
  --theme fullwidth \
