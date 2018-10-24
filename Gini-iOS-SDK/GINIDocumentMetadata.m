//
//  GINIDocumentMetadata.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 10/24/18.
//

#import <GINIDocumentMetadata.h>
#import <GINIConstants.h>

@implementation GINIDocumentMetadata

- (instancetype)initWithBranchId:(NSString *)branchId
               additionalHeaders:(NSDictionary<NSString *,NSString *> *)additionalHeaders {
    _headers = [[NSMutableDictionary alloc] initWithDictionary:additionalHeaders];
    [_headers setValue:branchId forKey:BranchIdHeaderKey];
    
    return self;
}

@end

