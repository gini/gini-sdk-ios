/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>

@class GINIURLResponse;

typedef NS_ENUM(NSInteger, GINIHTTPErrorCode) {
    /** The error code when the HTTP request fails. */
    GINIHTTPErrorRequestError
};

/**
 * The GINIHTTPError is an error with extra information and is used to represent the result of an HTTP request that
 * returned an HTTP status code which implies that the requested action did not succeed (e.g. 500, 403, 401 and so on).
 */
@interface GINIHTTPError : NSError

/** @name Factories */

/**
 * Factory to create a new GINIHTTPError instance.
 *
 * @param response  The response for the error.
 * @param code      The error code for the error.
 * @param userInfo  The userInfo for the error.
 */
+ (instancetype)HTTPErrrorWithResponse:(GINIURLResponse *)response code:(NSInteger)code userInfo:(NSDictionary *)dict;

/**
 * The `GINIURLResponse` object with the parsed HTTP response.
 */
@property (readonly) GINIURLResponse *response;

@end
