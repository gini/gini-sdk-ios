#!/bin/sh
#
# Copyright (c) 2015-present Gini GmbH
#

virtualenv ./virtualenv
source virtualenv/bin/activate
pip install -r requirements.txt

make clean
make html
