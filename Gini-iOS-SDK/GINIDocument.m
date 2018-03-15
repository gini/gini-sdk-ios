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
    } else if ([classification isEqualToString:@"TEXT"]) {
        sourceClassification = GiniDocumentSourceClassificationText;
    } else if ([classification isEqualToString:@"SANDWICH"]) {
        sourceClassification = GiniDocumentSourceClassificationSandwich;
    } else {
        NSLog(@"Unknown document source classification: %@", classification);
        return nil;
    }

    NSUInteger pageCount = [apiResponse[@"pageCount"] unsignedIntValue];

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
    return [self previewWithSize:size forPage:page cancellationToken:nil];
}

- (BFTask *)previewWithSize:(GiniApiPreviewSize)size forPage:(NSUInteger)page
          cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert(page > 0);
    NSParameterAssert(page <= self.pageCount);
    
    return [_documentTaskManager getPreviewForPage:page
                                        ofDocument:self withSize:size
                                 cancellationToken:cancellationToken];
}

- (BFTask *)getExtractions {
    return [self getExtractionsWithCancellationToken:nil];
}

- (BFTask *)getExtractionsWithCancellationToken:(BFCancellationToken *)cancellationToken {
    return [[self extractionTaskWithCancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *task) {
        NSMutableDictionary *results = task.result;
        return [results valueForKey:@"extractions"];
    }];
}

- (BFTask *)getCandidates {
    return [self getCandidatesWithCancellationToken:nil];
}

-(BFTask *)getCandidatesWithCancellationToken:(BFCancellationToken *)cancellationToken {
    return [[self extractionTaskWithCancellationToken:cancellationToken] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *results = task.result;
        return [results valueForKey:@"candidates"];
    }];
}

- (BFTask *)getLayout {
    return [self getLayoutWithCancellationToken:nil];
}

- (BFTask *)getLayoutWithCancellationToken:(BFCancellationToken *)cancellationToken {
    if (!_layout) {
        _layout = [[_documentTaskManager pollDocument:self cancellationToken:cancellationToken] continueWithBlock:^id(BFTask *task) {
            return [self->_documentTaskManager getLayoutForDocument:self cancellationToken:cancellationToken];
        }];
    }
    return _layout;
}


#pragma mark - Properties
- (BFTask *)extractionTaskWithCancellationToken:(BFCancellationToken *)cancellationToken {
    if (!_extractions) {
        // Ensure that the extractions are really available:
        _extractions = [[_documentTaskManager pollDocument:self cancellationToken:cancellationToken] continueWithBlock:^id(BFTask *task) {
            return [self->_documentTaskManager getExtractionsForDocument:self cancellationToken:cancellationToken];
        }];
    }
    return _extractions;
}

- (BFTask *)extractions {
    return [self getExtractions];
}

- (BFTask *)candidates {
    return [self getCandidates];
}

- (BFTask *)layout {
    return [self getLayout];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GINIDocument id=%@>", _documentId];
}

@end
