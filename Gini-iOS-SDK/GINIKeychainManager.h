/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>

@class GINIKeychainItem;


@interface GINIKeychainManager : NSObject

/**
 * Gets the item with the given identifier from the keychain.
 *
 * @param identifier    The keychain item identifier.
 */
- (GINIKeychainItem *)getItem:(NSString *)identifier;

/**
 * Stores the given item in the keychain.
 *
 * @param item          The `GINIKeychainItem to store.
 * @returns             Whether or not the item was stored successfully.
 */
- (BOOL)storeItem:(GINIKeychainItem *)item;

/**
 * Deletes the given item in the keychain.
 *
 * @param item          The `GINIKeychainItem` to delete.
 * @returns             Whether or not the item was deleted successfully.
 */
- (BOOL)deleteItem:(GINIKeychainItem *)item;

/**
 * Deletes all previously stored items from the keychain. Handy for tests.
 */
- (BOOL)deleteAllItems;
@end
