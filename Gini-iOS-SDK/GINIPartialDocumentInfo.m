//
//  GINIPartialDocumentInfo.m
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 4/25/18.
//

#import <Foundation/Foundation.h>
#import "GINIPartialDocumentInfo.h"

@implementation GINIPartialDocumentInfo

- (instancetype)initWithDocumentUrl:(NSString *)documentUrl rotationDelta:(int)rotationDelta {
    self = [super init];
    if (self) {
        _documentUrl = documentUrl;
        _rotationDelta = rotationDelta;
    }
    
    return self;
}

- (NSString *)formattedJson {
    NSString * formattedString = [NSString stringWithFormat:@"{\"document\":\"%@\", \"rotationDelta\":%d}",
                                  _documentUrl,
                                  _rotationDelta];
    
    return formattedString;
}

@end
