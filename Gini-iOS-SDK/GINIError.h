/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>


/** The default error domain for GINI Errors. */
extern NSString * const GINIErrorDomain;

/** The error code when the Gini iOS SDK can't get a new valid session. */
extern NSInteger const GINIErrorNoValidSession;


/**
 * The common error class to make errors which are from Gini (and which are somehow expected to happen) distinguishable
 * from other errors (e.g. network errors, argument errors, ...). All errors from Gini are an instance of this class or
 * an instance of a subclass of this class.
 *
 * Of course we could use "normal" `NSError` instances and make them distinguishable by the error domain, but we think
 * it is better to use the type system, especially since Objective-C has a nice type system with subclasses, since it is
 * always possible to upcast to NSError.
 */
@interface GINIError : NSError

/** @name Factories */

/**
 * Factory to create a new GINIError instance.
 *
 * @param code      The error code for the error.
 * @param userInfo  The userInfo for the error.
 */
+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;

@end
