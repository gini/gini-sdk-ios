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

@end
