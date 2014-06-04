#import "GINIURLSession.h"
#import "GINIURLSessionMock.h"
#import "BFTask.h"


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
    [_requests addObject:request];
    return [self responseForURL:[request.URL absoluteString]];
}

#pragma mark - Mock helper methods
- (void)setResponse:(BFTask *)response forURL:(NSString *)URL {
    [_responses setValue:response forKey:URL];
}

- (BFTask *)responseForURL:(NSString *)URL{
    BFTask *response = [_responses objectForKey:URL];
    if (!response) {
        response = [BFTask taskWithResult:nil];
    }
    return response;
}

@end