/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/BFTask.h>
#import "GINIDocument.h"
#import "GINIDocumentTaskManager.h"


@interface GINIDocument ()
@property (readonly) BFTask *extractionTask;
@end


@implementation GINIDocument {
    GINIDocumentTaskManager *_documentTaskManager;
    BFTask *_extractions;
    BFTask *_layout;
}

+ (instancetype)documentFromAPIResponse:(NSDictionary *)apiResponse withDocumentManager:(GINIDocumentTaskManager *)documentManager{
    NSString *documentId = apiResponse[@"id"];
    // Documents must have an ID.
    if (!documentId) {
        NSLog(@"Document without id: %@", apiResponse);
        return nil;
    }

    GiniDocumentState documentState;
    NSString *progress = [apiResponse valueForKey:@"progress"];
    if ([progress isEqualToString:@"PENDING"]) {
        documentState = GiniDocumentStatePending;
    } else if([progress isEqualToString:@"COMPLETED"]) {
        documentState = GiniDocumentStateComplete;
    } else if ([progress isEqualToString:@"ERROR"]) {
        documentState = GiniDocumentStateError;
    } else {
        NSLog(@"Unknown document state: %@", progress);
        return nil;
    }

    GiniDocumentSourceClassification sourceClassification;
    NSString *classification = [apiResponse valueForKey:@"sourceClassification"];
    if ([classification isEqualToString:@"SCANNED"]) {
        sourceClassification = GiniDocumentSourceClassificationScanned;
    } else if ([classification isEqualToString:@"NATIVE"]) {
        sourceClassification = GiniDocumentSourceClassificationNative;
    } else {
        NSLog(@"Unknown document source classification: %@", classification);
        return nil;
    }

    NSUInteger pageCount = (NSUInteger)[apiResponse[@"pageCount"] integerValue];

    GINIDocument *document = [[GINIDocument alloc] initWithId:documentId state:documentState pageCount:pageCount sourceClassification:(GiniDocumentSourceClassification) sourceClassification documentManager:documentManager];
    document.filename = [apiResponse valueForKey:@"name"];
    document.creationDate = [NSDate dateWithTimeIntervalSince1970:floor([[apiResponse valueForKey:@"creationDate"] doubleValue] / 1000)];

    return document;
}

#pragma mark - Initializer

- (instancetype)initWithId:(NSString *)documentId state:(GiniDocumentState)state pageCount:(NSUInteger)pageCount sourceClassification:(GiniDocumentSourceClassification)sourceClassification documentManager:(GINIDocumentTaskManager *)documentManager {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);

    self = [super init];
    if (self) {
        _documentId = documentId;
        _state = state;
        _documentTaskManager = documentManager;
        _sourceClassification = sourceClassification;
        _pageCount = pageCount;
    }
    return self;
}

#pragma mark - Methods
- (BFTask *)previewWithSize:(GiniApiPreviewSize)size forPage:(NSUInteger)page {
    NSParameterAssert(page > 0);
    NSParameterAssert(page <= self.pageCount);

    return [_documentTaskManager getPreviewForPage:page ofDocument:self withSize:size];
}


#pragma mark - Properties
- (BFTask *)extractionTask {
    if (!_extractions) {
        // Ensure that the extractions are really available:
        _extractions = [[_documentTaskManager pollDocument:self] continueWithBlock:^id(BFTask *task) {
            return [_documentTaskManager getExtractionsForDocument:self];
        }];
    }
    return _extractions;
}

- (BFTask *)extractions {
    return [self.extractionTask continueWithSuccessBlock:^id(BFTask *task) {
        NSMutableDictionary *results = task.result;
        return [results valueForKey:@"extractions"];
    }];
}

- (BFTask *)candidates {
    return [self.extractionTask continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *results = task.result;
        return [results valueForKey:@"candidates"];
    }];
}

- (BFTask *)layout {
    if (!_layout) {
        _layout = [[_documentTaskManager pollDocument:self] continueWithBlock:^id(BFTask *task) {
            return [_documentTaskManager getLayoutForDocument:self];
        }];
    }
    return _layout;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GINIDocument id=%@>", _documentId];
}

@end
