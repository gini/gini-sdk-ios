/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>

@class BFTask;
@protocol GINISessionManager;

/**
 * The GINIAPIManagerRequestFactory creates NSURLRequests, usually for the GINIAPIManager. It is guaranteed that the
 * created requests have the correct HTTP headers set to make requests against the Gini API based on the user's current
 * session.
 *
 * Please notice that this request factory does not handle every detail of the request settings. It only guarantees
 * that the session headers are valid. All other headers and serialization of data has to come from the consumer of the
 * request.
 */
@protocol GINIAPIManagerRequestFactory <NSObject>

@required
/**
 * Returns a NSMutableURLRequest that is guaranteed to have the correct headers set (including session headers) to do
 * a request to the Gini API.
 *
 * Please notice that in some implementations, this method will block the thread in which it is executed! Because of
 * that, it is usually preferred to use the asynchronous implementation asynchronousRequestUrl:withMethod:andParameters.
 */
- (NSMutableURLRequest *)requestUrl:(NSURL *)url withMethod:(NSString *)httpMethod;

/**
 * Returns a BFTask that will resolve to a NSMutableURLRequest that is guaranteed to have the correct headers set
 * (including session headers) to do a request to the Gini API.
 *
 * This method is the asynchronous implementation of requestUrl:withMethod:andParameters.
 */
- (BFTask *)asynchronousRequestUrl:(NSURL *)url withMethod:(NSString *)httpMethod;

@end


@interface GINIAPIManagerRequestFactory : NSObject <GINIAPIManagerRequestFactory>

- (instancetype)initWithSessionManager:(id <GINISessionManager>)sessionManager;

@end