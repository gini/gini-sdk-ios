/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>

@class GINIURLResponse;

typedef NS_ENUM(NSInteger, GINIHTTPErrorCode) {
    GINIHTTPErrorURLSessionError
};

// TODO: edit and add comments

/**
 * The GINIHTTPError is an error with extra information and is used to represent the result of an HTTP request that
 * returned an HTTP status code which implies that the requested action did not succeed (e.g. 500, 403, 401 and so on).
 */
@interface GINIHTTPError : NSError

+ (instancetype)HTTPErrrorWithResponse:(GINIURLResponse *)response code:(NSInteger)code userInfo:(NSDictionary *)dict;


/**
 * The designated initializer.
 *
 * @param response      The `GINIURLResponse` object with the parsed HTTP response.
 */
- (instancetype)initWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;


/**
 * The `GINIURLResponse` object with the parsed HTTP response.
 */
@property (readonly) GINIURLResponse *response;

@end
