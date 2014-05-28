/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIKeychainCredentialsStore.h"
#import "KeychainItemWrapper.h"

@interface GINIKeychainCredentialsStore () {
    KeychainItemWrapper *_keychain;
}
@end

@implementation GINIKeychainCredentialsStore

- (instancetype)initWithIdentifier:(NSString *)identifier accessGroup:(NSString *)accessGroup {
    self = [super init];
    if (self) {
        _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:accessGroup];
    }
    return self;
}

- (BOOL)storeRefreshToken:(NSString *)refreshToken {
    if (refreshToken) {
        [_keychain setObject:refreshToken forKey:(__bridge id)kSecValueData];
        return YES;
    }
    return NO;
}

- (NSString *)fetchRefreshToken {
    return [_keychain objectForKey:(__bridge id)kSecValueData];
}

@end
