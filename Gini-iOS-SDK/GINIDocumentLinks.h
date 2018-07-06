//
//  GINIDocumentLinks.h
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 3/27/18.
//

@interface GINIDocumentLinks: NSObject
    @property (readonly) NSString *document;
    @property (readonly) NSString *extractions;
    @property (readonly) NSString *layout;
    @property (readonly) NSString *processed;

- (instancetype) initWithDocumentURL:(NSString *)documentURL
                      extractionsURL:(NSString *)extractionsURL
                           layoutURL:(NSString *)layoutURL
                        processedURL:(NSString *)processedURL;
@end
