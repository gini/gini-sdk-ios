/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "GINIAPIManager.h"
#import "GINIDocumentLinks.h"

@class GINIDocumentTaskManager;

/**
 * The possible states of documents. The availability of a document's extractions, layout and preview images are
 * depending on the document's state.
 */
typedef NS_ENUM(NSUInteger, GiniDocumentState) {
    /// The document is not fully processed yet. There are no extractions, layout or preview images available.
    GiniDocumentStatePending,
    /// The document is fully processed. Preview images, extractions and the layout are available.
    GiniDocumentStateComplete,
    /// The document is processed, but there was an error during processing, so it is very likely that neither the
    /// extractions, layout or preview images are available.
    GiniDocumentStateError
};

/**
 * The possible source classifications of a document.
 */
typedef NS_ENUM(NSUInteger, GiniDocumentSourceClassification) {
    /// A scanned document, usually the result of a photographed or scanned document.
    GiniDocumentSourceClassificationScanned,
    /// A "native" document, usually a PDF document.
    GiniDocumentSourceClassificationNative,
    /// A text document.
    GiniDocumentSourceClassificationText,
    /// A scanned document with the ocr information on top.
    GiniDocumentSourceClassificationSandwich,
    /// A composite document created by one or several partial documents
    GiniDocumentSourceClassificationComposite
};

/**
 * The data model for a document.
 */
@interface GINIDocument : NSObject

/// The document's unique identifier.
@property (readonly) NSString *documentId;
/// The processing state of the document.
@property (readonly) GiniDocumentState state;
/// The number of pages.
@property NSUInteger pageCount;
/// The document's file name.
@property NSString *filename;
/// The document's creation date.
@property NSDate *creationDate;
/// The document's source classification.
@property GiniDocumentSourceClassification sourceClassification;
/// Links to related resources, such as extractions, document, processed or layout.
@property (readonly) GINIDocumentLinks *links;
/// (Optional) Array containing the path of every composite document
@property (readonly) NSArray<NSString *> *compositeDocuments;
/// (Optional) Array containing the path of every partial document info
@property (readonly) NSArray<GINIPartialDocumentInfo *> *partialDocumentInfos;
/// A `BFTask*` resolving to a mapping with extractions (extraction name as key).
@property (readonly) BFTask *extractions __attribute__((deprecated("use `GINIDocumentTaskManager.getExtractionsForDocument:` method instead")));
/// A `BFTask*` resolving to a mapping with the candidates (extraction entity as key).
@property (readonly) BFTask *candidates __attribute__((deprecated("use `GINIDocumentTaskManager.getCandidatesForDocument:` method instead")));
/// A `BFTask*` resolving to a dictionary with the layout of the document.
@property (readonly) BFTask *layout __attribute__((deprecated("use `GINIDocumentTaskManager.getLayoutForDocument:` method instead")));


/**
 * Factory to create a new document.
 *
 * @param apiResponse           A dictionary containing the document information. Usually the response of the Gini API.
 * @param documentManager       The document manager that is used to get the additional data, e.g. for the `extractions`
 *
 */
+ (instancetype)documentFromAPIResponse:(NSDictionary *)apiResponse withDocumentManager:(GINIDocumentTaskManager *)documentManager;

/**
 * The designated initializer.
 *
 * @param documentId            The document's unique identifier.
 * @param state                 The document's state.
 * @param pageCount             The number of pages of the document.
 * @param sourceClassification  The document's source classification.
 * @param links                 The document list of related resources (extractions, document, processed or layout).
 * @param compositeDocuments    (Optional) Array containing the path of every composite document
 * @param partialDocumentInfos  (Optional) Array containing the path of every partial document info
 */
- (instancetype)initWithId:(NSString *)documentId
                     state:(GiniDocumentState)state
                 pageCount:(NSUInteger)pageCount
      sourceClassification:(GiniDocumentSourceClassification)sourceClassification
                     links:(GINIDocumentLinks *)links
        compositeDocuments:(NSArray<NSString *> *)compositeDocuments
      partialDocumentInfos:(NSArray<GINIPartialDocumentInfo *> *)partialDocumentInfos;

/**
 * The designated initializer.
 *
 * @param documentId            The document's unique identifier.
 * @param state                 The document's state.
 * @param pageCount             The number of pages of the document.
 * @param sourceClassification  The document's source classification.
 * @param documentManager       The document manager that is used to get the additional data, e.g. for the `extractions`
 */
- (instancetype)initWithId:(NSString *)documentId
                     state:(GiniDocumentState)state
                 pageCount:(NSUInteger)pageCount
      sourceClassification:(GiniDocumentSourceClassification)sourceClassification
           documentManager:(GINIDocumentTaskManager *)documentManager __attribute__((deprecated("use `initWithId:state:pageCount:sourceClassification:links:compositeDocuments:partialDocuments:` initializer instead")));

/**
 * Gets the preview image for the given page.
 *
 * @param size              The size of the rendered preview. Please notice that those sizes are the maximum sizes of the
 *                          renderings, the actual image can have smaller dimensions.
 *
 * @param page              The page for which the preview is rendered. Please notice that only the first 10 pages of a
 *                          document are processed by the Gini API.
 */
- (BFTask *)previewWithSize:(GiniApiPreviewSize)size
                    forPage:(NSUInteger)page __attribute__((deprecated("Use `GINIDocumentTaskManager.getPreviewForPage:ofDocument:withSize:` method instead")));

@end
