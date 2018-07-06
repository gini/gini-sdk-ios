.. _guide-updating-to-1.0:

===============
Updating to 1.0
===============

What's new?
=================

* Added **Multipage** support, which introduces a new way to analyze documents (see `Partial and Composite documents`_ section below).
* Updated **Bolts** to 1.9 (see more details `here <https://github.com/BoltsFramework/Bolts-ObjC/blob/master/CHANGELOG.md>`_)
* Now it is possible to provide a cancellation token for every task

Partial and Composite documents
=================

Now - for every page - a **Partial** document has to be created using the
`createPartialDocumentWithFilename:fromData:docType:cancellationToken:` method, even if only one page is going to be analyzed.
Once you have created one or several partial documents, you have to create a **Composite** document. To do so, you just need to pass an array of `GINIPartialDocumentInfo` (in the correct order) to the `createCompositeDocumentWithPartialDocumentsInfo:fileName:docType:cancellationToken:`` method.

Finally, you can get the extractions for that **Composite** document using the `getExtractionsForDocument:` method in the `GINIDocumentTaskManager`.

Breaking changes
=================

The new **Bolts** version introduces a lot of improvements and bug fixes, but also some breaking changes in the syntaxis for _Swift_ projects.
* `continue()` is now `continueWith(block:)`.
* `continue(successBlock:)` is now `continueOnSuccessWith(block:)`.
* And now every `BFTask` has a specific type for the result, `BFTask<ResultType>`. i.e: `BFTask<GINIDocument>`.


Deprecated
=================

* In the `GINIDocument`:
  - `extractions` -> `GINIDocumentTaskManager.getExtractionsForDocument`.
  - `candidates` -> `GINIDocumentTaskManager.getCandidatesForDocument`.
  - `layout` -> `GINIDocumentTaskManager.getExtractionsForDocument`.
  - `previewWithSize:forPage` -> `GINIDocumentTaskManager.gerPreviewForPage:ofDocument:withSize:`.
  - `initWithId:state:pageCount:sourceClassification:documentManager:` deprecated since the `GINIDocumentTaskManager` won't be part of the `GINIDocument` in the future.

* In the `GINIDocumentTaskManager`:
  - `createDocumentWithFilename:fromImage:docType:` and `createDocumentWithFilename:fromData:docType:`. Both have been replaced with the methods mentioned above.
  - `updateDocument:`. Since the extractions task is deprecated in the `GINIDocument`, now they have to be specified  in the `updateDocument:updatedExtractions:cancellationToken:` method.
  - `deleteDocument:`. Now there is an specific method for both partial and composite documents, `deleteCompositeDocumentWithId:cancellationToken:` and `deletePartialDocumentWithId:cancellationToken`.
