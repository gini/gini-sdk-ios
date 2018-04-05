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
    return availablePreviewSizes[previewSize];
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
- (instancetype)initWithURLSession:(id <GINIURLSession>)urlSession
                    requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory
                           baseURL:(NSURL *)baseURL {
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
+ (instancetype)apiManagerWithURLSession:(id <GINIURLSession>)urlSession
                          requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory
                                 baseURL:(NSURL *)baseURL {
    return [[self alloc] initWithURLSession:urlSession requestFactory:requestFactory baseURL:baseURL];
}

- (BFTask *)getDocument:(NSString *)documentId{
    return [self getDocument:documentId cancellationToken:nil];
}

-(BFTask *)getDocument:(NSString *)documentId
     cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@", documentId]
                        relativeToURL:_baseURL];
    return [self getDocumentWithURL:url cancellationToken:cancellationToken];
}

- (BFTask *)getDocumentWithURL:(NSURL *)location{
    return [self getDocumentWithURL:location cancellationToken:nil];
}

-(BFTask *)getDocumentWithURL:(NSURL *)location
            cancellationToken:(BFCancellationToken *)cancellationToken {
    return [[_requestFactory asynchronousRequestUrl:location withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *documentTask) {
            GINIURLResponse *response = documentTask.result;
            return response.data;
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)getPreviewForPage:(NSUInteger)pageNumber
                   ofDocument:(NSString *)documentId
                     withSize:(GiniApiPreviewSize)size {
    return [self getPreviewForPage:pageNumber ofDocument:documentId withSize:size cancellationToken:nil];
}

-(BFTask *)getPreviewForPage:(NSUInteger)pageNumber
                  ofDocument:(NSString *)documentId
                    withSize:(GiniApiPreviewSize)size
           cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert(pageNumber > 0);
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@/pages/%lu/%@", documentId, (unsigned long)pageNumber, GINIPreviewSizeString(size)]
                        relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        return [[self->_urlSession BFDownloadTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *downloadTask) {
            GINIURLResponse *response = downloadTask.result;
            NSURL *pathURL = response.data;
            NSData *imageData = [NSData dataWithContentsOfURL:pathURL];
            UIImage *image = [UIImage imageWithData:imageData];
            return image;
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)getPagesForDocument:(NSString *)documentId {
    return [self getPagesForDocument:documentId cancellationToken:nil];
}

-(BFTask *)getPagesForDocument:(NSString *)documentId
             cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@/pages", documentId] relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *pagesTask) {
            GINIURLResponse *response = pagesTask.result;
            return response.data;
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)getLayoutForDocument:(NSString *)documentId
                    responseType:(GiniAPIResponseType)responseType {
    return [self getLayoutForDocument:documentId responseType:responseType cancellationToken: nil];
}

-(BFTask *)getLayoutForDocument:(NSString *)documentId
                   responseType:(GiniAPIResponseType)responseType
              cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@/layout", documentId] relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        if (responseType == GiniAPIResponseTypeJSON) {
            [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        } else {
            [request setValue:@"application/vnd.gini.v1+xml" forHTTPHeaderField:@"Accept"];
        }
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *layoutTask) {
            GINIURLResponse *response = layoutTask.result;
            return response.data;
        }];
    } cancellationToken:cancellationToken];
}


- (BFTask *)uploadDocumentWithData:(NSData *)documentData
                       contentType:(NSString *)contentType
                          fileName:(NSString *)fileName
                           docType:(NSString *)docType {
    return [self uploadDocumentWithData:documentData contentType:contentType fileName:fileName docType:docType cancellationToken:nil];
}

- (BFTask *)uploadDocumentWithData:(NSData *)documentData
                       contentType:(NSString *)contentType
                          fileName:(NSString *)fileName
                           docType:(NSString *)docType
                 cancellationToken:(BFCancellationToken *)cancellationToken {
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
        
        return [[self->_urlSession BFUploadTaskWithRequest:requestTask.result fromData:documentData] continueWithSuccessBlock:^id(BFTask *uploadTask) {
            // The HTTP response has a Location header with the URL of the document.
            GINIURLResponse *response = uploadTask.result;
            NSString *location = [[response.response allHeaderFields] valueForKey:@"Location"];
            // Get the document.
            return [self getDocumentWithURL:[NSURL URLWithString:location] cancellationToken:cancellationToken];
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)createCompositeDocumentWithPartialDocumentsInfo:(NSArray<NSDictionary<NSString *,id> *> *)partialDocumentsInfo
                                                   fileName:(NSString *)fileName
                                                    docType:(NSString *)docType
                                          cancellationToken:(BFCancellationToken *)cancellationToken {   
    NSDictionary* dict = @{@"subdocuments": partialDocumentsInfo};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *jsonStringFormatted = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSData *jsonDataFormatted = [jsonStringFormatted dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"documents/?filename=%@", stringByEscapingString(fileName)];
    if (docType) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&doctype=%@", stringByEscapingString(docType)]];
    }
    
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"POST"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v2.document+json" forHTTPHeaderField:@"Content-Type"];
        
        return [[self->_urlSession BFUploadTaskWithRequest:requestTask.result fromData:jsonDataFormatted] continueWithSuccessBlock:^id(BFTask *uploadTask) {
            // The HTTP response has a Location header with the URL of the document.
            GINIURLResponse *response = uploadTask.result;
            NSString *location = [[response.response allHeaderFields] valueForKey:@"Location"];
            // Get the document.
            return [self getDocumentWithURL:[NSURL URLWithString:location] cancellationToken:cancellationToken];
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)deleteDocument:(NSString *)documentId {
    return [self deleteDocument:documentId cancellationToken:nil];
}

-(BFTask *)deleteDocument:(NSString *)documentId
        cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"documents/%@", documentId] relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"DELETE"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *documentTask) {
            GINIURLResponse *response = documentTask.result;
            return response.data;
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)getDocumentsWithLimit:(NSUInteger)limit
                           offset:(NSUInteger)offset {
    return [self getDocumentsWithLimit:limit offset:offset cancellationToken:nil];
}

-(BFTask *)getDocumentsWithLimit:(NSUInteger)limit
                          offset:(NSUInteger)offset
               cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert(limit > 0);
    NSParameterAssert(offset >= 0);
    
    NSString *urlString = [NSString stringWithFormat:@"documents?limit=%lu&offset=%lu", (unsigned long)limit, (unsigned long)offset];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *documentsTask) {
            GINIURLResponse *response = documentsTask.result;
            return response.data;
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)getExtractionsForDocument:(NSString *)documentId {
    return [self getExtractionsForDocument:documentId cancellationToken:nil];
}

