/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>


@interface GINIUser : NSObject

@property NSString *userId;
@property NSString *userEmail;

/**
 * Factory to create a new `GINIUser` instance.
 *
 * @param email         The user's email address.
 * @param userId        The user's id.
 */
+ (instancetype)userWithEmail:(NSString *)email userId:(NSString *)userId;

/**
 * The designated initializer to create a `GINIUser`.
 *
 * @param email         The user's email address.
 * @param userId        The user's id.
 */
- (instancetype)initWithEmail:(NSString *)email userId:(NSString *)userId;

@end
