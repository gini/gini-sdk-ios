/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>

@class GINIURLResponse;


/**
 * The GINIHTTPError is an error with extra information and is used to represent the result of an HTTP request that
 * returned an HTTP status code which implies that the requested action did not succeed (e.g. 500, 403, 401 and so on).
 */
@interface GINIHTTPError : NSError

+ (instancetype)HTTPErrrorWithResponse:(GINIURLResponse *)response;


/**
 * The designated initializer.
 *
 * @param response      The `GINIURLResponse` object with the parsed HTTP response.
 */
- (instancetype)initWithResponse:(GINIURLResponse *)response;


/**
 * The `GINIURLResponse` object with the parsed HTTP response.
 */
@property GINIURLResponse *response;

@end
