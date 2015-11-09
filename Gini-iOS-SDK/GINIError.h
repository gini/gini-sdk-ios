/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>


/** The default error domain for GINI Errors. */
extern NSString * const GINIErrorDomain;

extern NSString *const GINIErrorKeyCause;

typedef NS_ENUM(NSInteger, GINIErrorCode) {
    /** The error code when the Gini iOS SDK can't get a new valid session without user interaction. */
    GINIErrorNoValidSession,

    GINIErrorNotAuthorized,

    GINIErrorInsufficientRights,

    /**
     * The error code when the Resource is not found, e.g. when you try to access a non-existing document (wrong ID) or
     * if you try to access an extraction which does not exist for the document.
     */
    GINIErrorResourceNotFound,

    GINIErrorNoCredentials,

    GINIErrorInvalidCredentials,

    /** The error code when the creation of a new user was not successful. */
    GINIErrorUserCreationError,

    /** The error code when the login of an existing user failed. */
    GINIErrorLoginError
};


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

/**
 * Factory to create a new GINIError instance. Usually to collect low-level errors into a high-level error.
 *
 * @param code      The error code for the error.
 * @param cause     The underlying (low-level) error which caused the error.
 * @param userInfo  The userInfo for the error.
 */
+ (instancetype)errorWithCode:(NSInteger)code cause:(NSError *)cause userInfo:(NSDictionary *)dict;

/**
 * The designated initializer.
 *
 * @param code      The error code for the error.
 * @param cause     The underlying (low-level) error which caused the error.
 * @param userInfo  The userInfo for the error.
 */
- (instancetype)initWithCode:(NSInteger)code cause:(NSError *)cause userInfo:(NSDictionary *)dict;


/** The original error which caused the error. */
@property (readonly) NSError *cause;

@end
