#!/bin/sh

echo ${ACCESS_TOKEN} > Gini-iOS-SDKIntegrationTests/Resources/accessToken.txt

xcodebuild -workspace Gini-iOS-SDK.xcworkspace -scheme Gini-iOS-SDKIntegrationTests -sdk iphonesimulator test

rm Gini-iOS-SDKIntegrationTests/Resources/accessToken.txt
