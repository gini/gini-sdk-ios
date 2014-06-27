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
 * @param location The document's location.
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
 * Gets the list of pages for a document.
 *
 * @param documentId The document's id.
 * @return A BFTask* that will resolve to an array of pages.
 */
- (BFTask *)getPagesForDocument:(NSString *)documentId;

/**
 * Gets the layout of a document.
 *
 * @param documentId The document's id.
 * @return A BFTask that will resolve to a NSDictionary containing the document layout.
 */
- (BFTask *)getLayoutForDocument:(NSString *)documentId;

/**
 * Creates a new document from the given NSData*.
 *
 * @param documentData Data containing the document. This should be in a format that is supported by the Gini API, see
 *   http://developer.gini.net/gini-api/html/documents.html?highlight=put#supported-file-formats for details.
 * @param contentType The content type of the document (as a MIME string).
 * @param fileName The filename of the document.
 * @returns A BFTask* that will resolve to a NSString containing the created document's ID.
 */
- (BFTask *)uploadDocumentWithData:(NSData *)documentData contentType:(NSString *)contentType fileName:(NSString *)fileName;

/**
 * Deletes the document with the given ID.
 *
 * @param documentId The document's id.
 * @returns A BFTask*
 */
- (BFTask *)deleteDocument:(NSString *)documentId;

/**
 * Gets a list of all documents.
 *
 * @param limit The maximum number of documents to return.
 * @param offset The start offset.
 * @returns A BFTask* that will resolve to an NSDictionary containing a paginated list of documents.
 */
- (BFTask *)getDocumentsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset;

/**
 * Gets extractions for the specific document
 *
 * @param documentId The document's id.
 * @returns A BFTask that will resolve to an NSDictionary containing the extractions for the document.
 */
- (BFTask *)getExtractionsForDocument:(NSString *)documentId;

/**
 * Gets the extractions for the specific document, including the incubation extractions (see
 * http://developer.gini.net/gini-api/html/incubator.html for details on incubating extractions).
 *
 * @param document  The document's unique identifier.
 * @returns A BFTask that will resolve to an NSDictionary containing the extractions for the document.
 */
- (BFTask *)getIncubatorExtractionsForDocument:(NSString *)documentId;

/**
 * Submit feedback for the document on a specific label.
 *
 * @param documentId The document's id.
 * @param label The extraction label to be updated.
 * @param value The new value for the extraction.
 * @param boundingBox The new bounding box for the updated extraction (optional).
 * @returns A BFTask*
 */
- (BFTask *)submitFeedbackForDocument:(NSString *)documentId label:(NSString *)label value:(NSString *)value boundingBox:(NSDictionary *)boundingBox;

/**
 * Delete a specific feedback label for the document.
 * 
 * @param documentId The document's id.
 * @param label The extraction label to be deleted.
 * @returns A BFTask*
 */
- (BFTask *)deleteFeedbackForDocument:(NSString *)documentId label:(NSString *)label;

/**
 * Searches for documents containing the given words.
 * 
 * @param searchTerm The search term(s) separated by space.
 * @param limit The number of results per page.
 * @param offset The start offset.
 * @param docType Restrict the search to a specific doctype.
 * @returns A BFTask* that will resolve to an NSDictionary containing documents found.
 */
- (BFTask *)search:(NSString *)searchTerm limit:(NSUInteger)limit offset:(NSUInteger)offset docType:(NSString *)docType;

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
