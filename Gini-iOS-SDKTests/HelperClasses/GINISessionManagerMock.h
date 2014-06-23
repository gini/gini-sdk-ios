/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "GINISessionManager.h"


@class GINISession;

/**
 * A Mock for the GINISessionManager that can be used in tests. It takes an access token on initialization and always
 * immediately returns a session with the given access token when a session is requested without the need to do some
 * asynchronous stuff.
 */
@interface GINISessionManagerMock : NSObject <GINISessionManager>

/**
 * Factory to create a new instance of the GINISessionManagerMock. The mock's getSession method will always return a
 * session with the given access token and requestToken and expirationDate both set to nil.
 */
+ (instancetype)sessionManagerWithAccessToken:(NSString *)accessToken;

/**
 * The designated initializer. The instance will always return the given session object when its getSession method is
 * called.
 */
- (instancetype)initWithSession:(GINISession *)session;

@end