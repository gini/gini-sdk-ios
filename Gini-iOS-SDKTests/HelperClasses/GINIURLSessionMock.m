/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIURLSession.h"
#import "GINIURLSessionMock.h"
#import "BFTask.h"
#import "GINIURLResponse.h"
#import "GINIHTTPError.h"


@implementation GINIURLSessionMock {
    NSMutableArray *_requests;
    NSMutableDictionary *_responses;
}

#pragma mark - Initializer
- (instancetype)init{
    self = [super init];
    if (self) {
        _requests = [NSMutableArray new];
        _responses = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - Properties
- (NSURLRequest *)lastRequest{
    return [_requests lastObject];
}

- (NSUInteger)requestCount{
    return [_requests count];
}

- (NSArray *)requests{
    return _requests;
}

#pragma mark - GINIURLSession protocol
// TODO: all three methods are obviously the same.
- (BFTask *)BFDataTaskWithRequest:(NSURLRequest *)request{
    [_requests addObject:request];
    return [self responseForURL:[request.URL absoluteString]];
}

- (BFTask *)BFDownloadTaskWithRequest:(NSURLRequest *)request {
    [_requests addObject:request];
    return [self responseForURL:[request.URL absoluteString]];
}

- (BFTask *)BFUploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)uploadData {
    [request setValue:uploadData forKey:@"HTTPBody"];
    [_requests addObject:request];
    return [self responseForURL:[request.URL absoluteString]];
}

#pragma mark - Mock helper methods
- (void)setResponse:(BFTask *)response forURL:(NSString *)URL {
    [_responses setValue:response forKey:URL];
}

- (void)createAndSetResponse:(id)data httpStatus:(NSInteger)httpStatus forURL:(NSString *)URL error:(BOOL)isError {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:URL]
                                                                     statusCode:httpStatus
                                                                    HTTPVersion:@"1.1"
                                                                   headerFields:nil];
    GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:httpURLResponse data:data];

    if (!isError) {
        [self setResponse:[BFTask taskWithResult:response] forURL:URL];
    } else {
        GINIHTTPError *error = [GINIHTTPError HTTPErrrorWithResponse:response];
        [self setResponse:[BFTask taskWithError:error] forURL:URL];
    }
}

- (BFTask *)responseForURL:(NSString *)URL{
    BFTask *response = _responses[URL];
    if (!response) {
        response = [BFTask taskWithResult:nil];
    }
    return response;
}

@end