/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIDocumentTaskManager.h"
#import "GINIDocument.h"
#import "GINIExtraction.h"
#import <Bolts/Bolts.h>


@implementation GINIDocumentTaskManager {
    GINIAPIManager *_apiManager;
}

#pragma mark - Factory

+ (instancetype)documentTaskManagerWithAPIManager:(GINIAPIManager *)apiManager {
    NSParameterAssert([apiManager isKindOfClass:[GINIAPIManager class]]);

    return [[GINIDocumentTaskManager alloc] initWithAPIManager:apiManager];
}

#pragma mark - Initializer
- (instancetype)initWithAPIManager:(GINIAPIManager *)apiManager {
    self = [super init];
    if (self) {
        _apiManager = apiManager;

    }
    return self;
}

#pragma mark - Document methods
- (BFTask *)getDocumentWithId:(NSString *)documentId{
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    return [[_apiManager getDocument:documentId] continueWithSuccessBlock:^id(BFTask *task) {
        GINIDocument *document = [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
        return document;
    }];
}

- (BFTask *)createDocumentWithFilename:(NSString *)fileName fromImage:(UIImage *)image {
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([UIImage isKindOfClass:[UIImage class]]);

    return [[_apiManager uploadDocumentWithData:UIImagePNGRepresentation(image) contentType:@"image/png" fileName:fileName] continueWithSuccessBlock:^id(BFTask *task) {
        return [GINIDocument documentFromAPIResponse:task.result withDocumentManager:self];
    }];
}

- (BFTask *)updateDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    // TODO: The Gini API will offer bulk updates soon. As soon as it is available, refactor this method to use the bulk update
    return [document.extractions continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *extractions = task.result;
        NSMutableArray *updateTasks = [NSMutableArray new];
        for (NSString *key in extractions) {
            GINIExtraction *extraction = extractions[key];
            if (extraction.isDirty) {
                [updateTasks addObject:[self updateExtraction:extraction forDocument:document]];
            }
        }
        return [BFTask taskForCompletionOfAllTasks:updateTasks];
    }];
}

- (BFTask *)deleteDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    return [_apiManager deleteDocument:document.documentId];
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
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [self pollDocumentWithId:documentId completionSource:taskCompletionSource];
    return taskCompletionSource.task;
}

- (void)pollDocumentWithId:(NSString *)documentId completionSource:(BFTaskCompletionSource *)taskCompletionSource {
    [[_apiManager getDocument:documentId] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [taskCompletionSource setError:task.error];
        } else {
            NSDictionary *polledDocument = task.result;
            if ([[polledDocument objectForKey:@"progress"] isEqualToString:@"PENDING"]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.pollingInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self pollDocumentWithId:documentId completionSource:taskCompletionSource];
                });
            } else {
                GINIDocument *document = [GINIDocument documentFromAPIResponse:polledDocument withDocumentManager:self];
                [taskCompletionSource setResult:document];
            }
        }
        return nil;
    }];
}

- (BFTask *)getPreviewForPage:(NSUInteger)page ofDocument:(GINIDocument *)document withSize:(GiniApiPreviewSize)size {
    NSParameterAssert(page > 0);
    NSParameterAssert(page <= document.pageCount);

    return [_apiManager getPreviewForPage:page ofDocument:document.documentId withSize:size];
}

#pragma mark - Extraction methods
- (BFTask *)getExtractionsForDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    return [[_apiManager getExtractionsForDocument:document.documentId] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *apiResponse = task.result;
        // First of all, create the candidates.
        NSArray *candidates = [apiResponse valueForKey:@"candidates"];    // TODO error handling
        NSMutableDictionary *giniCandidates = [NSMutableDictionary new];  // TODO more error handling
        for (NSUInteger i=0; i < [candidates count]; i++) {               // TODO a lot of error handling
            NSDictionary *candidate = [candidates objectAtIndex:i];
            NSString *entity = [candidate valueForKey:@"entity"];
            if (!giniCandidates[entity]) {
                giniCandidates[entity] = [NSMutableArray new];
            }
            GINIExtraction *giniExtraction = [GINIExtraction extractionWithName:[candidate valueForKey:@"name"]
                                                                          value:[candidate valueForKey:@"value"]
                                                                         entity:entity
                                                                            box:[candidate valueForKey:@"box"]];
            [giniCandidates[entity] addObject:giniExtraction];
        }
        // And then create the extractions.
        NSArray *extractions = [apiResponse valueForKey:@"extractions"];
        NSMutableDictionary *giniExtractions = [NSMutableDictionary new];
        for (NSUInteger i=0; i < [extractions count]; i++) {
            NSDictionary *extraction = [extractions objectAtIndex:i];
            NSString *entity = [extraction valueForKey:@"entity"];
            NSString *name = [extraction valueForKey:@"name"];
            NSArray *candidatesForExtraction;
            if (giniCandidates[entity]) {
                candidatesForExtraction = giniCandidates[entity];
            } else {
                candidatesForExtraction = [NSArray new];
            }
            GINIExtraction *giniExtraction = [GINIExtraction extractionWithName:[extraction valueForKey:@"name"]
                                                                          value:[extraction valueForKey:@"value"]
                                                                         entity:entity
                                                                            box:[extraction valueForKey:@"box"]];
            giniExtraction.candidates = candidatesForExtraction;
            giniExtractions[name] = candidatesForExtraction;
        }

        return [NSMutableDictionary dictionaryWithDictionary:@{@"extractions": giniExtractions, @"candidates": giniCandidates}];
    }];
}

- (BFTask *)updateExtraction:(GINIExtraction *)extraction forDocument:(GINIDocument *)document {
    NSParameterAssert([GINIExtraction isKindOfClass:[GINIExtraction class]]);
    NSParameterAssert([GINIDocument isKindOfClass:[GINIDocument class]]);

    return [[_apiManager submitFeedbackForDocument:document.documentId
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
}

- (BFTask *)getLayoutForDocument:(GINIDocument *)document {
    NSParameterAssert([document isKindOfClass:[GINIDocument class]]);

    return [_apiManager getLayoutForDocument:document.documentId];
}

@end
