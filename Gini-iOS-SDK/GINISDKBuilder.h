/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>

@class GiniSDK;
@class GINIInjector;


/**
 * The GINISDKBuilder is used to create and configure new instances of the Gini SDK.
 */
@interface GINISDKBuilder : NSObject

/**
 * Creates an instance of the GINISDKBuilder where the client authorization flow is used.
 *
 * @param urlScheme         The custom URL scheme of the application that is used for the authorization flow. It is used
 *                          when the browser redirects back to the app after a login. Must be the same as the custom URL
 *                          you registered with Gini.
 *
 * @param clientID          The application's client ID for the Gini API.
 */
+ (instancetype)clientFlowWithClientID:(NSString *)clientID urlScheme:(NSString *)urlScheme;

/**
 * Creates an instance of the GINISDKBuilder where the server authorization flow is used.
 *
 * @param urlScheme         The custom URL scheme of the application that is used for the authorization flow. It is used
 *                          when the browser redirects back to the app after a login. Must be the same as the custom URL
 *                          you registered with Gini.
 *
 * @param clientID          The application's client ID for the Gini API.
 *
 * @param clientSecret      The client secret you received from Gini.
 */

+ (instancetype)serverFlowWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret urlScheme:(NSString *)urlScheme;

/**
 * Creates an instance of the GINISDKBuilder where anonymous users are used.
 *
 * @param clientID          The application's clientID for the Gini API.
 *
 * @param userEmailDomain:  The domain of the email address.
 *
 * @warning: This requires access to the Gini User Center API. Access to the User Center API is restricted to selected
 * clients only.
 */
+ (instancetype)anonymousUserWithClientID:(NSString *)clientId clientSecret:(NSString *)clientSecret userEmailDomain:(NSString *)emailDomain;


/**
 * The GINIInjector instance which is used for the dependency injection.
 */
@property GINIInjector *injector;

/**
 * Use the sandbox environment (https://api-sandbox.gini.net/ and https://user-sandbox.gini.net/) instead of the
 * production environment.
 *
 * This method returns the instance on which it is called, so it is possible to chain the configuration via builder
 * methods.
 */
- (instancetype)useSandbox;

/**
 * Set the `NSNotificationCenter` instance which is used for the notifications.
 *
 * This method returns the instance on which it is called, so it is possible to chain the configuration via builder
 * methods.
 */
- (instancetype)useNotificationCenter:(NSNotificationCenter *)notificationCenter;

/**
 * Creates and returns the GiniSDK instance.
 */
- (GiniSDK *)build;

@end
