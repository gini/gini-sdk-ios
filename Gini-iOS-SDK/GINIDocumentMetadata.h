//
//  GINIDocumentMetadata.h
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 10/24/18.
//

@interface GINIDocumentMetadata: NSObject
    @property (readonly) NSDictionary<NSString *, NSString *> *headers;

- (instancetype) initWithBranchId:(NSString *)branchId
                additionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders;
@end
