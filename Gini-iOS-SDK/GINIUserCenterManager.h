/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>

@class GINIURLSession, GINIAPIManager, BFTask, GINISession;
@protocol GINIURLSession;


/**
 * The name of the notification which is posted when a user was created. The notification's object is a `GINIUser`
 * instance representing the newly created user.
 **/
extern NSString *const GINIUserCreationNotification;

/** The name of the notification which is posted when there was an error during user creation. */
extern NSString *const GINIUserCreationErrorNotification;

/** The name of the notification which is posted when a user was logged in. */
extern NSString *const GINILoginNotification;

/** The name of the notification when there was an error during login */
extern NSString *const GINILoginErrorNotification;


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
+ (instancetype)userCenterManagerWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL notificationCenter:(NSNotificationCenter *)notificationCenter;

/** @name initializer */
/**
 * The designated initializer.
 */
- (instancetype)initWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL notificationCenter:(NSNotificationCenter *)notificationCenter;

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
 * @param password      The user's password. Must be at least 6 characters long.
 * @returns             A `BFTask *` which will resolve to the user's unique ID.
 */
- (BFTask *)createUserWithEmail:(NSString *)email password:(NSString *)password;

/**
 * Logs in the user with the given username and password.
 *
 * @param userName         The user's username (usually the email address).
 * @param password         The user's password.
 * @return              A `BFTask *` which will resolve to a `GINISession` instance in case of success or to a GINIError
 *                      if the credentials are wrong.
 */
- (BFTask *)loginUser:(NSString *)userName password:(NSString *)password;

/**
 * Returns information about the Gini API session.
 *
 * Although you may use this method with any session (for Gini API or User Center API) the
 * purpose of this method is to retrieve information about Gini API sessions.
 *
 *
 * @param giniApiSession            A valid session for the Gini API.
 * @return                          A `BFTask *` which will resolve to an NSDictionary containing information
 *                                  about the session.
 */
- (BFTask *)getAccessTokenInfoForGiniApiSession:(GINISession *)giniApiSession;

/**
 * Returns the user id of the logged in user.
 *
 * @param giniApiSession            The session for the Gini API, which was returned when the
 *                                  user was logged in.
 * @return                          A `BFTask *` which will resolve to a String containing the user id.
 */
- (BFTask *)getUserIdForGiniApiSession:(GINISession *)giniApiSession;

/**
 * Update the email of a user.
 *
 * @param newEmail                  A new email address.
 * @param oldEmail                  The previous email address of the user.
 * @param giniApiSession            The session for the Gini API which was returned when
 *                                  the user was logged in.
 * @return                          A `BFTask *` with empty result as the response contains no data.
 */
- (BFTask *)updateEmail:(NSString *)newEmail
               oldEmail:(NSString *)oldEmail
         giniApiSession:(GINISession *)giniApiSession;

@end
