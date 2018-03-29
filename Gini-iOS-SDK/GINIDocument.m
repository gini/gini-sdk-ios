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
    NSDictionary *linksDict = [apiResponse valueForKey:@"_links"];
    GINIDocumentLinks *links = [[GINIDocumentLinks alloc] initWithDocumentURL:linksDict[@"document"]
                                                               extractionsURL:linksDict[@"extractions"]
                                                                    layoutURL:linksDict[@"layout"] 
                                                                 processedURL:linksDict[@"processed"]];
    GINIDocument *document = [[GINIDocument alloc] initWithId:documentId
                                                        state:documentState
                                                    pageCount:pageCount
                                         sourceClassification:(GiniDocumentSourceClassification) sourceClassification
                                              documentManager:documentManager
                                                        links:links];
    document.filename = [apiResponse valueForKey:@"name"];
    document.creationDate = [NSDate dateWithTimeIntervalSince1970:floor([[apiResponse valueForKey:@"creationDate"] doubleValue] / 1000)];

    return document;
}

#pragma mark - Initializer

- (instancetype)initWithId:(NSString *)documentId state:(GiniDocumentState)state pageCount:(NSUInteger)pageCount sourceClassification:(GiniDocumentSourceClassification)sourceClassification {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    return [self initWithId:documentId state:state pageCount:pageCount sourceClassification:sourceClassification links:nil];
}

- (instancetype)initWithId:(NSString *)documentId state:(GiniDocumentState)state pageCount:(NSUInteger)pageCount sourceClassification:(GiniDocumentSourceClassification)sourceClassification links:(GINIDocumentLinks *)links {
    NSParameterAssert([documentId isKindOfClass:[NSString class]]);
    
    self = [super init];
    if (self) {
        _documentId = documentId;
        _state = state;
        _sourceClassification = sourceClassification;
        _pageCount = pageCount;
        _links = links;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GINIDocument id=%@>", _documentId];
}

@end
