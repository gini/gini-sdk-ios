#!/bin/sh
#
# Copyright (c) 2014-present Gini GmbH
#

cd $TRAVIS_BUILD_DIR
mkdir appledoc
cd appledoc
wget https://github.com/tomaz/appledoc/releases/download/v2.2-963/appledoc.zip
unzip appledoc.zip

