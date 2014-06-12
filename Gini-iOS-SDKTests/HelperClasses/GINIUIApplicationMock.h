/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>

@class GINISessionManager;

@interface GINIUIApplicationMock : NSObject {
    GINISessionManager *_sessionManager;
}

@property NSURL* openingURL;

- (instancetype)initWithSessionManager:(GINISessionManager *)sessionManager openURLBlock:(BOOL(^)(NSURL *URL))openURLBlock;

// Helpers

/*
 * This methods build a URL that stubs the URL of the GINI authentication server when the login succeeds.
 */
+ (NSURL *)incomingURLWithRedirectURI:(NSString *)redirectURI state:(NSString *)state accessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiresIn:(NSTimeInterval)expiresIn;
+ (NSURL *)incomingURLWithRedirectURI:(NSString *)redirectURI state:(NSString *)state code:(NSString *)code;

/*
 * Sends an 'openURL' message to the ApplicationMock
 */
- (void)fakeIncomingURL:(NSURL *)URL;

@end
