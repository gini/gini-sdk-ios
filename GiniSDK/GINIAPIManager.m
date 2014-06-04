#import <Bolts/Bolts.h>
#import <UIKit/UIKit.h>
#import "GINIAPIManager.h"
#import "GINIAPIManagerRequestFactory.h"
#import "GINIURLSession.h"
#import "GINIURLResponse.h"


/**
 * Returns the string that is part of the URL of an API request for the given image preview size.
 */
NSString* GINIpreviewSizeString(GiniApiPreviewSize previewSize) __attribute__((const)){
    static NSArray *availablePreviewSizes;
    if (!availablePreviewSizes) {
        availablePreviewSizes = @[@"750x900", @"1280x1810"];
    }
    return [availablePreviewSizes objectAtIndex:previewSize];
}


@implementation GINIAPIManager {
    /**
     * The base url to which the requests are made, e.g. https://api-sandbox.gini.net/ or https://api.gini.net. All
     * methods request the data from the API server with the given URL.
     */
    NSURL *_baseURL;

    /**
     * The request factory that creates NSURLRequests with the correct authorization headers set so it is possible to
     * request data from the API. See the <GINIAPIManagerRequestFactory> protocol for details.
     */
    id<GINIAPIManagerRequestFactory> _requestFactory;

    /**
     * The URL session that is used to do the request. Usually this is an instance of NSURLSession.
     */
    id<GINIURLSession> _urlSession;
}

#pragma mark - Initializer
- (instancetype)initWithURLSession:(id <GINIURLSession>)urlSession requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory baseURL:(NSURL *)baseURL {
    NSParameterAssert([requestFactory conformsToProtocol:@protocol(GINIAPIManagerRequestFactory)]);
    NSParameterAssert([baseURL isKindOfClass:[NSURL class]]);
    NSParameterAssert([urlSession conformsToProtocol:@protocol(GINIURLSession)]);

    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _requestFactory = requestFactory;
        _urlSession = urlSession;
    }
    return self;
}

#pragma mark - Public methods
- (BFTask *)getDocument:(NSString *)documentId{
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@", documentId]
                        relativeToURL:_baseURL];
    return [self getDocumentWithURL:url];
}

- (BFTask *)getDocumentWithURL:(NSURL *)location{
    return [[_requestFactory asynchronousRequestUrl:location withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *documentTask) {
            GINIURLResponse *response = documentTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)getPreviewForPage:(NSUInteger)pageNumber ofDocument:(NSString *)documentId withSize:(GiniApiPreviewSize)size {
    NSParameterAssert(pageNumber > 0);
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@/pages/%i/%@", documentId, pageNumber, GINIpreviewSizeString(size)]
                        relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        return [[_urlSession BFDownloadTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *downloadTask) {
            GINIURLResponse *response = downloadTask.result;
            NSURL *pathURL = response.data;
            NSData *imageData = [NSData dataWithContentsOfURL:pathURL];
            UIImage *image = [UIImage imageWithData:imageData];
            return image;
        }];
    }];
}

- (BFTask *)uploadDocumentWithData:(NSData *)documentImage contentType:(NSString *)contentType fileName:(NSString *)fileName {
    NSParameterAssert([documentImage isKindOfClass:[NSData class]]);
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([contentType isKindOfClass:[NSString class]]);

    NSString *urlString = [NSString stringWithFormat:@"documents/?filename=%@", [fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"POST"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        return [[_urlSession BFUploadTaskWithRequest:requestTask.result fromData:documentImage] continueWithSuccessBlock:^id(BFTask *uploadTask) {
            // The HTTP response has a Location header with the URL of the document.
            GINIURLResponse *response = uploadTask.result;
            NSString *location = [[response.response allHeaderFields] valueForKey:@"Location"];
            // Get the document.
            return [self getDocumentWithURL:[NSURL URLWithString:location]];
        }];
    }];
}

@end
