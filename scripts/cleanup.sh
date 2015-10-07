#!/bin/sh
#
# Copyright (c) 2015-present Gini GmbH
#

if [ -d $TRAVIS_BUILD_DIR/appledoc ]; then
	rm -rf $TRAVIS_BUILD_DIR/appledoc
fi

if [ -d $TRAVIS_BUILD_DIR/integration-guide ]; then
	rm -rf $TRAVIS_BUILD_DIR/integration-guide
fi

if [ -d $TRAVIS_BUILD_DIR/docs ]; then
	rm -rf $TRAVIS_BUILD_DIR/docs
fi
