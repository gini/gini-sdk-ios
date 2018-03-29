/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIDocumentTaskManager.h"
#import "GINIDocument.h"
#import "GINIExtraction.h"
#import "GINIError.h"
#import <Bolts/Bolts.h>
#import "NSData+MimeTypes.h"

/**
 * Handles common HTTP errors and expected errors that occur during task execution.
 */
BFTask*GINIhandleHTTPerrors(BFTask *originalTask){
    return [originalTask continueWithBlock:^id(BFTask *task) {
        if (task.error && [task.error.domain isEqualToString:NSURLErrorDomain]) {
            switch(task.error.code) {
                    // HTTP #404
                case NSURLErrorFileDoesNotExist:
                    return [GINIError errorWithCode:GINIErrorResourceNotFound userInfo:task.error.userInfo];
                    
                    // HTTP #401
                case NSURLErrorUserAuthenticationRequired:
                    return [GINIError errorWithCode:GINIErrorNotAuthorized userInfo:task.error.userInfo];
                    
                    // HTTP #403
                case NSURLErrorNoPermissionsToReadFile:
                    return [GINIError errorWithCode:GINIErrorInsufficientRights userInfo:task.error.userInfo];
                    
                default:
                    break;
            }
        }
        return task;
    }];
}


@implementation GINIDocumentTaskManager {
    GINIAPIManager *_apiManager;
}

#pragma mark - Factory

+ (instancetype)documentTaskManagerWithAPIManager:(GINIAPIManager *)apiManager {
    NSParameterAssert([apiManager isKindOfClass:[GINIAPIManager class]]);
    
    return [[self alloc] initWithAPIManager:apiManager];
}

#pragma mark - Initializer
- (instancetype)initWithAPIManager:(GINIAPIManager *)apiManager {
    self = [super init];
    if (self) {
        _apiManager = apiManager;
        _pollingInterval = 1;
    }
    return self;
}

#pragma mark - Document methods
- (BFTask *)getDocumentWithId:(NSString *)documentId{
    return [self getDocumentWithId:documentId cancellationToken:nil];
}

- (BFTask *)getDocumentWithId:(NSString *)documentId cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    BFTask *documentTask = [[_apiManager getDocument:documentId cancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *task) {
        GINIDocument *document = [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
        return document;
    }];
    return GINIhandleHTTPerrors(documentTask);
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName
                             fromImage:(UIImage *)image {
    return [self createDocumentWithFilename:fileName
                                  fromImage:image
                                    docType:nil];
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName
                             fromImage:(UIImage *)image
                               docType:(NSString *)docType {
    return [self createDocumentWithFilename:fileName
                                   fromData:UIImageJPEGRepresentation(image, 0.2)
                                    docType:@"image/jpeg"
                          cancellationToken:nil];
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName
                              fromData:(NSData *)data
                               docType:(NSString *)docType {
    return [self createDocumentWithFilename:fileName
                                   fromData:data
                                    docType:docType
                          cancellationToken:nil];
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName
                              fromData:(NSData *)data
                               docType:(NSString *)docType
                     cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([data isKindOfClass:[NSData class]]);
    
    NSString* contentType = [data mimeType]; // i.e: image/jpeg
    
    NSString* lastContentTypeComponent = [[contentType componentsSeparatedByString:@"/"] lastObject];
    NSString* concreteType = @"";  // i.e: jpeg
    if (lastContentTypeComponent != nil && [lastContentTypeComponent length] > 0) {
        concreteType = lastContentTypeComponent;
    }
    contentType = [NSString stringWithFormat:@"application/vnd.gini.v2.partial+%@", concreteType];
    
    BFTask *createTask = [[_apiManager uploadDocumentWithData:data
                                                  contentType:contentType
                                                     fileName:fileName
                                                      docType:docType
                                            cancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *task) {
        return [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
    }];
    return GINIhandleHTTPerrors(createTask);
}

- (BFTask *)updateDocument:(GINIDocument *)document {
    return [self updateDocument:document cancellationToken:nil];
}

- (BFTask *)updateDocument:(GINIDocument *)document cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    BFTask *updateTask = [[document getExtractionsWithCancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *extractions = task.result;
        NSMutableDictionary *updateExtractions = [NSMutableDictionary new];
        
        NSArray *keys = @[@"paymentReference", @"iban", @"bic", @"amountToPay", @"paymentRecipient", @"paymentPurpose"];
        for (NSString *key in extractions) {
            if ([keys containsObject:key]) {
                GINIExtraction *extraction = extractions[key];
                updateExtractions[key] = @{@"value": extraction.value};
            }
        }
        
        return [self->_apiManager submitBatchFeedbackForDocument:document.documentId feedback:updateExtractions];
    }];
    return GINIhandleHTTPerrors(updateTask);
}

- (BFTask *)deleteDocument:(GINIDocument *)document {
    return [self deleteDocument:document cancellationToken:nil];
}

- (BFTask *)deleteDocument:(GINIDocument *)document
         cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    return GINIhandleHTTPerrors([_apiManager deleteDocument:document.documentId cancellationToken:cancellationToken]);
}

- (BFTask *)pollDocument:(GINIDocument *)document {
    return [self pollDocument:document cancellationToken:nil];
}

- (BFTask *)pollDocument:(GINIDocument *)document
       cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    // Immediately return already processed documents.
    if (document.state == GiniDocumentStateComplete) {
        return [BFTask taskWithResult:document];
    }
    
    return [self pollDocumentWithId:document.documentId
                  cancellationToken:cancellationToken];
}

- (BFTask *)pollDocumentWithId:(NSString *)documentId{
    return [self pollDocumentWithId:documentId cancellationToken:nil];
}

- (BFTask *)pollDocumentWithId:(NSString *)documentId
             cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    BFTask *pollTask = [self privatePollDocumentWithId:documentId cancellationToken:cancellationToken];
    return GINIhandleHTTPerrors(pollTask);
}


