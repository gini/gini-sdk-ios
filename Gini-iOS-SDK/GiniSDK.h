/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */
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


// Keys used in the injector. See the discussion on keys at `GINIInjector` class.

/// Use this key to identify the base URL of the Gini API in the injector.
FOUNDATION_EXPORT NSString *const GINIAPIBaseURLKey;
/// Use this key to identify the base URL of the Gini user center in the injector.
FOUNDATION_EXPORT NSString *const GINIUserBaseURLKey;
/// Use this key to identify the application's custom URL scheme in the injector.
FOUNDATION_EXPORT NSString *const GINIURLSchemeKey;
/// Use this key to identify the application's client ID in the injector.
FOUNDATION_EXPORT NSString *const GINIClientIDKey;
/// Use this key to identify the application's client secret in the injector.
FOUNDATION_EXPORT NSString *const GINIClientSecretKey;
/// Use this key to identify the application's credential store identifier (see the `GINIKeychainCredentialsStore` class for details.
FOUNDATION_EXPORT NSString *const GINICredentialsStoreIdentifierKey;
/**
 * Use this key to identify the application's credential (keychain) access group (see the discussion at the
 * `GINIKeychainCredentialsStore` class and
 * https://developer.apple.com/library/ios/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/data/kSecAttrAccessGroup
 * for Details.
 */
FOUNDATION_EXPORT NSString *const GINICredentialsStoreAccessGroupKey;


@interface GINIInjector (DefaultWiring)

/**
 * Returns an instance of the GINIInjector where all dependencies are configured with standard values. The default
 * configuration uses the client authentication flow.
 */
+ (instancetype) defaultInjector;

@end


/**
 * The Gini SDK.
 */
@interface GiniSDK : NSObject

/**
 * Creates an instance of the GiniSDK where the client authentication flow is used.
 *
 * @param urlScheme      The custom URL scheme of the application that is used for the authentication flow. It is used
 *                       when the browser redirects back to the app after a login. Must be the same as the custom URL
 *                       you registered with Gini.
 *
 * @param clientID       The application's client ID for the Gini API.
 */
+ (instancetype)giniSDKWithAppURLScheme:(NSString *)urlScheme clientID:(NSString *)clientID;

/**
* Creates an instance of the GiniSDK where the server authentication flow is used.
*
* @param urlScheme       The custom URL scheme of the application that is used for the authentication flow. It is used
*                        when the browser redirects back to the app after a login. Must be the same as the custom URL
*                        you registered with Gini.
*
* @param clientID        The application's client ID for the Gini API.
*
* @param clientSecret    The client secret you received from Gini.
*/
+ (instancetype)giniSDKWithAppURLScheme:(NSString *)urlScheme clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

/**
 * The designated initializer.
 *
 * @param injector       The GINIInjector instance that is used for wiring the app.
 */
- (instancetype)initWithInjector:(GINIInjector *)injector;

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

/**
 * The injector that is used by the SDK to instantiate the classes.
 */
@property (readonly) GINIInjector *injector;

@end
