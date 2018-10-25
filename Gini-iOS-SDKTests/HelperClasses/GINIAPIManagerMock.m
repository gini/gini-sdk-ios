/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/Bolts.h>
#import "GINIAPIManagerMock.h"



@implementation GINIAPIManagerMock

+ (NSDictionary *)extractionsData{
    static NSDictionary *extractions;
    if (!extractions) {
        NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"extractions" withExtension:@"json"];
        extractions = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                      options:NSJSONReadingAllowFragments
                                                        error:nil];
    }
    return extractions;
}

- (instancetype)init{
    self = [super self];
    if (self) {
        _getDocumentCalled = 0;
    }
    return self;
}

- (BFTask *)getDocument:(NSString *)documentId{
    return [self getDocument:documentId cancellationToken:nil];
}

- (BFTask *)getDocument:(NSString *)documentId cancellationToken:(BFCancellationToken *)cancellationToken {
    _getDocumentCalled += 1;
    return [BFTask taskWithResult:@{
                                    @"id": @"1234",
                                    @"progress": @"COMPLETED",
                                    @"sourceClassification": @"SCANNED"
                                    }];
}

- (BFTask *)uploadDocumentWithData:(NSData *)documentData
                       contentType:(NSString *)contentType
                          fileName:(NSString *)fileName
                           docType:(NSString *)docType
                          metadata:(GINIDocumentMetadata *)metadata
                 cancellationToken:(BFCancellationToken *)cancellationToken {
    NSParameterAssert([documentData isKindOfClass:[NSData class]]);
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([contentType isKindOfClass:[NSString class]]);

    // Todo, for the current tests it's sufficient.
    return [BFTask taskWithError:[NSError errorWithDomain:@"mock" code:1 userInfo:nil]];
}

- (BFTask *)reportErrorForDocument:(NSString *)documentId summary:(NSString *)summary description:(NSString *)description {
    return [BFTask taskWithError:[NSError errorWithDomain:@"mock" code:1 userInfo:nil]];
}

- (BFTask *)submitBatchFeedbackForDocument:(NSString *)documentId feedback:(NSDictionary *)feedback {
    return [BFTask taskWithError:[NSError errorWithDomain:@"mock" code:1 userInfo:nil]];
}

- (BFTask *)getExtractionsForDocument:(NSString *)documentId {
    return [BFTask taskWithResult:[GINIAPIManagerMock extractionsData]];
}

@end
