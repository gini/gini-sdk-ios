/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Bolts/BFTask.h>
#import "GINISessionManagerAnonymous.h"
#import "GINIUserCenterManager.h"
#import "GINISession.h"
#import "GINIKeychainCredentialsStore.h"
#import "GINIError.h"


@implementation GINISessionManagerAnonymous {
    /// The credentials store which is used to store the user accounts.
    id<GINICredentialsStore> _credentialsStore;

    /// The user center manager which is used to manage the user accounts.
    GINIUserCenterManager *_userCenterManager;

    /// The domain of the email address of new users.
    NSString *_emailDomain;

    /// The currently active session if there's a logged-in user.
    GINISession *_activeSession;

    /// The number of login requests.
    NSUInteger _loginAttempts;
}

+ (instancetype)sessionManagerWithCredentialsStore:(id<GINICredentialsStore>)credentialsStore userCenterManager:(GINIUserCenterManager *)userCenterManager emailDomain:(NSString *)emailDomain {
    return [[GINISessionManagerAnonymous alloc] initWithCredentialsStore:credentialsStore userCenterManager:userCenterManager emailDomain:emailDomain];
}

- (instancetype)initWithCredentialsStore:(id <GINICredentialsStore>)credentialsStore userCenterManager:(GINIUserCenterManager *)userCenterManager emailDomain:(NSString *)emailDomain {
    NSParameterAssert([credentialsStore conformsToProtocol:@protocol(GINICredentialsStore)]);
    NSParameterAssert([userCenterManager isKindOfClass:[GINIUserCenterManager class]]);
    NSParameterAssert([emailDomain isKindOfClass:[NSString class]]);

    if (self = [super init]) {
        _credentialsStore = credentialsStore;
        _userCenterManager = userCenterManager;
        _emailDomain = emailDomain;
        _loginAttempts = 0;
    }
    return self;
}

#pragma mark - GINISessionManager protocol
- (BFTask *)logIn {
    return [self getSession];
}

- (BFTask *)getSession {
    // Try to reuse an active session.
    if (_activeSession && ![_activeSession hasAlreadyExpired]) {
        return [BFTask taskWithResult:_activeSession];
    }

    // First step: Get the user credentials.
    return [[[[self getUserCredentials] continueWithBlock:^id(BFTask *task) {
        // There are no stored user credentials
        if (task.error) {
            // So create a new user and return the credentials of the new user.
            return [[self createUser] continueWithSuccessBlock:^id(BFTask *createTask) {
                return [self getUserCredentials];
            }];
        }
        return task.result;

        // Second step: Try to log-in the user.
    }] continueWithSuccessBlock:^id(BFTask *credentialsTask) {


        NSDictionary *credentials = credentialsTask.result;

        // Try to avoid infinite login attempts.
        _loginAttempts += 1;
        if (_loginAttempts > 3) {
            return [BFTask taskWithError:[GINIError errorWithCode:GINIErrorNoCredentials userInfo:nil]];
        }

        return [[_userCenterManager loginUser:credentials[GINIUserNameKey] password:credentials[GINIPasswordKey]] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                // Login error: This means that the stored user credentials are (no longer) valid. We need to create
                // a new user.
                if ([task.error isKindOfClass:[GINIError class]] && task.error.code == GINIErrorInvalidCredentials) {
                    [self removeStoredCredentials];
                    return [self getSession];
                }
                // Transparently pass-through all other errors.
                return [BFTask taskWithError:task.error];
            }
            return task;
        }];
    }] continueWithBlock:^id(BFTask *task) {
        _loginAttempts = 0;
        return task;
    }];
}

#pragma mark - Private methods
/**
 * Gets the user credentials from the keychain. Implemented as a `BFTask *`, so it's more convenient to use in the
 * asynchronous methods.
 *
 * @returns     A `BFTask *` that will resolve to a dictionary with the login credentials or to a `GINIError *` if there
 *              are no login credentials stored in the keychain.
 */
- (BFTask *)getUserCredentials {
    NSString *userName;
    NSString *password;
    [_credentialsStore fetchUserCredentials:&userName password:&password];
    if (userName && password) {
        return [BFTask taskWithResult:@{
            GINIUserNameKey: userName,
            GINIPasswordKey: password
        }];
    }
    return [BFTask taskWithError:[GINIError errorWithCode:GINIErrorNoCredentials userInfo:nil]];
}


/**
 * Creates a new user with a random email address and a random password and stores the user credentials in the
 * credentials store.
 */
- (BFTask *)createUser {
    // Creates a new "anonymous" user, where the email address is a random UUID@emailDomain and the password is
    // another random UUID.
    NSString *email = [NSString stringWithFormat:@"%@@%@", [[NSUUID UUID] UUIDString], _emailDomain];
    NSString *password = [[NSUUID UUID] UUIDString];
    return [[_userCenterManager createUserWithEmail:email password:password] continueWithSuccessBlock:^id(BFTask *task) {
        [_credentialsStore storeUserCredentials:email password:password];
        return nil;
    }];
}

- (void)removeStoredCredentials {
    [_credentialsStore removeCredentials];
}

@end
