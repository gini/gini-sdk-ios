#!/bin/bash
#
# Copyright (c) 2014-present Gini GmbH
#

version_and_date="$1 (`date '+%d-%m-%Y'`)"

cat changelog.rst | sed "s/{{version_and_date}}/${version_and_date}§$(printf '=%.0s' `seq 1 ${#version_and_date}`)/" | tr '§' '\n' > changelog.rst.tmp && mv changelog.rst.tmp changelog.rst

