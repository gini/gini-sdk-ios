/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIKeychainCredentialsStore.h"
#import "GINIKeychainManager.h"
#import "GINIKeychainItem.h"


/// The identifier of the keychain item for the refresh token.
NSString *const GINIRefreshTokenKey = @"refreshToken";
/// The identifier of the keychain item for the username.
NSString *const GINIUserNameKey = @"userName";
/// The identifier of the keychain item for the password.
NSString *const GINIPasswordKey = @"hrmPassword";


@implementation GINIKeychainCredentialsStore {
    GINIKeychainManager *_keychainManager;
}

+ (instancetype)credentialsStoreWithKeychainManager:(GINIKeychainManager *)keychainManager {
    return [[GINIKeychainCredentialsStore alloc] initWithKeychainManager:keychainManager];
}

- (instancetype)initWithKeychainManager:(GINIKeychainManager *)keychainManager {
    NSParameterAssert([keychainManager isKindOfClass:[GINIKeychainManager class]]);

    if (self = [super init]) {
        _keychainManager = keychainManager;
    }
    return self;
}


- (BOOL)storeRefreshToken:(NSString *)refreshToken {
    NSParameterAssert([refreshToken isKindOfClass:[NSString class]]);

    GINIKeychainItem *refreshTokenItem = [GINIKeychainItem keychainItemWithIdentifier:GINIRefreshTokenKey value:refreshToken];
    return [_keychainManager storeItem:refreshTokenItem];
}

- (NSString *)fetchRefreshToken {
    return [[_keychainManager getItem:GINIRefreshTokenKey] value];
}

- (BOOL)storeUserCredentials:(NSString *)userName password:(NSString *)password {
    NSParameterAssert([userName isKindOfClass:[NSString class]]);
    NSParameterAssert([password isKindOfClass:[NSString class]]);

    GINIKeychainItem *userItem = [GINIKeychainItem keychainItemWithIdentifier:GINIUserNameKey value:userName];
    GINIKeychainItem *passwordItem = [GINIKeychainItem keychainItemWithIdentifier:GINIPasswordKey value:password];

    return [_keychainManager storeItem:userItem] && [_keychainManager storeItem:passwordItem];
}

- (void)fetchUserCredentials:(NSString **)userName password:(NSString **)password {
    *userName = [[_keychainManager getItem:GINIUserNameKey] value];
    *password = [[_keychainManager getItem:GINIPasswordKey] value];
}


@end
