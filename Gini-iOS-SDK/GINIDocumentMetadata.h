//
//  GINIDocumentMetadata.h
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 10/24/18.
//

/**
 * The GINIDocumentMetadata contains any custom information regarding the upload (used later for reporting),
 * creating HTTP headers with an specific format.
 *
 */
@interface GINIDocumentMetadata: NSObject
    @property (readonly) NSDictionary<NSString *, NSString *> *headers;

/**
 * The document metadata initializer with only the branch ID (i.e: the BLZ of a Bank in Germany)
 *
 * @param branchId              The branch id (i.e: the BLZ of a Bank in Germany)
 */
- (instancetype) initWithBranchId:(NSString *)branchId;

/**
 * The document metadata initializer with only custom headers
 *
 * @param headers               Additional headers for the metadata. i.e: ["customerId":"123456"]
 */
- (instancetype)initWithHeaders:(NSDictionary<NSString *,NSString *> *)headers;

/**
 * The document metadata initializer with the branch ID and additional custom headers
 *
 * @param branchId              The branch id (i.e: the BLZ of a Bank in Germany)
 * @param additionalHeaders     Additional headers for the metadata. i.e: ["customerId":"123456"]
 */
- (instancetype) initWithBranchId:(NSString *)branchId
                additionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders;

@end
