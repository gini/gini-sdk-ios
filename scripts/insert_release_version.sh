#!/bin/bash
#
# Copyright (c) 2014-present Gini GmbH
#

if [ "$#" != "2" ]; then
    echo "Usage: insert_release_version.sh <changelog> <version>"
fi

version_and_date="$2 (`date '+%d-%m-%Y'`)"

cd `dirname "$1"`

filename=`basename "$1"`

cat $filename | sed "s/{{version_and_date}}/${version_and_date}\n$(printf '=%.0s' `seq 1 ${#version_and_date}`)/" > ${filename}.tmp && mv ${filename}.tmp ${filename}

