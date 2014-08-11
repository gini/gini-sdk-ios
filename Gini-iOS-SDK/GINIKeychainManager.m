/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIKeychainManager.h"
#import "GINIKeychainItem.h"


// TODO: Maybe provide some possibility to set the kSecAttrService key, since kSecClassGenericPasswords are identified by
//       the combination of kSecAttrAccount and kSecAttrService.

/**
 * Creates and returns a new dictionary which can be used as the query dictionary in a keychain search.
 */
NSMutableDictionary* GINIqueryDictionary() {
    NSMutableDictionary *queryDictionary = [NSMutableDictionary new];
    queryDictionary[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;
    // Only return one item.
    queryDictionary[(__bridge id) kSecMatchLimit] = (__bridge id) kSecMatchLimitOne;
    // Return the data, since we are interested in the value.
    queryDictionary[(__bridge id) kSecReturnData] = (__bridge id) kCFBooleanTrue;

    return queryDictionary;
}

/**
 * Creates a dictionary from a GINIKeyChainItem value object.
 */
NSMutableDictionary* GINIqueryDictionaryFromKeychainItem(GINIKeychainItem *item) {
    NSMutableDictionary *queryDictionary = [NSMutableDictionary new];

    if (item.value) {
        queryDictionary[(__bridge id) kSecValueData] = [item.value dataUsingEncoding:NSUTF8StringEncoding];
    }
    // The item should not be displayed.
    queryDictionary[(__bridge id) kSecAttrIsInvisible] = (__bridge id)kCFBooleanTrue;
    queryDictionary[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;
    queryDictionary[(__bridge id) kSecAttrAccount] = item.identifier;

    return queryDictionary;
}


@implementation GINIKeychainManager

#pragma mark - Public methods
- (GINIKeychainItem *)getItem:(NSString *)identifier {
    NSParameterAssert([identifier isKindOfClass:[NSString class]]);

    // Build the query dictionary.
    NSMutableDictionary *queryDictionary = GINIqueryDictionary();
    queryDictionary[(__bridge id) kSecAttrAccount] = identifier;

    // And query the keychain.
    CFDataRef storedData;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&storedData) != noErr) {
        return nil;
    }
    NSData *password = (__bridge_transfer NSData *) storedData;
    NSString *value = [[NSString alloc] initWithData:password encoding:NSUTF8StringEncoding];
    return [GINIKeychainItem keychainItemWithIdentifier:identifier value:value];
}

- (BOOL)storeItem:(GINIKeychainItem *)item {
    NSParameterAssert([item isKindOfClass:[GINIKeychainItem class]]);
    NSParameterAssert(item.value);

    NSMutableDictionary *queryDictionary = GINIqueryDictionaryFromKeychainItem(item);
    // If the item already exists, it needs to be updated, not added.
    if ([self getItem:item.identifier] != nil) {
        NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionaryWithDictionary:queryDictionary];
        [updateDictionary removeObjectForKey:(__bridge id)kSecClass];
        return SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary) == noErr;
    }

    return SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL) == noErr;
}

- (BOOL)deleteItem:(GINIKeychainItem *)item {
    NSParameterAssert([item isKindOfClass:[GINIKeychainItem class]]);

    NSMutableDictionary *queryDictionary = GINIqueryDictionaryFromKeychainItem(item);
    return SecItemDelete((__bridge CFDictionaryRef)queryDictionary) == noErr;
}

- (BOOL)deleteAllItems {
    // Query dictionary that should find all stored items in the keychain.
    NSDictionary *dictionary = @{
            (__bridge id) kSecReturnRef: (__bridge id) kCFBooleanTrue,
            (__bridge id) kSecReturnAttributes: (__bridge id) kCFBooleanTrue,
            (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
            (__bridge id) kSecMatchLimit: (__bridge id) kSecMatchLimitAll
    };
    // Query the keychain.
    CFArrayRef storedData;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)dictionary, (CFTypeRef *)&storedData) != noErr) {
        return NO;
    }
    // And delete every found item.
    BOOL successful = YES;
    NSArray *items = (__bridge_transfer NSArray *)storedData;
    for (NSUInteger index = 0; index < [items count]; index++) {
        if (SecItemDelete((__bridge CFDictionaryRef) items[index]) != noErr) {
            successful = NO;
        }
    }
    return successful;
}
@end
