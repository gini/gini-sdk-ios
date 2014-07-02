# Gini iOS SDK

An SDK for integrating Gini technology into other apps. With this SDK you will be able to extract semantic information from various types of documents.

The Gini iOS SDK works for both Objective-C and Swift apps.

## Installation

For maximum convenience we rely on the excellent dependency manager [Cocoapods](http://www.cocoapods.org).
To install the Gini iOS SDK simply add the following repository to your Cocoapods installation

    $ pod repo add gini-podspecs https://github.com/gini/gini-podspecs.git

and include the pod in your Podfile

    pod 'Gini-iOS-SDK'

Then run
    
    $ pod install
    
in your project directory and open the generated Xcode workspace.


## Register your App with Gini

See the [API Documentation](http://developer.gini.net/gini-api/html/guides/oauth2.html#first-of-all-register-your-application-with-gini).

## Usage

Learn how to use the Gini API at the [Gini Developer Portal](http://developer.gini.net):

- [Gini API Documentation](http://developer.gini.net/gini-api/)
- [Gini iOS SDK Documentation](http://developer.gini.net/gini-sdk-ios/)


## Usage in Swift code

In order to use the Gini SDK in Swift code, you first need to add a bridge header file. A good tutorial how to add a
bridge header file can be found at [Medium](https://medium.com/@stigi/swift-cocoapods-da09d8ba6dd2).

Inside the bridging header, you must import the Gini SDK by adding the following line:

    #import <Gini-iOS-SDK/GiniSDK.h>

After that, you can use all Gini classes inside your Swift code.


Copyright (c) 2014, [Gini GmbH](http://www.gini.net)
