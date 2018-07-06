//
//  GINIPartialDocumentInfo.h
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 4/25/18.
//

@interface GINIPartialDocumentInfo: NSObject

@property NSString *documentUrl;
@property int rotationDelta;
@property (nonatomic, retain) NSString *documentId;


/**
 * The designated initializer to create a `GINIPartialDocumentInfo`.
 *
 * @param documentUrl         Partial document url.
 * @param rotationDelta       Rotation delta. Should be normalized to be in [0, 360).
 */
- (instancetype)initWithDocumentUrl:(NSString *)documentUrl rotationDelta:(int)rotationDelta;

/**
 * Method used to get the formatted json string for a partial document info.
 *
 * @returns     A formatted json string for this partial document info.
 */
- (NSString *)formattedJson;
@end
