/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINICredentialsStore.h"

@class GINIKeychainManager;


/**
 * The `GINIKeychainCredentialsStore` implements the <GINICredentialsStore> protocol by saving the user data into the
 * devices' keychain.
 */
@interface GINIKeychainCredentialsStore : NSObject <GINICredentialsStore>

/**
 * Factory to create a new `GINIKeychainCredentialsStore` instance.
 *
 * @param keychainManager       A `GINIKeychainManager` instance which is used to store the user data.
 */
+ (instancetype)credentialsStoreWithKeychainManager:(GINIKeychainManager *)keychainManager;

/**
 * The designated initializer.
 *
 * @param keychainManager       A `GINIKeychainManager` instance which is used to store the user data.
 */
- (instancetype)initWithKeychainManager:(GINIKeychainManager *)keychainManager;

@end
