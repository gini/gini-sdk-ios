/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>


@interface GINIUser : NSObject

@property NSString *userId;
@property NSString *userEmail;

/** @name Factories */
/**
 * Factory to create a new `GINIUser` instance.
 *
 * @param email         The user's email address.
 * @param userId        The user's id.
 */
+ (instancetype)userWithEmail:(NSString *)email userId:(NSString *)userId;

/**
 * Factory to create a new `GINIUser` instance from a dictionary that is the result of a call to the Gini User Center
 * API. Returns nil if the data is incomplete or has a wrong structure, so you have to do nil-checks with the result of
 * calls to this factory.
 *
 * @param response      The response from the Gini API.
 */
+ (id)userFromAPIResponse:(NSDictionary *)response;


/** @name Initializer */
/**
 * The designated initializer to create a `GINIUser`.
 *
 * @param email         The user's email address.
 * @param userId        The user's id.
 */
- (instancetype)initWithEmail:(NSString *)email userId:(NSString *)userId;

@end