- (BFTask *)privatePollDocumentWithId:(NSString *)documentId
                    cancellationToken:(BFCancellationToken *)cancellationToken {
    return [[_apiManager getDocument:documentId cancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *polledDocument = task.result;
        // If the document is not fully processed yet, wait a second and then poll again.
        if ([polledDocument[@"progress"] isEqualToString:@"PENDING"]) {
            return [[BFTask taskWithDelay:(int)self.pollingInterval * 1000 cancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *waitTask) {
                return [self privatePollDocumentWithId:documentId cancellationToken:cancellationToken];
            }];
            // Otherwise return the document.
        } else {
            return [GINIDocument documentFromAPIResponse:polledDocument withDocumentManager:self];
        }
    }];
}

- (BFTask *)getPreviewForPage:(NSUInteger)page
                   ofDocument:(GINIDocument *)document
                     withSize:(GiniApiPreviewSize)size {
    return [self getPreviewForPage:page ofDocument:document withSize:size cancellationToken:nil];
}

- (BFTask *)getPreviewForPage:(NSUInteger)page
                   ofDocument:(GINIDocument *)document
                     withSize:(GiniApiPreviewSize)size
            cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert(page > 0);
    NSParameterAssert(page <= document.pageCount);
    
    BFTask *pageTask = [_apiManager getPreviewForPage:page ofDocument:document.documentId withSize:size cancellationToken:cancellationToken];
    return GINIhandleHTTPerrors(pageTask);
}

#pragma mark - Extraction methods
- (BFTask *)getExtractionsForDocument:(GINIDocument *)document {
    return [self getExtractionsForDocument:document cancellationToken:nil];
}

- (BFTask *)getExtractionsForDocument:(GINIDocument *)document
                    cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    BFTask *extractionsTask = [self createExtractionsForGetTask:[_apiManager getExtractionsForDocument:document.documentId
                                                                                     cancellationToken:cancellationToken]];
    return GINIhandleHTTPerrors(extractionsTask);
}

- (BFTask *)getExtractionsForDocuments:(NSArray<GINIDocument *> *)documents cancellationToken:(BFCancellationToken *)cancellationToken {
    NSMutableArray* urls = [NSMutableArray new];
    
    for (GINIDocument *document in documents) {
        [urls addObject: document.links.document];
    }
    
    return [[_apiManager createCompositeDocumentWithPartialDocumentsURLs:urls
                                                                fileName:@""
                                                                 docType:@""
                                                       cancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *task) {
        GINIDocument *compositeDocument = task.result;
        BFTask *extractionsTask = [[self pollDocument:compositeDocument cancellationToken:cancellationToken] continueWithBlock:^id(BFTask *task) {
            return [self createExtractionsForGetTask:[self->_apiManager getExtractionsForDocument:compositeDocument.documentId
                                                                                cancellationToken:cancellationToken]];
        }];
        
        return [extractionsTask continueWithSuccessBlock:^id(BFTask *task) {
            NSDictionary *results = task.result;
            return [results valueForKey:@"extractions"];
        }];;
    }];
    
}

