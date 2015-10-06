.. _guide-getting-started:

===============
Getting started
===============


First of all: Add the Library to your Build
===========================================

The Gini iOS SDK is provided via `Cocoapods <http://www.cocoapods.org>`_.
To install the Gini iOS SDK simply add the following repository to your Cocoapods installation

.. code-block:: none

    $ pod repo add gini-podspecs https://github.com/gini/gini-podspecs.git

and include the pod in your Podfile

.. code-block:: none

    pod 'Gini-iOS-SDK'

Then run

.. code-block:: none

    $ pod install
    
in your project directory and open the generated Xcode workspace.


Integrating the Gini SDK
========================


The Gini SDK provides the ``GiniSDK`` class which is a facade to all functionality of the Gini SDK. We recommend using an
instance of this class singleton-like. By saying singleton-like we mean that you somehow manage to create and keep
one instance at application start. Instead of creating a new instance every time you need to interact with the
Gini API, you reuse this instance. This has the benefit that the SDK can reuse sessions between requests to the
Gini API, which may save a significant number of HTTP requests.

Creating the Gini SDK instance
------------------------------

In order to create an instance of the ``GiniSDK`` class, you need both your client id and your client secret. If you don't
have a client id and client secret yet, you need to register your application with Gini. `See the Gini API documentation
to find out how to register your application with Gini <http://developer.gini.net/gini-api/html/guides/oauth2.html#first-of-all-register-your-application-with-gini>`_.

All requests to the Gini API are made on behalf of a user. This means in particular that all created documents are bound
to a specific user account. But since you are most likely only interested in the results of the semantic document
analysis and not in a cloud document storage system, the Gini API has the feature of "anonymous users". This means that
user accounts are created on the fly and the user account is unknown to your application's user.

The following example describes how to use the Gini API in your application with such anonymous user accounts. To use
the Gini API, you must create an instance of the ``GiniSDK`` class. The ``GiniSDK`` instance is configured and created with the
help of the ``GINISDKBuilder`` class. In this example, the anonymous users are created with the email domain "example.com".
An example of a username created with this configuration would be ``550e8400-e29b-11d4-a716-446655440000@example.com``

.. code-block:: obj-c

    // AppDelegate.h

    #import <Gini-iOS-SDK/GiniSDK.h>

    @interface AppDelegate

    @property GiniSDK *giniSDK;
    @property (strong, nonatomic) UIWindow *window;

    @end

.. code-block:: obj-c

    // AppDelegate.m
    
    ...

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        _giniSDK = [[GINISDKBuilder anonymousUserWithClientID:@"your-client-id" clientSecret:@"your-client-secret" userEmailDomain:@"example.com"] build];
        // The DocumentTaskManager provides the high-level API to work with documents.
        GINIDocumentTaskManager *documentManager = _giniSDK.documentTaskManager;

        return YES;
    }

    ...

Whenever you need the Gini SDK, for example in a view controller, you can now access your AppDelegate and get the ``GiniSDK`` instance:

.. code-block:: obj-c

    GiniSDK *sdk = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).giniSDK;

Congratulations, you have now successfully integrated the Gini SDK. 

