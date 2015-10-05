.. _guide-common-tasks:

==================
Working with Tasks
==================

The Gini iOS SDK makes heavy use of the concept of tasks. Tasks are convenient when you want to
do a series of tasks in a row, each one waiting waiting for the previous to finish (comparable to
Promises in JavaScript). This is a common pattern when working with Gini's remote API.
The Gini iOS SDK uses `facebook's task implementation, which is called bolts <https://github.com/BoltsFramework/Bolts-iOS>`_.
Before you continue reading this guide, we strongly encourage you to read the `short guide for the Bolts
framework <https://github.com/BoltsFramework/Bolts-iOS/blob/master/README.md#tasks>`_.

Upload a document
=================

As the key aspect of the Gini API is to provide information extraction for analyzing documents, the
API is mainly built around the concept of documents. A document can be any written representation
of information, usually such as invoices, reminders, contracts and so on.

The Gini iOS SDK supports creating documents from images, usually a picture of a paper document
which was taken with the device's camera. The following example shows how to create a new
document from an image.


.. code-block:: obj-c

    #import <Gini-iOS-SDK/GiniSDK.h>

    ...

    // Assuming that `gini` is an instance of the `GiniSDK` facade class and `image` is an `UIImage` instance,
    // e.g. from a picture taken by the camera.

    GINIDocumentTaskManager *documentTaskManager = gini.documentTaskManager;
    [[documentTaskManager createDocumentWithFilename:@"myFirstDocument" fromImage:image] continueWithSuccessBlock:^id(BFTask *task) {
        GINIDocument *document = task.result;
        NSLog(@"Created document with ID %@", document.documentId);
        return nil;
    }];

    ...

Read on to find out how to get the extractions from a document.

Getting extractions
===================

After you have successfully created a new document, you most likely want to get the extractions for
the document. Gini needs to process your document first before you can fetch the document's
extractions. Effectively this means that you won't get any extractions before the document is fully
processed. The processing time may vary, usually it is in the range of a couple of seconds, but
blurred or slightly rotated images are known to drasticly increase the processing time. 

The ``GINIDocument`` class provides the ``extractions`` method which can be used
to fetch the extractions. The method waits until the processing of the document is completed. The following example shows 
how to achieve this in detail.

.. code-block:: obj-c

    // Assuming `document` is an instance of the `GINIDocument` class as returned by `createDocumentWithFilename:fromImage:`.

    [[document extractions] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *extractions = task.result;
        // Do somethin with the extractions.
        return nil;
    }];

.. _feedback-task:

Sending feedback
================

Depending on your use case your app probably presents the extractions to the user and give her the opportunity to correct them. Yes, there *could be errors*.
We do our best to prevent them - but it's more unlikely to happen if your app is sending us feedback for the extractions we have delivered. Your app should send feedback
only for the extractions the *user has seen and accepted*. Feedback should be send for corrected extractions **and** for *correct extractions*.
The code example below shows how to correct extractions and send feedback.

.. hint:: Feedback should only be send for extractions which were seen and accepted.

.. code-block:: obj-c

    // Assuming `document` is an instance of the `GINIDocument` class as returned by `createDocumentWithFilename:fromImage:`,
    // `retrievedExtractions` is an instance of the `BFTask` class as returned by ``[document extractions]`` and
    // `gini` is an instance of the `GiniSDK` facade class.
    
    NSMutableDictionary *extractions = retrievedExtractions.result;
    
    // 'amountToPay' was wrong, we'll correct it.
    GINIExtraction *amountToPay = (GINIExtraction *)extractions[@"amountToPay"];
    [amountToPay setValue:@"31:00"];
    
    GINIDocumentTaskManager *documentTaskManager = gini.documentTaskManager;
    BFTask *feedbackTask = [documentTaskManager updateDocument:document];

Report an extraction error to Gini
==================================

If the processing result for a document was not satisfactory for the user, your app can give her the opportunity to report an error directly to Gini. Gini will return
an error identifier which can be used to refer to it towards the Gini support. The user must agree that Gini can use this document for debugging and error analysis.
The code example below shows how to send the error report to Gini.

.. code-block:: obj-c

    // Assuming that `gini` is an instance of the `GiniSDK` facade class and
    // `document` is an instance of the `GINIDocument` class as returned by `createDocumentWithFilename:fromImage:`. 

    GINIAPIManager *apiManager = gini.APIManager;
    BFTask *reportTask = [apiManager reportErrorForDocument:document.documentId summary:@"short summary" description:@"detailed description"];

Handling SDK errors
===================

Currently, the Gini iOS SDK doesn't have intelligent error-handling mechanisms. All errors that
occure during executing a task are handed over transparently. You can react on those errors by checking ``task.error`` in the block of the task. 
We may add better error-handling mechanisms in the future. At the moment we recommend checking the network status when a task failed and retrying the task.
