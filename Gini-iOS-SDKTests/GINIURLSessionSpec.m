/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import "GINIURLSession.h"
#import "BFTask.h"
#import "GINIURLResponse.h"


// Make the helper functions visible for the tests.
BOOL GINIIsJSONContent(NSString *contentType);
BOOL GINIIsImageContent(NSString *contentType);
BOOL GINIIsTextContent(NSString *contentType);


#pragma mark - GININSURLSessionDataTaskMock
/**
 * This is a mock class for a `NSURLSession`. It is used by the `GININSURLSessionDownloadTaskMock` (see implementation
 * below).
 *
 * All it does is to call it's completion handler and passes its properties as arguments to the completion handler, when
 * its `resume` method is called.
 */
@class GININSURLSessionMock;

@interface GININSURLSessionDataTaskMock : NSObject
@property NSData *data;
@property NSURLResponse *response;
@property NSError *error;

- (instancetype)initWithCompletionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler;
@end

@implementation GININSURLSessionDataTaskMock{
    void (^_completionHandler)(NSData *, NSURLResponse *, NSError *);
}

- (instancetype)initWithCompletionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    self = [super init];
    if (self) {
        _completionHandler = completionHandler;
    }
    return self;
}

- (void)resume{
    _completionHandler(self.data, self.response, self.error);
}

@end



#pragma mark - GININSURLSessionDownloadTaskMock
@interface GININSURLSessionDownloadTaskMock : NSObject
@property NSURL *location;
@property NSURLResponse *response;
@property NSError *error;

- (instancetype)initWithCompletionHandler:(void (^)(NSURL *, NSURLResponse *, NSError *))completionHandler;
@end

@implementation GININSURLSessionDownloadTaskMock{
    void (^_completionHandler)(NSURL *, NSURLResponse *, NSError *);
}

- (instancetype)initWithCompletionHandler:(void (^)(NSURL *, NSURLResponse *, NSError *))completionHandler {
    self = [super init];
    if (self) {
        _completionHandler = completionHandler;
    }
    return self;
}

- (void)resume{
    _completionHandler(self.location, self.response, self.error);
}

@end



#pragma mark - GININSURLSessionMock
/**
 * The `GINIURLSession` uses a `NSURLSession` to do the HTTP requests. This mock is used in the tests to have a
 * NSURLSession-like object that returns pre-defined reponses.
 *
 * When a
 */
@interface GININSURLSessionMock : NSObject

@property (readonly) NSMutableArray *dataTasks;
@property (readonly) NSMutableArray *downloadTasks;
@property NSURL *location;
@property NSError *error;
@property NSData *data;
@property NSURLResponse *response;

- (GININSURLSessionDataTaskMock *)dataTaskWithRequest:(NSURLRequest *)request
                                    completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler;

- (GININSURLSessionDownloadTaskMock *)downloadTaskWithRequest:(NSURLRequest *)request
                                            completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler;

- (GININSURLSessionDataTaskMock *)uploadTaskWithRequest:(NSURLRequest *)request
                                               fromData:(NSData *)data
                                      completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler;

@end

@implementation GININSURLSessionMock
@synthesize dataTasks, error, data, response;

- (GININSURLSessionDataTaskMock *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    // Create the new mock for the data task.. The consumer of the result value of this method usually calls the
    // `resume` method of the mock which does the actual magic.
    GININSURLSessionDataTaskMock *dataTask = [[GININSURLSessionDataTaskMock alloc] initWithCompletionHandler:completionHandler];
    dataTask.data = self.data;
    dataTask.error = self.error;
    dataTask.response = self.response;
    [self.dataTasks addObject:dataTask];

    return dataTask;
}

- (id)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL *, NSURLResponse *, NSError *))completionHandler {
    GININSURLSessionDownloadTaskMock *downloadTask = [[GININSURLSessionDownloadTaskMock alloc] initWithCompletionHandler:completionHandler];
    downloadTask.location = self.location;
    downloadTask.error = self.error;
    downloadTask.response = self.response;
    [self.downloadTasks addObject:downloadTask];

    return downloadTask;
}

- (GININSURLSessionDataTaskMock *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data1 completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    // Create the new mock for the data task.. The consumer of the result value of this method usually calls the
    // `resume` method of the mock which does the actual magic.
    GININSURLSessionDataTaskMock *dataTask = [[GININSURLSessionDataTaskMock alloc] initWithCompletionHandler:completionHandler];
    dataTask.data = self.data;
    dataTask.error = self.error;
    dataTask.response = self.response;
    [self.dataTasks addObject:dataTask];

    return dataTask;
}

@end


