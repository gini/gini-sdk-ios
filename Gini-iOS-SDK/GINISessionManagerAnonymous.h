/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "GINISessionManager.h"

@class GINIUserCenterManager;
@protocol GINICredentialsStore;


/**
 * The name of the notification which is posted when the stored credentials of an existing user are used for the login
 * attempt. The object of the notification will be the user's email address.
 **/
extern NSString *const GINIUsingExistingUserNotification;


/**
 * An implementation for the <GINISessionManager> protocol. Instead of using the OAuth authorization flow where the
 * user has to sign in, this session manager implementation uses the Gini User Center API to create new users on the
 * fly. The created account is stored in the keychain. This completely hides the user accounts from the user and has the
 * effect of anonymous accounts.
 *
 * @warning Access to the User Center API is restricted to selected clients only.
 */
@interface GINISessionManagerAnonymous : NSObject <GINISessionManager>


/**
 * Factory to create a new `GINISessionManagerAnonymous` instance.
 *
 * @param credentialsStore      A <GINICredentialsStore> implementation that is used to store the login credentials of
 *                              the created user.
 * @param userCenterManager     The `GINIUserCenterManager` instance that is used to do the requests to the Gini
 *                              User Center API.
 * @param emailDomain           The domain part of the created user emails. The created user names are in the form
 *                              "<random>@<emailDomain>" and have a random password.
 * @param notificationCenter    The `NSNotificationCenter` instance which is used to post notifications.
 */
+ (instancetype)sessionManagerWithCredentialsStore:(id <GINICredentialsStore>)credentialsStore
                                 userCenterManager:(GINIUserCenterManager *)userCenterManager
                                       emailDomain:(NSString *)emailDomain
                                notificationCenter:(NSNotificationCenter *)notificationCenter;

/**
 * The designated initializer.
 *
 * @param credentialsStore      A <GINICredentialsStore> implementation that is used to store the login credentials of
 *                              the created user.
 * @param userCenterManager     The `GINIUserCenterManager` instance that is used to do the requests to the Gini
 *                              User Center API.
 * @param emailDomain           The domain part of the created user emails. The created user names are in the form
 *                              "<random>@<emailDomain>" and have a random password.
 * @param notificationCenter    The `NSNotificationCenter` instance which is used to post notifications.
 */
- (instancetype)initWithCredentialsStore:(id <GINICredentialsStore>)credentialsStore
                       userCenterManager:(GINIUserCenterManager *)userCenterManager
                             emailDomain:(NSString *)emailDomain
                      notificationCenter:(NSNotificationCenter *)notificationCenter;

/**
 * The credentials store which is used to store the user credentials.
 */
@property id<GINICredentialsStore> credentialsStore;

/// The user center manager which is used to manage the user accounts.
@property (readonly) GINIUserCenterManager *userCenterManager;

@end
