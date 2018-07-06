//
//  GINIDocumentLinks.m
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 3/27/18.
//

#import <GiniDocumentLinks.h>

@implementation GINIDocumentLinks {
    
}

- (instancetype)initWithDocumentURL:(NSString *)documentURL
                    extractionsURL:(NSString *)extractionsURL
                         layoutURL:(NSString *)layoutURL
                      processedURL:(NSString *)processedURL {
    self = [super init];
    if (self) {
        _document = documentURL;
        _extractions = extractionsURL;
        _layout = layoutURL;
        _processed = processedURL;
    }
    
    return self;
}

@end
