/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * The `GINIURLResponse` is a value object for the result of an HTTP request. It is used inside the Gini SDK to have
 * the possibility to pass the interpreted result of an HTTP communication (the `data` property) together with the
 * HTTP request's original meta data (like HTTP headers and so on).
 *
 * Usually you don't use this data object directly. It is only used by low level classes such as the `GINIURLSession`
 * class.
 */
@interface GINIURLResponse : NSObject

/**
 * Factory to create a new `GINIURLResponse` where the `data` property is nil.
 *
 * @param urlResponse       The `NSHTTPURLResponse` which will be the property `response`.
 */
+ (instancetype)urlResponseWithResponse:(NSHTTPURLResponse *)urlResponse;

/**
 * Factory to create a new `GINIURLResponse`.
 *
 * @param urlResponse       The`NSHTTPURLResponse` which will be the property `response`.
 * @param urlData           The interpreted data of the HTTP response. Will be set as the `data` property.
 */
+ (instancetype)urlResponseWithResponse:(NSHTTPURLResponse *)urlResponse data:(id)urlData;

/**
 * Initializer.
 *
 * @param urlResponse       The `NSHTTPURLResponse` which will be the property `response`.
 */
- (instancetype)initWithResponse:(NSHTTPURLResponse *)urlResponse;

/**
 * The designates initializer.
 *
 * @param urlResponse       The`NSHTTPURLResponse` which will be the property `response`.
 * @param responseData      The interpreted data of the HTTP response. Will be set as the `data` property.
 */
- (instancetype)initWithResponse:(NSHTTPURLResponse *)urlResponse data:(id)responseData;


/**
 * The interpreted data, based on the content type of the response. See the `GINIURLSession` documentation for more
 * detailed information about the of the content-type deserialization of the data.
 */
@property id data;

/**
 * The NSHTTPURLResponse (including the HTTP headers and other meta data).
 */
@property NSHTTPURLResponse *response;

@end
