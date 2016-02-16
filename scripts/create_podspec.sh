#!/bin/bash
#
# Copyright (c) 2014-present Gini GmbH
#

cat Gini-iOS-SDK.podspec.template | sed "s/{{version}}/$1/" > Gini-iOS-SDK.podspec 

