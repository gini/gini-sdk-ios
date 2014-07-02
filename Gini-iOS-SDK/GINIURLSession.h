/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>

@class BFTask;

/**
 * The GINIURLSession is a small wrapper around Apple's NSURLSession. It wraps the Apple's HTTP tasks into BFTask* so
 * it can easily be used inside Managers. It also provides some higher level error handling than the default methods.
 */
@protocol GINIURLSession <NSObject>

@required
/**
 * This method wraps a BFTask around Apple's dataTaskWithRequest:. The BFTask* resolves to a `GINIURLResponse` object
 * of which the `data` property is the result of some advanced handling of the result of the HTTP communication
 * (based on the Content-Type HTTP header of the response):
 *
 *   - If the response has JSON contents, the data property is either a NSDictionary* or a NSArray* (or NSString* and
 *     NSNumber* if the response are "JSON fragments").
 *   - If the response has text contents, the data property is a NSString* with the contents of the HTTP body.
 *   - If the response has image contents, the data property is an UIImage*.
 *
 * In all other cases, the data property is a NSData* object containing the response's HTTP body.
 * If there have benn errors in the HTTP communication or in the response deserialization (e.g. due to an invalid JSON
 * response), the error property of the task is set accordingly.
 *
 * @param request   The HTTP request that should be done to get the data.
 */
- (BFTask *)BFDataTaskWithRequest:(NSURLRequest *)request;

/**
 * This method wraps a BFTask around Apple's downloadTaskWithRequest: method. The BFTask* resolves to a
 * `GINIURLResponse` object where the `data` property is an NSURL* representing the file system path of the downloaded
 * file.
 *
 * @param request   The HTTP request that should be done to download the data.
 */
- (BFTask *)BFDownloadTaskWithRequest:(NSURLRequest *)request;

/**
 * This method wraps a BFTask around Apple's `uploadTaskWithRequest:fromData` method. The BFTask* resolves to a
 * `GINIURLResponse` object where the data property is the interpreted result of the HTTP communication (based on the
 * Content-Type HTTP header of the response):
 *
 *   - If the response has JSON contents, the BFTask* resolves to either a NSDictionary* or a NSArray* (or NSString* and
 *     NSNumber* if the response are "JSON fragments").
 *   - If the response has text contents, the BFTask* resolves to a NSString* with the contents of the HTTP body.
 *   - If the response has image contents, the BFTask* resolves to a UIImage*.
 *
 * In all other cases, the task resolves to a NSData* object containing the response's HTTP body.
 * If there are errors in the HTTP communication or in the response deserialization (e.g. due to an invalid JSON
 * response), the error property of the task is set accordingly.
 *
 * @param request       The HTTP request that should be done to upload the data.
 * @param uploadData    The data that should be uploaded.
 */
- (BFTask *)BFUploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)uploadData;
@end


/**
 * Gini's default implementation of the <GINIURLSession> protocol.
 */
@interface GINIURLSession : NSObject <GINIURLSession>

/**
 * Factory to create a new GINIURLSession instance.
 *
 * @param urlSession    An instance of Apple's `NSURLSession` class that is used by the GINIURLSession to do the
 *                      HTTP requests.
 */
+ (instancetype)urlSessionWithNSURLSession:(NSURLSession *)urlSession;

/**
 * Factory to create a new GINIURLSession instance. The created instance uses an instance of Apple's `NSURLSession` with
 * Apple's default configuration to do the HTTP requests.
 */
+ (instancetype)urlSession;

/**
 * The designated initializer.
 *
 * @param urlSession An instance of Apple's `NSURLSession` class that is used to do the HTTP requests.
 */
- (instancetype)initWithNSURLSession:(NSURLSession *)urlSession;

@end
