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

- (instancetype)initWithHeaders:(NSDictionary<NSString *,NSString *> *)headers {
    return [self initWithBranchId:nil additionalHeaders:headers];
}

- (instancetype)initWithBranchId:(NSString *)branchId
               additionalHeaders:(NSDictionary<NSString *,NSString *> *)additionalHeaders {
    
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    if(branchId != nil) {
        NSString *branchIdKey = [self formattedKey:MetadataBranchIdHeaderKey];
        [headers setValue:branchId forKey:branchIdKey];
    }

    for (NSString* key in additionalHeaders) {
        NSParameterAssert(![key containsString:MetadataHeaderKeyPrefix]);
            
        [headers setValue:additionalHeaders[key] forKey:[self formattedKey:key]];
    }
    
    _headers = headers;
    
    return self;
}

- (NSString *)formattedKey:(NSString *) key {
    return [[NSString alloc] initWithFormat:@"%@%@",
            MetadataHeaderKeyPrefix,
            key];
}

@end

