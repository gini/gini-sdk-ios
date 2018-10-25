//
//  GINIDocumentMetadata.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 10/24/18.
//

#import <GINIDocumentMetadata.h>
#import <GINIConstants.h>

@implementation GINIDocumentMetadata

- (instancetype)initWithBranchId:(NSString *)branchId {
    return [self initWithBranchId:branchId additionalHeaders:nil];
}

- (instancetype)initWithBranchId:(NSString *)branchId
               additionalHeaders:(NSDictionary<NSString *,NSString *> *)additionalHeaders {
    
    _headers = [[NSMutableDictionary alloc] initWithCapacity:additionalHeaders.count + 1];
    
    NSString *branchIdKey = [self formattedKey:MetadataBranchIdHeaderKey];
    [_headers setValue:branchId forKey:branchIdKey];
    
    if(additionalHeaders != nil) {
        for (NSString* key in additionalHeaders) {
            NSParameterAssert(![key containsString:MetadataHeaderKeyPrefix]);
            
            [_headers setValue:additionalHeaders[key] forKey:[self formattedKey:key]];
        }
    }
    
    return self;
}

- (NSString *)formattedKey:(NSString *) key {
    return [[NSString alloc] initWithFormat:@"%@%@",
            MetadataHeaderKeyPrefix,
            key];
}

@end

