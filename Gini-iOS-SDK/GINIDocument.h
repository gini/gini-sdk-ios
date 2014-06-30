/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "GINIAPIManager.h"

@class GINIDocumentTaskManager;

/**
 * The possible states of documents.
 * TODO: probably some explanation what the document's state is.
 */
typedef NS_ENUM(NSUInteger, GiniDocumentState) {
    /// The document is not fully processed yet.
    GiniDocumentStatePending,
    /// The document is fully processed.
    GiniDocumentStateComplete,
    /// The document is processed, but there was an error.
    GiniDocumentStateError
};

/**
 * The possible source classifications of a document.
 * TODO some explanation what a source classification actually is.
 */
typedef NS_ENUM(NSUInteger, GiniDocumentSourceClassification) {
    /// A scanned document, usually the result of a photographed or scanned document.
    GiniDocumentSourceClassificationScanned,
    /// A "native" document, usually a PDF document.
    GiniDocumentSourceClassificationNative
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
/// A `BFTask*` resolving to a mapping with extractions (extraction name as key).
@property (readonly) BFTask *extractions;
/// A `BFTask*` resolving to a mapping with the candidates (extraction entity as key).
@property (readonly) BFTask *candidates;
/// A `BFTask*` resolving to a dictionary with the layout of the document.
@property (readonly) BFTask *layout;

/**
 * Factory to create a new document.
 *
 * @param apiResponse       A dictionary containing the document information. Usually the response of the Gini API.
 *
 * @param documentManager   The document manager instance that is used to communicate with the Gini API.
 */
+ (instancetype)documentFromAPIResponse:(NSDictionary *)apiResponse withDocumentManager:(GINIDocumentTaskManager *)documentManager;

/**
 * The designated initializer.
 *
 * @param documentId        The document's unique identifier.
 *
 * @param state             The document's state.
 *
 * @param documentManager   The document manager that is used to get the additional data, e.g. for the `extractions`
 *                          and `layout` property.
 */
- (instancetype)initWithId:(NSString *)documentId state:(GiniDocumentState)state pageCount:(NSUInteger)pageCount sourceClassification:(GiniDocumentSourceClassification)sourceClassification documentManager:(GINIDocumentTaskManager *)documentManager;

/**
 * Gets the preview image for the given page.
 *
 * @param size              The size of the rendered preview. Please notice that those sizes are the maximum sizes of the
 *                          renderings, the actual image can have smaller dimensions.
 *
 * @param page              The page for which the preview is rendered. Please notice that only the first 10 pages of a
 *                          document are processed by the Gini API.
 */
- (BFTask *)previewWithSize:(GiniApiPreviewSize)size forPage:(NSUInteger)page;
@end
