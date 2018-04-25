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

+ (instancetype)documentFromAPIResponse:(NSDictionary *)apiResponse withDocumentManager:(GINIDocumentTaskManager *)documentManager {
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
    } else if ([classification isEqualToString:@"COMPOSITE"]) {
        sourceClassification = GiniDocumentSourceClassificationComposite;
    } else {
        NSLog(@"Unknown document source classification: %@", classification);
        return nil;
    }

    NSUInteger pageCount = [apiResponse[@"pageCount"] unsignedIntValue];
    
    NSDictionary *linksDict = [apiResponse valueForKey:@"_links"];
    GINIDocumentLinks *links = [[GINIDocumentLinks alloc] initWithDocumentURL:linksDict[@"document"]
                                                               extractionsURL:linksDict[@"extractions"]
                                                                    layoutURL:linksDict[@"layout"] 
                                                                 processedURL:linksDict[@"processed"]];
    
    NSArray<NSString *> *parents = [apiResponse valueForKey:@"parents"];
    NSArray<NSString *> *partialDocuments = [apiResponse valueForKey:@"partialDocuments"];
    
    GINIDocument *document = [[GINIDocument alloc] initWithId:documentId
                                                        state:documentState
                                                    pageCount:pageCount
                                         sourceClassification:(GiniDocumentSourceClassification) sourceClassification
                                                        links:links
                                                      parents:parents
                                             partialDocuments:partialDocuments
                                              documentManager:documentManager];
    
    document.filename = [apiResponse valueForKey:@"name"];
    document.creationDate = [NSDate dateWithTimeIntervalSince1970:floor([[apiResponse valueForKey:@"creationDate"] doubleValue] / 1000)];

    return document;
}

#pragma mark - Initializer


-(instancetype)initWithId:(NSString *)documentId
                    state:(GiniDocumentState)state
                pageCount:(NSUInteger)pageCount
     sourceClassification:(GiniDocumentSourceClassification)sourceClassification
          documentManager:(GINIDocumentTaskManager *)documentManager {
    return [self initWithId:documentId
                      state:state
                  pageCount:pageCount
       sourceClassification:sourceClassification
                      links:nil
                    parents:nil
           partialDocuments:nil
            documentManager:documentManager];
}

- (instancetype)initWithId:(NSString *)documentId
                     state:(GiniDocumentState)state
                 pageCount:(NSUInteger)pageCount
      sourceClassification:(GiniDocumentSourceClassification)sourceClassification
                     links:(GINIDocumentLinks *)links
                   parents:(NSArray<NSString *> *)parents
          partialDocuments:(NSArray<NSString *> *)partialDocuments {
    return [self initWithId:documentId
                      state:state
                  pageCount:pageCount
       sourceClassification:sourceClassification
                      links:links
                    parents:parents
           partialDocuments:partialDocuments
            documentManager:nil];
}

- (instancetype)initWithId:(NSString *)documentId
                     state:(GiniDocumentState)state
                 pageCount:(NSUInteger)pageCount
      sourceClassification:(GiniDocumentSourceClassification)sourceClassification
                     links:(GINIDocumentLinks *)links
                   parents:(NSArray<NSString *> *)parents
          partialDocuments:(NSArray<NSString *> *)partialDocuments
           documentManager:(GINIDocumentTaskManager *)documentManager {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    self = [super init];
    if (self) {
        _documentId = documentId;
        _state = state;
        _sourceClassification = sourceClassification;
        _pageCount = pageCount;
        _links = links;
        _parents = parents;
        _partialDocuments = partialDocuments;
        _documentTaskManager = documentManager;
    }
    
    return self;
}

- (BFTask *)extractions {
    return [self->_documentTaskManager getExtractionsForDocument:self cancellationToken:nil];
}

- (BFTask *)candidates {
    return [self->_documentTaskManager getCandidatesForDocument:self cancellationToken:nil];
}

- (BFTask *)layout {
    return [self->_documentTaskManager getExtractionsForDocument:self cancellationToken:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GINIDocument id=%@>", _documentId];
}

-(BFTask *)previewWithSize:(GiniApiPreviewSize)size forPage:(NSUInteger)page {
    return [self->_documentTaskManager getPreviewForPage:page ofDocument:self withSize:size cancellationToken:nil];
}

@end
