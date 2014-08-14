/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>

@class GINIURLSession, GINIAPIManager, BFTask;
@protocol GINIURLSession;

/**
 * The `GINIUserCenterManager` handles the communication with the Gini User Center via the Gini User Center API
 * (see http://developer.gini.net/gini-api/html/user_center_api.html for details). It can be used to create new users,
 * log in a user or to get information on a user.
 *
 * @warning Access to the User Center API is restricted to selected clients only.
 */
@interface GINIUserCenterManager : NSObject

/** @name Factory */
/**
 * Factory to create a new `GINIUserCenterManager` instance.
 *
 * @param urlSession    The `GINIURLSession` instance that will be used to do the HTTP requests to the Gini User Center.
 */
+ (instancetype)userCenterManagerWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL;

/** @name initializer */
/**
 * The designated initializer.
 */
- (instancetype)initWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL;

/** @name Methods */
/**
 * Gets the information on the user with the given unique ID.
 *
 * @param userID        The user's unique ID.
 * @returns             A `BFTask *` which will resolve to a `GINIUser` model instance representing the user information.
 */
- (BFTask *)getUserInfo:(NSString *)userID;

/**
 * Creates a new user.
 *
 * @param email         The user's email address. Will also be used as the user's username.
 * @param password      The user's password. Must be at leas 6 characters long.
 * @returns             A `BFTask *` which will resolve to the user's unique ID.
 */
- (BFTask *)createUserWithEmail:(NSString *)email password:(NSString *)password;

/**
 * Logs in the user with the given username and password.
 *
 * @param email         The user's username (usually the email address).
 * @param password      The user's password.
 * @return              A `BFTask *` which will resolve to a `GINISession` instance.
 */
- (BFTask *)loginUser:(NSString *)userName password:(NSString *)password;
@end
