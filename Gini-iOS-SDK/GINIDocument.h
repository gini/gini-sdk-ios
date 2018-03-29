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
    GiniDocumentSourceClassificationSandwich
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
 * @param documentId            The document's unique identifier.
 * @param state                 The document's state.
 * @param pageCount             The number of pages of the document.
 * @param sourceClassification  The document's source classification.
 * @param documentManager       The document manager that is used to get the additional data, e.g. for the `extractions`
 *                              and `layout` property.
 */
- (instancetype)initWithId:(NSString *)documentId
                     state:(GiniDocumentState)state
                 pageCount:(NSUInteger)pageCount
      sourceClassification:(GiniDocumentSourceClassification)sourceClassification
           documentManager:(GINIDocumentTaskManager *)documentManager;

/**
 * The designated initializer.
 *
 * @param documentId            The document's unique identifier.
 * @param state                 The document's state.
 * @param pageCount             The number of pages of the document.
 * @param sourceClassification  The document's source classification.
 * @param documentManager       The document manager that is used to get the additional data, e.g. for the `extractions`
 *                              and `layout` property.
 * @param links                 The document list of related resources (extractions, document, processed or layout).
 */
- (instancetype)initWithId:(NSString *)documentId
                     state:(GiniDocumentState)state
                 pageCount:(NSUInteger)pageCount
      sourceClassification:(GiniDocumentSourceClassification)sourceClassification
           documentManager:(GINIDocumentTaskManager *)documentManager
                     links:(GINIDocumentLinks *)links;

@end
