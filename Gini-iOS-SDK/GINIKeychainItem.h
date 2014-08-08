/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * Store string values suitable for storing into the keychain.
 */
@interface GINIKeychainItem : NSObject

/**
 * Factory to create a new keychain item instance with a given identifier.
 *
 * @param identifier            The keychain item identifier.
 * @param value                 The keychain item's value. Optional.
 */
+ (instancetype)keychainItemWithIdentifier:(NSString *)identifier value:(NSString *)value;

/**
 * The designated initializer.
 *
 * @param identifier            The keychain item identifier.
 * @param value                 The keychain item's value. Optional.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier value:(NSString *)value;


/// The item identifier.
@property NSString *identifier;

/// The value for the corresponding identifier.
@property NSString *value;

@end
