/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINICredentialsStore.h"

@class GINIKeychainManager;


/**
 * A `GINIKeychainCredentialsStore` saves the refresh token in the Keychain of the device.
 */
@interface GINIKeychainCredentialsStore : NSObject <GINICredentialsStore>

/**
 * Factory to create a new `GINIKeychainCredentialsStore` instance.
 *
 * @param keychainManager       A `GINIKeychainManager` instance which is used to store the refresh token.
 */
+ (instancetype)credentialsStoreWithKeychainManager:(GINIKeychainManager *)keychainManager;

/**
 * The designated initializer.
 *
 * @param keychainManager       A `GINIKeychainManager` instance which is used to store the refresh token.
 */
- (instancetype)initWithKeychainManager:(GINIKeychainManager *)keychainManager;

@end
