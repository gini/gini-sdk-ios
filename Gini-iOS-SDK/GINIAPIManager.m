/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/Bolts.h>
#import <UIKit/UIKit.h>
#import "GINIAPIManager.h"
#import "GINIAPIManagerRequestFactory.h"
#import "GINIURLSession.h"
#import "GINIURLResponse.h"
#import "NSString+GINIAdditions.h"

/**
 * Returns the string that is part of the URL of an API request for the given image preview size.
 */
NSString *GINIPreviewSizeString(GiniApiPreviewSize previewSize) {
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
+ (instancetype)apiManagerWithURLSession:(id <GINIURLSession>)urlSession requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory baseURL:(NSURL *)baseURL {
    return [[GINIAPIManager alloc] initWithURLSession:urlSession requestFactory:requestFactory baseURL:baseURL];
}

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

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@/pages/%lu/%@", documentId, (unsigned long)pageNumber, GINIPreviewSizeString(size)]
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

- (BFTask *)getPagesForDocument:(NSString *)documentId {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@/pages", documentId] relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *pagesTask) {
            GINIURLResponse *response = pagesTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)getLayoutForDocument:(NSString *)documentId {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@/layout", documentId] relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *layoutTask) {
            GINIURLResponse *response = layoutTask.result;
            return response.data;
        }];
    }];
}


- (BFTask *)uploadDocumentWithData:(NSData *)documentData contentType:(NSString *)contentType fileName:(NSString *)fileName docType:(NSString *)docType {
    NSParameterAssert([documentData isKindOfClass:[NSData class]]);
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([contentType isKindOfClass:[NSString class]]);

    NSString *urlString = [NSString stringWithFormat:@"documents/?filename=%@", stringByEscapingString(fileName)];
    if (docType) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&doctype=%@", stringByEscapingString(docType)]];
    }

    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"POST"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        return [[_urlSession BFUploadTaskWithRequest:requestTask.result fromData:documentData] continueWithSuccessBlock:^id(BFTask *uploadTask) {
            // The HTTP response has a Location header with the URL of the document.
            GINIURLResponse *response = uploadTask.result;
            NSString *location = [[response.response allHeaderFields] valueForKey:@"Location"];
            // Get the document.
            return [self getDocumentWithURL:[NSURL URLWithString:location]];
        }];
    }];
}

- (BFTask *)deleteDocument:(NSString *)documentId {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@", documentId] relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"DELETE"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *documentTask) {
            GINIURLResponse *response = documentTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)getDocumentsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset {
    NSParameterAssert(limit > 0);
    NSParameterAssert(offset >= 0);
    
    NSString *urlString = [NSString stringWithFormat:@"documents?limit=%lu&offset=%lu", (unsigned long)limit, (unsigned long)offset];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *documentsTask) {
            GINIURLResponse *response = documentsTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)getExtractionsForDocument:(NSString *)documentId {
    return [self getExtractionsForDocument:documentId withHeader:@"application/vnd.gini.v1+json"];
}

- (BFTask *)getIncubatorExtractionsForDocument:(NSString *)documentId {
    return [self getExtractionsForDocument:documentId withHeader:@"application/vnd.gini.incubator+json"];
}

- (BFTask *)getExtractionsForDocument:(NSString *)documentId withHeader:(NSString *)header{
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    NSString *urlString = [NSString stringWithFormat:@"documents/%@/extractions", documentId];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:header forHTTPHeaderField:@"Accept"];
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *extractionsTask) {
            GINIURLResponse *response = extractionsTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)submitFeedbackForDocument:(NSString *)documentId label:(NSString *)label value:(NSString *)value boundingBox:(NSDictionary *)boundingBox {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    NSParameterAssert([label isKindOfClass:[NSString class]]);
    NSParameterAssert([value isKindOfClass:[NSString class]]);
    
    NSString *urlString = [NSString stringWithFormat:@"documents/%@/extractions/%@", documentId, label];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"PUT"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Content-Type"];
        NSDictionary *feedbackDict = @{@"box": boundingBox, @"value": value};
        NSData *feedbackData = [NSJSONSerialization dataWithJSONObject:feedbackDict
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];
        return [[_urlSession BFUploadTaskWithRequest:request fromData:feedbackData] continueWithSuccessBlock:^id(BFTask *updateTask) {
            GINIURLResponse *response = updateTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)deleteFeedbackForDocument:(NSString *)documentId label:(NSString *)label {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    NSParameterAssert([label isKindOfClass:[NSString class]]);
    
    NSString *urlString = [NSString stringWithFormat:@"documents/%@/extractions/%@", documentId, label];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];

    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"DELETE"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *feedbackTask) {
            GINIURLResponse *response = feedbackTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)search:(NSString *)searchTerm limit:(NSUInteger)limit offset:(NSUInteger)offset docType:(NSString *)docType {
    NSParameterAssert([searchTerm isKindOfClass:[NSString class]]);
    
    NSString *urlString = [NSString stringWithFormat:@"search?q=%@&limit=%lu&offset=%lu&docType=%@", searchTerm, (unsigned long)limit, (unsigned long)offset, docType];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *searchTask) {
            GINIURLResponse *response = searchTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)reportErrorForDocument:(NSString *)documentId summary:(NSString *)summary description:(NSString *)description {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    NSString *summaryEncoded = stringByEscapingString(summary);
    NSString *descriptionEncoded = stringByEscapingString(description);

    NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/%@/errorreport?summary=%@&description=%@", documentId, summaryEncoded, descriptionEncoded];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];

    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"POST"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Content-Type"];
        return [[_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *reportErrorTask) {
            GINIURLResponse *response = reportErrorTask.result;
            return response.data;
        }];
    }];
}

@end
