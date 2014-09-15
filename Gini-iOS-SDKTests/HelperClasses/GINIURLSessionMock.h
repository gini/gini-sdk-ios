/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "GINIAPIManager.h"
#import "GINIURLSession.h"


/**
 * The `GINIURLSessionMock` implements the `<GINIURLSession>` protocol and is handy for tests that would require
 * HTTP communication. It provides methods to register mock responses for a given URL and also properties to check
 * the requests that were handled by this mock.
 */
@interface GINIURLSessionMock : NSObject <GINIURLSession>

/**
 * The last NSURLRequest that a method of the mock received.
 */
@property (readonly) NSURLRequest *lastRequest;

/**
 * The number of requests that the methods of the mock received.
 */
@property (readonly) NSUInteger requestCount;

/**
 * All requests that the methods of this mock received.
 */
@property (readonly) NSArray *requests;

/**
 * Registers a BFTask* that will be returned as the response when the given URL is requested by one of the methods of
 * the mock.
 *
 * @param response The BFTask* that will be stored and then returned if a request to the given `URL` is requested.
 * @param URL A string containing the URL.
 */
- (void)setResponse:(BFTask *)response forURL:(NSString *)URL;

/**
 * Shortcut method. Usually, the returned tasks of a `GINIURLSession` method resolve to a `GINIURLResponse` instance.
 * This shortcut method creates a `GINIURLResponse` instance, sets the given data as its data property, creates a new
 * `BFTask` of which the result is the previously created `GINIURLResponse` instance.
 *
 * @param data          The data that will be set as the data property of the created GINIURLResponse.
 * @param httpStatus    The HTTP status code that will be set as the status code of the NSURLResponse.
 * @param forURL        The URL of the request.
 */
- (void)createAndSetResponse:(id)data httpStatus:(NSInteger)httpStatus forURL:(NSString *)URL;

@end
