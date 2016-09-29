#!/bin/sh
#
# Copyright (c) 2015-present Gini GmbH
#

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
#   echo "This is a pull request. Not publishing documentation."
#   exit 0
# fi
# if [[ "$TRAVIS_BRANCH" != "master" ]]; then
#   echo "Testing on a branch other than master. Not publishing documentation."
#   exit 0
# fi


mkdir -p $TRAVIS_BUILD_DIR/integration-guide
cd $TRAVIS_BUILD_DIR/integration-guide
cp -r $TRAVIS_BUILD_DIR/doc/* .

curl -L -o virtualenv.py https://raw.github.com/pypa/virtualenv/master/virtualenv.py
virtualenv ./virtualenv
source virtualenv/bin/activate
pip install -r requirements.txt

make clean
make html
