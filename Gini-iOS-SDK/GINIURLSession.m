/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/Bolts.h>
#import <UIKit/UIImage.h>
#import "GINIURLSession.h"
#import "GINIURLResponse.h"
#import "GINIHTTPError.h"


#define GINI_DEFAULT_ENCODING NSUTF8StringEncoding


/**
 * Helper function that determines if a content type is a valid JSON content type.
 */
BOOL GINIIsJSONContent(NSString *contentType) {
    static NSSet *knownContentTypes;
    if (!knownContentTypes) {
        knownContentTypes = [NSSet setWithObjects:@"application/json", @"application/vnd.gini.v1+json", @"application/vnd.gini.incubator+json", nil];
    }
    NSArray *contentTypeComponents = [contentType componentsSeparatedByString:@";"];
    return ([knownContentTypes containsObject:contentTypeComponents.firstObject]);
}

/**
* Helper function that determines if a content type is a valid XML content type.
*/
BOOL GINIIsXMLContent(NSString *contentType) {
    static NSSet *knownContentTypes;
    if (!knownContentTypes) {
        knownContentTypes = [NSSet setWithObjects:@"application/xml", @"application/vnd.gini.v1+xml", @"application/vnd.gini.incubator+xml", nil];
    }
    NSArray *contentTypeComponents = [contentType componentsSeparatedByString:@";"];
    return ([knownContentTypes containsObject:contentTypeComponents.firstObject]);
}

/**
 * Helper function that determines if a content type is a valid image content type.
 */
BOOL GINIIsImageContent(NSString *contentType) {
    NSArray *contentTypeComponents = [contentType componentsSeparatedByString:@";"];
    return [[[contentTypeComponents firstObject] substringToIndex:6] isEqualToString:@"image/"];
}

/**
 * Helper function that determines if a content type is a valid text content type.
 */
BOOL GINIIsTextContent(NSString *contentType) {
    NSArray *contentTypeComponents = [contentType componentsSeparatedByString:@";"];
    return [[[contentTypeComponents firstObject] substringToIndex:5] isEqualToString:@"text/"];
}

/**
* Checks if there has been an error in the HTTP communication and if the HTTP status code is an error.
*/
BOOL GINICheckHTTPError(NSURLResponse *response) {

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode < 200 || httpResponse.statusCode > 304) {
            return YES;
        }
    }
    return NO;
}


UIImage *GINIDeserializeImageResponse(NSData *rawData) {
    return [UIImage imageWithData:rawData];
}

id GINIDeserializeJSONResponse(NSData *rawData, NSError **error) {
    return [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingAllowFragments error:error];
}


GINIURLResponse* GINIDeserializeResponse(NSURLResponse *response, NSData *rawData, NSError **error) {
    GINIURLResponse *httpResult = [GINIURLResponse new];

    // Usually the response object is actually an instance of the sub class NSHTTPURLResponse, but we check to be
    // sure instead of doing a simple downcast.
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResult.response = (NSHTTPURLResponse *) response;
        // Fortunately, the Gini API uses correct content types.
        NSString *contentType = [httpResult.response allHeaderFields][@"Content-Type"];
        if (GINIIsJSONContent(contentType) && [rawData length] > 0) {
            httpResult.data = GINIDeserializeJSONResponse(rawData, error);
        } else if (GINIIsImageContent(contentType)) {
            httpResult.data = GINIDeserializeImageResponse(rawData);
        } else if (GINIIsTextContent(contentType) || GINIIsXMLContent(contentType)) {
            httpResult.data = [[NSString alloc] initWithData:rawData encoding:GINI_DEFAULT_ENCODING];
        }
    }

    // If the response could not be deserialized, just use the raw data.
    if (!httpResult.data) {
        httpResult.data = rawData;
    }

    // If there was an error during deserialization set the error.
    if (error) {
        httpResult.parseError = *error;
    }

    return httpResult;
}

void GINIParseResponse(NSData *data, NSURLResponse *response, NSError *error, BFTaskCompletionSource *completionSource) {
    // If there has been an error in the HTTP communication, transparently pass-through the error.
    if (error) {
        return [completionSource setError:error];
    }
    // Otherwise try to use the response.
    GINIURLResponse *parsedResponse = GINIDeserializeResponse(response, data, &error);
    if (GINICheckHTTPError(response)) {
        [completionSource setError:[GINIHTTPError HTTPErrrorWithResponse:parsedResponse]];
    } else {
        [completionSource setResult:parsedResponse];
    }
}


@implementation GINIURLSession {
    NSURLSession *_nsURLSession;
}

+ (instancetype)urlSessionWithNSURLSession:(NSURLSession *)urlSession {
    return [[GINIURLSession alloc] initWithNSURLSession:urlSession];
}

+ (instancetype)urlSession {
    return [GINIURLSession urlSessionWithNSURLSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]];
}

- (instancetype)initWithNSURLSession:(NSURLSession *)urlSession {
    self = [super init];
    if (self) {
        _nsURLSession = urlSession;
    }
    return self;
}


#pragma mark - Public Methods
- (BFTask *)BFDataTaskWithRequest:(NSURLRequest *)request{
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSURLSessionDataTask *task = [_nsURLSession dataTaskWithRequest:request completionHandler:^void(NSData *data, NSURLResponse *response, NSError *error) {
        GINIParseResponse(data, response, error, completionSource);
    }];
    [task resume];
    return completionSource.task;
}

- (BFTask *)BFDownloadTaskWithRequest:(NSURLRequest *)request {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSURLSessionDownloadTask *downloadTask = [_nsURLSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        // If there has been an error in the HTTP communication, transparently pass-through the error.
        if (error) {
            return [completionSource setError:error];
        }
        GINIURLResponse *parsedResponse = [GINIURLResponse urlResponseWithResponse:(NSHTTPURLResponse *)response data:location];
        if (GINICheckHTTPError(response)) {
            [completionSource setError:[GINIHTTPError HTTPErrrorWithResponse:parsedResponse]];
        } else {
            [completionSource setResult:parsedResponse]; // TODO: downcast
        }
    }];
    [downloadTask resume];
    return completionSource.task;
}

- (BFTask *)BFUploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)uploadData {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSURLSessionUploadTask *uploadTask = [_nsURLSession uploadTaskWithRequest:request fromData:uploadData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        GINIParseResponse(data, response, error, completionSource);
    }];
    [uploadTask resume];
    return completionSource.task;
}

@end
