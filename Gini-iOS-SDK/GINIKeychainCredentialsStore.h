/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINICredentialsStore.h"

/**
 * A `GINIKeychainCredentialsStore` saves the token on the Keychain of the device.
 */
@interface GINIKeychainCredentialsStore : NSObject <GINICredentialsStore>

+ (instancetype)credentialsStoreWithIdentifier:(NSString *)identifier accessGroup:(NSString *)accessGroup;

/**
 * TODO
 */
- (instancetype)initWithIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup;

@end