#pragma mark - actual Spec
SPEC_BEGIN(GINIURLSessionSpec)

    describe(@"The GINIURLSession", ^{

        __block GININSURLSessionMock *nsURLSessionMock;
        __block GINIURLSession *giniURLSession;
        __block NSURLRequest *request;

        beforeEach(^{
            nsURLSessionMock = [GININSURLSessionMock new];
            giniURLSession = [[GINIURLSession alloc] initWithNSURLSession:(NSURLSession *)nsURLSessionMock]; // TODO (type cast)
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.gini.net"]];
        });

        context(@"Helper functions", ^{
            it(@"should correctly detect JSON content types", ^{
                [[theValue(GINIIsJSONContent(@"application/json")) should] beYes];
                [[theValue(GINIIsJSONContent(@"application/json; charset=utf8")) should] beYes];
                [[theValue(GINIIsJSONContent(@"text/html")) should] beNo];
                [[theValue(GINIIsJSONContent(@"application/customType")) should] beNo];
            });

            it(@"should correctly detect image content types", ^{
                [[theValue(GINIIsImageContent(@"image/jpeg")) should] beYes];
                [[theValue(GINIIsImageContent(@"image/png")) should] beYes];
                [[theValue(GINIIsImageContent(@"application/json")) should] beNo];
                [[theValue(GINIIsImageContent(@"application/json; charset=UTF-8")) should] beNo];
            });

            it(@"should correctly detect text content types", ^{
                [[theValue(GINIIsTextContent(@"text/html")) should] beYes];
                [[theValue(GINIIsTextContent(@"text/html;charset=UTF8")) should] beYes];
            });
        });

        context(@"The BFDataTaskWithRequest: method", ^{
            it(@"should return a BFTask", ^{
                [[[giniURLSession BFDataTaskWithRequest:request] should] beKindOfClass:[BFTask class]];
            });

            it(@"should pass-through errors in the HTTP communication", ^{
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
                nsURLSessionMock.error = error;
                BFTask *task = [giniURLSession BFDataTaskWithRequest:request];
                [[task.error should] equal:error];
                [[task.result should] beNil];
            });

            it(@"should resolve to an error if the NSURLSession has an error", ^{
                NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://api.gini.net"]
                                                                      statusCode:403
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:nil];
                nsURLSessionMock.response = response;
                nsURLSessionMock.error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil];
                BFTask *task = [giniURLSession BFDataTaskWithRequest:request];
                [[task.error should] beKindOfClass:[NSError class]];
                [[task.result should] beNil];
            });

            it(@"should return a JSON object if the content type is JSON", ^{
                NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://api.gini.net"]
                                                                      statusCode:200
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:@{
                                                                            @"Content-Type": @"application/json"
                                                                    }];
                nsURLSessionMock.response = response;
                nsURLSessionMock.data = [@"{\"foo\": \"bar\"}" dataUsingEncoding:NSUTF8StringEncoding];
                BFTask *task = [giniURLSession BFDataTaskWithRequest:request];
                [[theValue(task.isCompleted) should] beYes];
                [[task.error should] beNil];
                [[task.result should] beKindOfClass:[GINIURLResponse class]];
                GINIURLResponse *taskResponse = task.result;
                [[taskResponse.data should] equal:@{@"foo": @"bar"}];
            });

            it(@"should pass-through the error if the JSON deserialization fails", ^{
                NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://api.gini.net"]
                                                                      statusCode:200
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:@{
                                                                            @"Content-Type": @"application/json"
                                                                    }];
                nsURLSessionMock.response = response;
                nsURLSessionMock.data = [@"\"foo\": \"bar\"}" dataUsingEncoding:NSUTF8StringEncoding]; // Note the missing { at the beginning
                BFTask *task = [giniURLSession BFDataTaskWithRequest:request];
                [[theValue(task.isCompleted) should] beYes];
                [[task.result should] beNil];
                [[task.error should] beNonNil];
            });

            it(@"should return a string if the content is text content", ^{
                NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://api.gini.net"]
                                                                      statusCode:200
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:@{
                                                                            @"Content-Type": @"text/html"
                                                                    }];
                nsURLSessionMock.response = response;
                nsURLSessionMock.data = [@"<html></html>" dataUsingEncoding:NSUTF8StringEncoding];
                BFTask *task = [giniURLSession BFDataTaskWithRequest:request];
                [[theValue(task.isCompleted) should] beYes];
                [[task.result should] beKindOfClass:[GINIURLResponse class]];
                [[task.error should] beNil];
                GINIURLResponse *httpResponse = task.result;
                [[httpResponse.data should] equal:@"<html></html>"];
            });

        });


        describe(@"The BFDownloadTaskWithRequest:request method", ^{
            it(@"should return a BFTask*", ^{
                [[[giniURLSession BFDownloadTaskWithRequest:request] should] beKindOfClass:[BFTask class]];
            });

            it(@"should resolve to a GINIURLResponse", ^{
                BFTask *downloadTask = [giniURLSession BFDownloadTaskWithRequest:request];
                [[theValue(downloadTask.isCompleted) should] beYes];
                [[downloadTask.result should] beKindOfClass:[GINIURLResponse class]];
                [[downloadTask.error should] beNil];
            });

            it(@"should return the correct URL", ^{
                NSURL *testLocation = [NSURL URLWithString:@"https://api.gini.net/documents/1234-567-890"];
                nsURLSessionMock.location = testLocation;
                NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://api.gini.net/documents/"]
                                                                      statusCode:204
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:@{
                                                                            @"Content-Type": @"text/json"
                                                                    }];
                nsURLSessionMock.response = response;

                BFTask *downloadTask = [giniURLSession BFDownloadTaskWithRequest:request];
                [[theValue(downloadTask.isCompleted) should] beYes];
                GINIURLResponse *httpResponse = downloadTask.result;
                [[httpResponse.data should] beKindOfClass:[NSURL class]];
                [[httpResponse.data should] equal:testLocation];
            });
        });

        describe(@"The BFUploadTaskWithRequest:request:fromData method", ^{
            it(@"should return a BFTask", ^{
                [[[giniURLSession BFUploadTaskWithRequest:request fromData:[NSData new]] should] beKindOfClass:[BFTask class]];
            });

            it(@"should resolve to a GINIURLResponse", ^{
                BFTask *uploadTask = [giniURLSession BFUploadTaskWithRequest:request fromData:[NSData new]];
                [[theValue(uploadTask.isCompleted) should] beYes];
                [[uploadTask.result should] beKindOfClass:[GINIURLResponse class]];
                [[uploadTask.error should] beNil];
            });
        });

        // TODO: more tests
    });

SPEC_END
