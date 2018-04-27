//
//  GINIPartialDocumentInfo.h
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 4/25/18.
//

@interface GINIPartialDocumentInfo: NSObject

@property NSString *documentId;
@property int rotationDelta;


/**
 * The designated initializer to create a `GINIPartialDocumentInfo`.
 *
 * @param documentId         Partial document id.
 * @param rotationDelta      Rotation delta. Should be normalized to be in [0, 360).
 */
- (instancetype)initWithDocumentId:(NSString *)documentId rotationDelta:(int)rotationDelta;

/**
 * Method used to get the formatted json string for a partial document info.
 *
 * @returns     A formatted json string for this partial document info.
 */
- (NSString *)formattedJson;
@end
