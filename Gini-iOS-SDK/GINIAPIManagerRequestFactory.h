/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

@class BFTask;
@protocol GINISessionManager;

/**
 * The GINIAPIManagerRequestFactory creates NSURLRequests, usually for the `GINIAPIManager`. It is guaranteed that the
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
 * Returns a `BFTask*` that will resolve to a NSMutableURLRequest that is guaranteed to have the correct headers set
 * (including session headers) to do a request to the Gini API.
 *
 * @param url           The URL to which the request should be made.
 * @param httpMethod    The HTTP method which should be used to do the HTTP request, e.g. POST or GET or DELETE.
 */
- (BFTask *)asynchronousRequestUrl:(NSURL *)url withMethod:(NSString *)httpMethod;

@end


/**
 * The default implementation of the `GINIAPIManagerRequestFactory`. Used in the Gini SDK to create the requests for the
 * `GINIURLSession`.
 */
@interface GINIAPIManagerRequestFactory : NSObject <GINIAPIManagerRequestFactory>

/**
 * A factory to create an instance of the GINIAPIManagerRequestFactory.
 *
 * @param sessionManager        The session manager which is used to get the session.
 */
+ (instancetype)requestFactoryWithSessionManager:(id<GINISessionManager>)sessionManager;

/**
 * The designated initializer.
 *
 * @param sessionManager        The session manager which is used to get the session.
 */
- (instancetype)initWithSessionManager:(id <GINISessionManager>)sessionManager;

@end
