.. _guide-swift:

=======================
Swift Integration Guide
=======================

You can easily use the Gini iOS SDK in applications you built with Apple's Swift programming language.

Bridging header
===============

In order to use the Gini SDK in Swift code, you first need to add a bridge header file. A good tutorial how to add a
bridge header file can be found at `Medium <https://medium.com/@stigi/swift-cocoapods-da09d8ba6dd2>`_.

Inside the bridging header, you must import the Gini SDK by adding the following line:

.. code-block:: obj-c

    #import <Gini-iOS-SDK/GiniSDK.h>

After that, you can use all Gini classes inside your Swift code. See the :ref:`integration guide <guide-getting-started>`
for details how to integrate the Gini iOS SDK into your app. 

The code examples are in Objective-C but can be used in Swift if you follow  `Apple's interaction guide <https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html#//apple_ref/doc/uid/TP40014216-CH4-XID_26>`_.
