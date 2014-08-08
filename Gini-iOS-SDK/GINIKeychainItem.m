/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIKeychainItem.h"

@implementation GINIKeychainItem

#pragma mark - Factories

+ (instancetype)keychainItemWithIdentifier:(NSString *)identifier value:(NSString *)value {
    NSParameterAssert([identifier isKindOfClass:[NSString class]]);

    return [[GINIKeychainItem alloc] initWithIdentifier:identifier value:value];
}

#pragma mark - Initializer

- (instancetype)initWithIdentifier:(NSString *)identifier value:(NSString *)value {
    if (self = [super init]) {
        _identifier = identifier;
        _value = value;
    }
    return self;
}

@end
