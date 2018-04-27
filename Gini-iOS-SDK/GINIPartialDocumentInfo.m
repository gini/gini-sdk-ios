//
//  GINIPartialDocumentInfo.m
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 4/25/18.
//

#import <Foundation/Foundation.h>
#import "GINIPartialDocumentInfo.h"

@implementation GINIPartialDocumentInfo

- (instancetype)initWithDocumentId:(NSString *)documentId rotationDelta:(int)rotationDelta {
    self = [super init];
    if (self) {
        _documentId = documentId;
        _rotationDelta = rotationDelta;
    }
    
    return self;
}

- (NSString *)formattedJson {
    NSString * formattedString = [NSString stringWithFormat:@"{\"document\":\"%@\", \"rotationDelta\":%d}", _documentId, _rotationDelta];
    
    return formattedString;
}

@end
