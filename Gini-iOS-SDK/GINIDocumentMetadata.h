//
//  GINIDocumentMetadata.h
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 10/24/18.
//

@interface GINIDocumentMetadata: NSObject
    @property (readonly) NSDictionary<NSString *, NSString *> *headers;

/**
 * The document metadata initializer.
 *
 * @param branchId              The branch id
 */
- (instancetype) initWithBranchId:(NSString *)branchId;

/**
 * The document metadata initializer.
 *
 * @param branchId              The branch id
 * @param additionalHeaders     Additional headers for the metadata. i.e: ["customerId":"123456"]
 */
- (instancetype) initWithBranchId:(NSString *)branchId
                additionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders;

@end