- (BFTask *)getIncubatorExtractionsForDocument:(GINIDocument *)document {
    return [self getIncubatorExtractionsForDocument:document cancellationToken:nil];
}

- (BFTask *)getIncubatorExtractionsForDocument:(GINIDocument *)document
                             cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    BFTask *extractionsTask = [self createExtractionsForGetTask:[_apiManager getIncubatorExtractionsForDocument:document.documentId
                                                                                              cancellationToken:cancellationToken]];
    return GINIhandleHTTPerrors(extractionsTask);
}

- (BFTask *)createExtractionsForGetTask:(BFTask *)getTask {
    return [getTask continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *apiResponse = task.result;
        // First of all, create the candidates.
        NSMutableDictionary *giniCandidates = [NSMutableDictionary new];
        NSDictionary *candidatesMapping = [apiResponse valueForKey:@"candidates"];
        for (NSString *entity in candidatesMapping) {
            NSArray *candidates = candidatesMapping[entity];
            giniCandidates[entity] = [NSMutableArray new];
            
            for (NSUInteger i=0; i < [candidates count]; i++) {
                NSDictionary *candidate = candidates[i];
                GINIExtraction *giniExtraction = [GINIExtraction extractionWithName:nil
                                                                              value:[candidate valueForKey:@"value"]
                                                                             entity:entity
                                                                                box:[candidate valueForKey:@"box"]];
                [giniCandidates[entity] addObject:giniExtraction];
            }
            
        }
        
        // And then create the extractions.
        NSMutableDictionary *extractions = [apiResponse valueForKey:@"extractions"];
        NSMutableDictionary *giniExtractions = [NSMutableDictionary new];
        for (NSString *name in extractions) {
            NSDictionary *extraction = extractions[name];
            NSString *entity = [extraction valueForKey:@"entity"];
            NSArray *candidatesForExtraction;
            if (giniCandidates[entity]) {
                candidatesForExtraction = giniCandidates[entity];
            } else {
                candidatesForExtraction = [NSArray new];
            }
            GINIExtraction *giniExtraction = [GINIExtraction extractionWithName:name
                                                                          value:[extraction valueForKey:@"value"]
                                                                         entity:entity
                                                                            box:[extraction valueForKey:@"box"]];
            giniExtraction.candidates = candidatesForExtraction;
            giniExtractions[name] = giniExtraction;
        }
        
        return [NSMutableDictionary dictionaryWithDictionary:@{@"extractions": giniExtractions, @"candidates": giniCandidates}];
    }];
}

- (BFTask *)updateExtraction:(GINIExtraction *)extraction forDocument:(GINIDocument *)document {
    NSParameterAssert([GINIExtraction isKindOfClass:[GINIExtraction class]]);
    NSParameterAssert([GINIDocument isKindOfClass:[GINIDocument class]]);
    
    BFTask *updateTask = [[_apiManager submitFeedbackForDocument:document.documentId
                                                           label:extraction.name
                                                           value:extraction.value
                                                     boundingBox:extraction.box] continueWithSuccessBlock:^id(BFTask *task) {
        [document.extractions continueWithSuccessBlock:^id(BFTask *extractionsTask) {
            NSMutableDictionary *extractions = extractionsTask.result;
            extractions[extraction.name] = [GINIExtraction extractionWithName:extraction.name
                                                                        value:extraction.value
                                                                       entity:extraction.entity
                                                                          box:extraction.box];
            return nil;
        }];
        return nil;
    }];
    return GINIhandleHTTPerrors(updateTask);
}

- (BFTask *)getLayoutForDocument:(GINIDocument *)document {
    return [self getLayoutForDocument:document cancellationToken:nil];
}

- (BFTask *)getLayoutForDocument:(GINIDocument *)document cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    BFTask *layoutTask = [_apiManager getLayoutForDocument:document.documentId responseType:(GiniAPIResponseTypeJSON)];
    return GINIhandleHTTPerrors(layoutTask);
}

- (BFTask *)errorReportForDocument:(GINIDocument *)document
                           summary:(NSString *)summary
                       description:(NSString *)description{
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    BFTask *errorReportTask = [_apiManager reportErrorForDocument:document.documentId summary:summary description:description];
    return GINIhandleHTTPerrors(errorReportTask);
}

@end
