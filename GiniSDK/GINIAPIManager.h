#import <Foundation/Foundation.h>

@class BFTask;
@protocol GINIAPIManagerRequestFactory;
@protocol GINIURLSession;


/**
 * The possible sizes of rendered documents.
 */
typedef NS_ENUM(NSUInteger, GiniApiPreviewSize){
    /// 750x900
    GiniApiPreviewSizeMedium,
    /// 1280x1810
    GiniApiPreviewSizeBig
};


/**
 * The GINIAPIManager is responsible for handling the communication with the GINI API.
 */
@interface GINIAPIManager : NSObject


+ (instancetype)apiManagerWithURLSession:(id<GINIURLSession>)urlSession requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory baseURL:(NSURL *)baseURL;


/**
 * Gets the document with the given ID.
 *
 * @param documentId The document's ID
 * @returns A BFTask* that will resolve to a NSDictionary* containing the API's response.
 */
- (BFTask *)getDocument:(NSString *)documentId;

/**
 * Gets the document with the given URL.
 *
 * @param documentId The document's location.
 * @returns A BFTask* that will resolve to a NSDictionary* containing the API's response.
 */
- (BFTask *)getDocumentWithURL:(NSURL *)location;

/**
 * Gets the rendered preview of a document page.
 *
 * @param pageNumber The page number of the page of which the preview image is wanted (index starting with 1).
 * @param documentId The document's id.
 * @returns A BFTask* that will resolve to an UIImage* containing the preview image.
 */
- (BFTask *)getPreviewForPage:(NSUInteger)pageNumber ofDocument:(NSString *)documentId withSize:(GiniApiPreviewSize)size;


/**
 * Creates a new document from the given NSData*.
 *
 * @param documentData Data containing the document. This should be in a format that is supported by the Gini API, see
 *   http://developer.gini.net/gini-api/html/documents.html?highlight=put#supported-file-formats for details.
 * @param contentType The content type of the document (as a MIME string).
 * @param fileName The filename of the document.
 * @returns A BFTask* that will resolve to a NSString containing the created document's ID.
 */
- (BFTask *)uploadDocumentWithData:(NSData *)documentImage contentType:(NSString *)contentType fileName:(NSString *)fileName;

/**
 * The designated initializer.
 *
 * @param urlSession An object that implements the <GINIURLSession> protocol. Will be used to perform the HTTP
 *   communication.
 * @param requestFactory An object that implements the <GINIAPIManagerRequestFactory>. Will be used to create request
 *   objects with valid session credentials. @see GINIAPIManagerRequestFactory for details.
 * @param baseURL The baseURL. The requests to the Gini API are relative to that URL, so it usually should be set
 *   to a NSURL* pointing to 'https://api.gini.net'.
 */
- (instancetype)initWithURLSession:(id<GINIURLSession>)urlSession requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory baseURL:(NSURL *)baseURL;


@end
