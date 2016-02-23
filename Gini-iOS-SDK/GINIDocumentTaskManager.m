/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIDocumentTaskManager.h"
#import "GINIDocument.h"
#import "GINIExtraction.h"
#import "GINIError.h"
#import <Bolts/Bolts.h>


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
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    BFTask *documentTask = [[_apiManager getDocument:documentId] continueWithSuccessBlock:^id(BFTask *task) {
        GINIDocument *document = [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
        return document;
    }];
    return GINIhandleHTTPerrors(documentTask);
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName fromImage:(UIImage *)image {
    return [self createDocumentWithFilename:fileName fromData:UIImageJPEGRepresentation(image, 0.2) docType:nil];
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName fromImage:(UIImage *)image docType:(NSString *)docType {
    return [self createDocumentWithFilename:fileName fromData:UIImageJPEGRepresentation(image, 0.2) docType:docType];
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName fromData:(NSData *)data docType:(NSString *)docType {
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([data isKindOfClass:[NSData class]]);
    
    BFTask *createTask = [[_apiManager uploadDocumentWithData:data contentType:@"image/jpeg" fileName:fileName docType:docType] continueWithSuccessBlock:^id(BFTask *task) {
        return [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
    }];
    return GINIhandleHTTPerrors(createTask);
}

- (BFTask *)updateDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);
    
    BFTask *updateTask = [document.extractions continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *extractions = task.result;
        NSMutableDictionary *updateExtractions = [NSMutableDictionary new];
        
        NSArray *keys = @[@"paymentReference", @"iban", @"bic", @"amountToPay", @"paymentRecipient"];
        for (NSString *key in extractions) {
            if ([keys containsObject:key]) {
                GINIExtraction *extraction = extractions[key];
                updateExtractions[key] = @{@"value": extraction.value};
            }
        }
        
        return [_apiManager submitBatchFeedbackForDocument:document.documentId feedback:updateExtractions];
    }];
    return GINIhandleHTTPerrors(updateTask);
}

- (BFTask *)deleteDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    return GINIhandleHTTPerrors([_apiManager deleteDocument:document.documentId]);
}

- (BFTask *)pollDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    // Immediately return already processed documents.
    if (document.state == GiniDocumentStateComplete) {
        return [BFTask taskWithResult:document];
    }

    return [self pollDocumentWithId:document.documentId];
}

- (BFTask *)pollDocumentWithId:(NSString *)documentId{
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    BFTask *pollTask = [self privatePollDocumentWithId:documentId];
    return GINIhandleHTTPerrors(pollTask);
}

- (BFTask *)privatePollDocumentWithId:(NSString *)documentId {
    return [[_apiManager getDocument:documentId] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *polledDocument = task.result;
        // If the document is not fully processed yet, wait a second and then poll again.
        if ([polledDocument[@"progress"] isEqualToString:@"PENDING"]) {
            return [[BFTask taskWithDelay:self.pollingInterval * 1000] continueWithSuccessBlock:^id(BFTask *waitTask) {
                return [self privatePollDocumentWithId:documentId];
            }];
            // Otherwise return the document.
        } else {
            return [GINIDocument documentFromAPIResponse:polledDocument withDocumentManager:self];
        }
    }];
}

- (BFTask *)getPreviewForPage:(NSUInteger)page ofDocument:(GINIDocument *)document withSize:(GiniApiPreviewSize)size {
    NSParameterAssert(page > 0);
    NSParameterAssert(page <= document.pageCount);

    BFTask *pageTask = [_apiManager getPreviewForPage:page ofDocument:document.documentId withSize:size];
    return GINIhandleHTTPerrors(pageTask);
}

#pragma mark - Extraction methods
- (BFTask *)getExtractionsForDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    BFTask *extractionsTask = [self createExtractionsForGetTask:[_apiManager getExtractionsForDocument:document.documentId]];
    return GINIhandleHTTPerrors(extractionsTask);
}

- (BFTask *)getIncubatorExtractionsForDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    BFTask *extractionsTask = [self createExtractionsForGetTask:[_apiManager getIncubatorExtractionsForDocument:document.documentId]];
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
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    BFTask *layoutTask = [_apiManager getLayoutForDocument:document.documentId responseType:(GiniAPIResponseTypeJSON)];
    return GINIhandleHTTPerrors(layoutTask);
}

- (BFTask *)errorReportForDocument:(GINIDocument *)document summary:(NSString *)summary description:(NSString *)description{
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    BFTask *errorReportTask = [_apiManager reportErrorForDocument:document.documentId summary:summary description:description];
    return GINIhandleHTTPerrors(errorReportTask);
}

@end