- (BFTask *)getExtractionsForDocument:(NSString *)documentId
                    cancellationToken:(BFCancellationToken *)cancellationToken {
    return [self getExtractionsForDocument:documentId withHeader:@"application/vnd.gini.v1+json" cancellationToken:cancellationToken];
}

- (BFTask *)getIncubatorExtractionsForDocument:(NSString *)documentId {
    return [self getIncubatorExtractionsForDocument:documentId cancellationToken:nil];
}

-(BFTask *)getIncubatorExtractionsForDocument:(NSString *)documentId
                            cancellationToken:(BFCancellationToken *)cancellationToken {
    return [self getExtractionsForDocument:documentId withHeader:@"application/vnd.gini.incubator+json" cancellationToken:cancellationToken];
}

- (BFTask *)getExtractionsForDocument:(NSString *)documentId
                           withHeader:(NSString *)header
                    cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    NSString *urlString = [NSString stringWithFormat:@"documents/%@/extractions", documentId];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:header forHTTPHeaderField:@"Accept"];
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *extractionsTask) {
            GINIURLResponse *response = extractionsTask.result;
            return response.data;
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)submitFeedbackForDocument:(NSString *)documentId
                                label:(NSString *)label
                                value:(NSString *)value
                          boundingBox:(NSDictionary *)boundingBox {
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
        return [[self->_urlSession BFUploadTaskWithRequest:request fromData:feedbackData] continueWithSuccessBlock:^id(BFTask *updateTask) {
            GINIURLResponse *response = updateTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)submitBatchFeedbackForDocument:(NSString *)documentId
                                  feedback:(NSDictionary *)feedback {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    NSParameterAssert([feedback isKindOfClass:[NSDictionary class]]);

    NSString *urlString = [NSString stringWithFormat:@"documents/%@/extractions", documentId];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];

    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"PUT"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Content-Type"];
        NSData *feedbackData = [NSJSONSerialization dataWithJSONObject:@{@"feedback": feedback}
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];

        return [[self->_urlSession BFUploadTaskWithRequest:request fromData:feedbackData] continueWithSuccessBlock:^id(BFTask *updateTask) {
            GINIURLResponse *response = updateTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)deleteFeedbackForDocument:(NSString *)documentId
                                label:(NSString *)label {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    NSParameterAssert([label isKindOfClass:[NSString class]]);
    
    NSString *urlString = [NSString stringWithFormat:@"documents/%@/extractions/%@", documentId, label];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];

    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"DELETE"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *feedbackTask) {
            GINIURLResponse *response = feedbackTask.result;
            return response.data;
        }];
    }];
}

- (BFTask *)search:(NSString *)searchTerm
             limit:(NSUInteger)limit
            offset:(NSUInteger)offset
           docType:(NSString *)docType {
    return [self search:searchTerm limit:limit offset:offset docType:docType cancellationToken:nil];
}

- (BFTask *)search:(NSString *)searchTerm
             limit:(NSUInteger)limit
            offset:(NSUInteger)offset
           docType:(NSString *)docType
 cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([searchTerm isKindOfClass:[NSString class]]);
    
    NSString *urlString = [NSString stringWithFormat:@"search?q=%@&limit=%lu&offset=%lu&docType=%@", searchTerm, (unsigned long)limit, (unsigned long)offset, docType];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];
    
    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Accept"];
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *searchTask) {
            GINIURLResponse *response = searchTask.result;
            return response.data;
        }];
    } cancellationToken:cancellationToken];
}

- (BFTask *)reportErrorForDocument:(NSString *)documentId
                           summary:(NSString *)summary
                       description:(NSString *)description {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    NSString *summaryEncoded = stringByEscapingString(summary);
    NSString *descriptionEncoded = stringByEscapingString(description);

    NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/%@/errorreport?summary=%@&description=%@", documentId, summaryEncoded, descriptionEncoded];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:_baseURL];

    return [[_requestFactory asynchronousRequestUrl:url withMethod:@"POST"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *request = requestTask.result;
        [request setValue:@"application/vnd.gini.v1+json" forHTTPHeaderField:@"Content-Type"];
        return [[self->_urlSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *reportErrorTask) {
            GINIURLResponse *response = reportErrorTask.result;
            return response.data;
        }];
    }];
}

@end
