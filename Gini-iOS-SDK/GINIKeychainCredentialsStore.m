/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIKeychainCredentialsStore.h"
#import "GINIKeychainManager.h"
#import "GINIKeychainItem.h"


/// The identifier of the keychain item for the refresh token.
NSString *const GINIrefreshTokenKey = @"refreshToken";


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

    GINIKeychainItem *refreshTokenItem = [GINIKeychainItem keychainItemWithIdentifier:GINIrefreshTokenKey value:refreshToken];
    return [_keychainManager storeItem:refreshTokenItem];
}

- (NSString *)fetchRefreshToken {
    return [[_keychainManager getItem:GINIrefreshTokenKey] value];
}

@end
