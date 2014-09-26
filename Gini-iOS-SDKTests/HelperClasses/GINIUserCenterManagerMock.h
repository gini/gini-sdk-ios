/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "GINIUserCenterManager.h"

@class BFTask;


@interface GINIUserCenterManagerMock : GINIUserCenterManager

// Features
@property BOOL loginEnabled;
@property BOOL getInfoEnabled;
@property BOOL createUserEnabled;

// Watchers
/// Number of times the createUser method was called.
@property NSUInteger createUserCalled;

/// Whether or not the login method resolves to a login error.
@property BOOL raiseWrongCredentialsOnLogin;


/// Whether or not the create user method should fail.
@property BOOL raiseHTTPErrorOnCreateUser;

@end
