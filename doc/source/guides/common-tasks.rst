.. _guide-common-tasks:

==================
Working with Tasks
==================

The Gini Android SDK makes heavy use of the concept of tasks. Tasks are convenient when you want to
do a series of tasks in a row, each one waiting waiting for the previous to finish (comparable to
Promises in JavaScript). This is a common pattern when working with Gini's remote API.
The Gini Android SDK uses `facebook's task implementation, which is called bolts <https://github.com/BoltsFramework/Bolts-Android>`_.
Before you continue reading this guide, we strongly encourage you to read the `short guide for the Bolts
framework <https://github.com/BoltsFramework/Bolts-Android/blob/master/Readme.md#tasks>`_.

Upload a document
=================

As the key aspect of the Gini API is to provide information extraction for analyzing documents, the
API is mainly built around the concept of documents. A document can be any written representation
of information, usually such as invoices, reminders, contracts and so on.

The Gini Android SDK supports creating documents from images, usually a picture of a paper document
which was taken with the device's camera. The following example shows how to create a new
document from a bitmap.


.. code-block:: java

    import net.gini.android.Gini;
    import net.gini.android.DocumentTaskManager;
    import net.gini.android.models.Document;
    
    ...
    
    // Assuming that `gini` is an instance of the `Gini` facade class and `bitmap` is an instance of Android's
    // Bitmap class, e.g. from a picture taken by the camera.
    
    DocumentTaskManager documentTaskManager = gini.getDocumentTaskManager();
    documentTaskManager.createDocument(bitmap, "myFirstDocument.jpg", null, 1).onSuccess(new Continuation<Document, Void>() {
                @Override
                public Void then(Task<Document> task) throws Exception {
                    Document document = task.getResult();
                    Log.d("gini", "Created document with ID " + document.getId());
                    return null;
                }
    });

Working with optional arguments
-------------------------------

You may have noticed that we used ``null`` as the argument for the document's doctype in the example
above. This is a completely valid thing to do since the argument is annoted with the ``Nullable``
annotation (``@org.jetbrains.annotations.Nullable``). All methods that accept null arguments use the
``@Nullable`` annotation for those arguments. Consider all arguments which do not have the ``@Nullable``
annotation as mandatory. The method will raise a ``NullPointerException`` if you pass null to such
arguments.

Read on to find out how to get the extractions from a document.

Getting extractions
===================

After you have successfully created a new document, you most likely want to get the extractions for
the document. Gini needs to process your document first before you can fetch the document's
extractions. Effectively this means that you won't get any extractions before the document is fully
processed. The processing time may vary, usually it is in the range of a couple of seconds, but
blurred or slightly rotated images are known to drasticly increase the processing time. 

The DocumentTaskManager provides the ``pollDocument`` and ``getExtractions`` methods which can be used
to fetch the extractions after the processing of the document is completed. The following example shows 
how to achieve this in detail.

.. code-block:: java

        import net.gini.android.Gini;
        import net.gini.android.DocumentTaskManager;
        import net.gini.android.models.Document;
        import net.gini.android.models.SpecificExtraction;
        
        
        ...
        
        
        // Assuming that `gini` is an instance of the `Gini` facade class and `document` is an instance
        // of the `Document` class as returned by `createDocument(...)`.
        final DocumentTaskManager documentTaskManager = gini.getDocumentTaskManager();
        documentTaskManager.pollDocument(document).
        onSuccessTask(new Continuation<Document, Task<Map<String, SpecificExtraction>>>() {
            @Override
            public Object then(Task<Document> task) throws Exception {
                final Document document = task.getResult();
                return documentTaskManager.getExtractions(document);
            }
        }).
        onSuccess(new Continuation<Map<String, SpecificExtraction>, Void>() {
            @Override
            public Void then(Task<Map<String, SpecificExtraction>> task) {
                final Map<String, SpecificExtraction> extractions = task.getResult();
                // Do something with the extractions.
                return null;
            }
        });

Sending feedback
================

Depending on your use case your app probably presents the extractions to the user and give her the opportunity to correct them. Yes, there *could be errors*.
We do our best to prevent them - but It's more unlikely to happen if your app is sending us feedback for the extractions we have delivered. Your app should send feedback
only for the extractions the *user has seen and accepted*. Feedback should be send for corrected extractions **and** for *correct extractions*.
The code example below shows how to correct extractions and send feedback.

.. code-block:: java

        final Task<Map<String, SpecificExtraction>> retrievedExtractions // provided
        final Document document // provided

        final Map<String, SpecificExtraction> extractions = retrieveExtractions.getResult();
        // amounTo pay was wrong, we'll correct it
        SpecificExtraction amountToPay = extractions.get("amountToPay");
        amountToPay.setValue("31:00");
        
        // we should send only feedback for extractions we have seen and accepted
        // all extractions we've seen were correct except amountToPay
        Map<String, SpecificExtraction> feedback = new HashMap<String, SpecificExtraction>();
        feedback.put("iban", extractions.get("iban"));
        feedback.put("amountToPay", amountToPay);
        feedback.put("bic", extractions.get("bic"));
        feedback.put("senderName", extractions.get("senderName"));

        final Task<Document> sendFeedback = documentTaskManager.sendFeedbackForExtractions(document, feedback);
        sendFeedback.waitForCompletion();

Report an extraction error to Gini
==================================

If the processing result for a document was not satisfactory for the user, your app can give her the opportunity to report a error directly to Gini. Gini will return
a error identifier which can be used to refer to it towards the Gini support. The user must agree that Gini can use this document for debugging and error analysis.
The code example below shows how to send the error report to Gini.

.. code-block:: java

        final Document document // provided
        documentTaskManager.reportDocument(document, "short summary", "detailed description");

Handling SDK errors
===================

Currently, the Gini Android SDK doesn't have intelligent error-handling mechanisms. All errors that
occure during executing a task are handed over transparently. You can react on those errors in the
``onError(...)`` method of the task. We may add better error-handling mechanisms in the future. At
the moment we recommend checking the network status when a task failed and retrying the task.
