/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/Bolts.h>
#import "GINIAPIManagerMock.h"



@implementation GINIAPIManagerMock

- (instancetype)init{
    self = [super self];
    if (self) {
        _getDocumentCalled = 0;
    }
    return self;
}

- (BFTask *)getDocument:(NSString *)documentId{
    _getDocumentCalled += 1;
    return [BFTask taskWithResult:@{
            @"id": @"1234",
            @"progress": @"COMPLETED",
            @"sourceClassification": @"SCANNED"
    }];
}

- (BFTask *)uploadDocumentWithData:(NSData *)documentData contentType:(NSString *)contentType fileName:(NSString *)fileName {
    NSParameterAssert([documentData isKindOfClass:[NSData class]]);
    NSParameterAssert([fileName isKindOfClass:[NSString class]]);
    NSParameterAssert([contentType isKindOfClass:[NSString class]]);

    // Todo, for the current tests it's sufficient.
    return [BFTask taskWithError:[NSError errorWithDomain:@"mock" code:1 userInfo:nil]];
}

- (BFTask *)reportErrorForDocument:(NSString *)documentId summary:(NSString *)summary description:(NSString *)description {
    return [BFTask taskWithError:[NSError errorWithDomain:@"mock" code:1 userInfo:nil]];
}

@end
