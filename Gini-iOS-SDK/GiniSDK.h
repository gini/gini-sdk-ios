/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */
#import <Bolts/Bolts.h>
#import "GINIAPIManager.h"
#import "GINIInjector.h"
#import "GINIAPIManagerRequestFactory.h"
#import "GINIURLSession.h"
#import "GINISession.h"
#import "GINISessionManager.h"
#import "GINICredentialsStore.h"
#import "GINIKeychainCredentialsStore.h"
#import "GINISessionParser.h"
#import "GINIDocumentTaskManager.h"
#import "GINIIncomingURLDelegate.h"
#import "GINIDocument.h"
#import "GINIFactoryDescription.h"
#import "GINIURLResponse.h"
#import "GINIExtraction.h"
#import "GINISDKBuilder.h"
#import "GINIUser.h"
#import "GINIUserCenterManager.h"
#import "GINIKeychainManager.h"


// Keys used in the injector. See the discussion on keys at `GINIInjector` class.

/// Use this key to identify the base URL of the Gini API in the injector.
FOUNDATION_EXPORT NSString *const GINIInjectorAPIBaseURLKey;
/// Use this key to identify the base URL of the Gini user center in the injector.
FOUNDATION_EXPORT NSString *const GINIInjectorUserBaseURLKey;
/// Use this key to identify the application's custom URL scheme in the injector.
FOUNDATION_EXPORT NSString *const GINIInjectorURLSchemeKey;
/// Use this key to identify the application's client ID in the injector.
FOUNDATION_EXPORT NSString *const GINIInjectorClientIDKey;
/// Use this key to identify the application's client secret in the injector.
FOUNDATION_EXPORT NSString *const GINIInjectorClientSecretKey;


/**
 * The Gini SDK.
 */
@interface GiniSDK : NSObject


/** @name initializer */

/**
 * The designated initializer.
 *
 * @param injector       The GINIInjector instance that is used for wiring the app.
 */
- (instancetype)initWithInjector:(GINIInjector *)injector;


/** @name Provided Manager instances */

/**
 * The instance of the `GINIAPIManager` that is used by the SDK.
 *
 * @warning It is not recommended to use the GINIAPIManager directly. The GINIAPIManager is a very low level manager
 *          that handles only the communication with the Gini API and directly returns the data from the server. Usually
 *          you want to have better abstractions and advanced error handling. Because of that, it is recommended that
 *          you use the higher level abstractions at the `GINIDocumentTaskManager` (see also the `documentTaskManager`
 *          property).
 */
@property (readonly) GINIAPIManager *APIManager;

/**
 * The instance of the `GINISessionManager` that is used by the SDK.
 */
@property (readonly) id <GINISessionManager, GINIIncomingURLDelegate> sessionManager;

/**
 * The instance of the `GINIDocumentTaskManager` that is used by the SDK. The `GINIDocumentTaskManager` is the high
 * level API for the Gini API and it is recommended that you use this class in your application.
 */
@property (readonly) GINIDocumentTaskManager *documentTaskManager;

@end
