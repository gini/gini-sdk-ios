/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

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
 *
 * Usually you do not directly use this class, since it directly returns the responses of the Gini API. Instead you
 * should use the `GINIDocumentTaskManager` which offers much more sophisticated methods for dealing with documents and
 * extractions and has advanced error handling and convenience methods.
 */
@interface GINIAPIManager : NSObject


/**
 * Factory to create a new `GINIAPIManager` instance.
 *
 * @param urlSession        The GINIURLSession used to do the HTTP requests.
 * @param requestFactory    The GINIAPIManagerRequestFactory used to create the HTTP requests. See the documentation for
 *                          the `<GINIAPIManagerRequestFactory> protocol for details.
 *
 * @param baseURL           A NSURL describing the base URL of the Gini API. Usually this URL is https://api.gini.net/.
 *
 */
+ (instancetype)apiManagerWithURLSession:(id<GINIURLSession>)urlSession requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory baseURL:(NSURL *)baseURL;


/**
 * Gets the document with the given ID.
 *
 * @param documentId        The document's ID
 *
 * @returns                 A `BFTask*` that will resolve to a NSDictionary* containing the API's response.
 */
- (BFTask *)getDocument:(NSString *)documentId;

/**
 * Gets the document with the given URL.
 *
 * @param location          The document's location.
 * @returns                 A `BFTask*` that will resolve to a NSDictionary* containing the API's response.
 */
- (BFTask *)getDocumentWithURL:(NSURL *)location;

/**
 * Gets the rendered preview of a document page.
 *
 * @param pageNumber        The page number of the page of which the preview image is wanted (index starting with 1).
 * @param documentId        The document's unique identifier.
 * @param size              The size of the rendered preview image. Please notice that this is the maximum size,
 *                          meaning that the images dimensions will not exceeding this limit but the rendered image can
 *                          actually have a little smaller dimensions.
 *
 * @returns                 A `BFTask*` that will resolve to an UIImage* containing the preview image.
 */
- (BFTask *)getPreviewForPage:(NSUInteger)pageNumber ofDocument:(NSString *)documentId withSize:(GiniApiPreviewSize)size;

/**
 * Gets the list of pages for a document.
 *
 * @param documentId        The document's id.
 *
 * @returns                 A `BFTask*` that will resolve to an array of pages.
 */
- (BFTask *)getPagesForDocument:(NSString *)documentId;

/**
 * Gets the layout of a document.
 *
 * @param documentId        The document's id.
 *
 * @return                  A `BFTask*` that will resolve to a NSDictionary containing the document layout.
 */
- (BFTask *)getLayoutForDocument:(NSString *)documentId;

/**
 * Creates a new document from the given NSData*.
 *
 * @param documentData      Data containing the document. This should be in a format that is supported by the Gini API, see
 *                          [the Gini API documentation](http://developer.gini.net/gini-api/html/documents.html?highlight=put#supported-file-formats)
 *                          for details.
 * @param contentType       The content type of the document (as a MIME string).
 * @param fileName          The filename of the document.
 *
 * @returns                 A`BFTask*` that will resolve to a NSString containing the created document's ID.
 */
- (BFTask *)uploadDocumentWithData:(NSData *)documentData contentType:(NSString *)contentType fileName:(NSString *)fileName;

/**
 * Deletes the document with the given ID.
 *
 * @param documentId        The document's id.
 *
 * @returns                 A `BFTask*` with `nil` as result when the document has been deleted.
 */
- (BFTask *)deleteDocument:(NSString *)documentId;

/**
 * Gets a list of all documents.
 *
 * @param limit             The maximum number of documents to return.
 * @param offset            The start offset.
 *
 * @returns                 A `BFTask*` that will resolve to an NSDictionary containing a paginated list of documents.
 */
- (BFTask *)getDocumentsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset;

/**
 * Gets extractions for the specific document
 *
 * @param documentId        The document's id.
 *
 * @returns                 A `BFTask*` that will resolve to an NSDictionary containing the extractions for the document.
 */
- (BFTask *)getExtractionsForDocument:(NSString *)documentId;

/**
 * Gets the extractions for the specific document, including the incubation extractions (see
 * http://developer.gini.net/gini-api/html/incubator.html for details on incubating extractions).
 *
 * @param documentId        The document's unique identifier.
 *
 * @returns                 A `BFTask*` that will resolve to an NSDictionary containing the extractions for the document.
 */
- (BFTask *)getIncubatorExtractionsForDocument:(NSString *)documentId;

/**
 * Submit feedback for the document on a specific label.
 *
 * @param documentId        The document's id.
 * @param label             The extraction label to be updated.
 * @param value             The new value for the extraction.
 * @param boundingBox       The new bounding box for the updated extraction (optional).
 *
 * @returns                 A `BFTask*`
 */
- (BFTask *)submitFeedbackForDocument:(NSString *)documentId label:(NSString *)label value:(NSString *)value boundingBox:(NSDictionary *)boundingBox;

/**
 * Delete a specific feedback label for the document.
 * 
 * @param documentId        The document's id.
 * @param label             The extraction label to be deleted.
 *
 * @returns                 `BFTask*`
 */
- (BFTask *)deleteFeedbackForDocument:(NSString *)documentId label:(NSString *)label;

/**
 * Searches for documents containing the given words.
 * 
 * @param searchTerm        The search term(s) separated by space.
 * @param limit             The number of results per page.
 * @param offset            The start offset.
 * @param docType           Restrict the search to a specific doctype.
 *
 * @returns                 A `BFTask*` that will resolve to a NSDictionary containing documents found.
 */
- (BFTask *)search:(NSString *)searchTerm limit:(NSUInteger)limit offset:(NSUInteger)offset docType:(NSString *)docType;

/**
* Report an error for a specific document. If the processing result for a document was not satisfactory (e.g.
* extractions where empty or incorrect), you can create an error report for a document. This allows Gini to analyze and
* correct the problem that was found. The returned errorId can be used to refer to the reported error towards the Gini
* support.
*
* @warning The owner of this document must agree that Gini can use this document for debugging and error analysis.
*
* @param documentId        The document's id.
* @param summary           A summary for the error.
* @param description       A detailed description for the error.
*/
- (BFTask *)reportErrorForDocument:(NSString *)documentId summary:(NSString *)summary description:(NSString *)description;

/**
 * The designated initializer.
 *
 * @param urlSession        An object that implements the <GINIURLSession> protocol. Will be used to perform the HTTP
 *                          communication.
 * @param requestFactory    An object that implements the <GINIAPIManagerRequestFactory>. Will be used to create request
 *                          objects with valid session credentials. @see GINIAPIManagerRequestFactory for details.
 * @param baseURL           The baseURL. The requests to the Gini API are relative to that URL, so it usually should be
 *                          set to a `NSURL*` pointing to 'https://api.gini.net'.
 */
- (instancetype)initWithURLSession:(id<GINIURLSession>)urlSession requestFactory:(id <GINIAPIManagerRequestFactory>)requestFactory baseURL:(NSURL *)baseURL;

@end
