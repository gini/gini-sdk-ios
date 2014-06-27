Upload an image and get extractions
-----------------------------------

First of all, get the sdk instance that you previously added as a property of the app delegate: 

    GiniSDK *sdk = ((EXMAppDelegate *)[[UIApplication sharedApplication] delegate]).giniSDK;
    
(Please notice that you should use the name of the class of your app delegate instead of `EXMAppDelegate`).

Afterwards, you can use the session manager instance to log in the user.

    [sdk.sessionManager logIn]

The result of this log in is a BFTask*. Since tasks are easy chainable, you can login the user and afterwards upload the
image:

    UIImage *image = myImage; // assuming that you already got an image, e.g. from the Gini Vision library.
    GINIDocumentTaskManager *manager = sdk.documentTaskManager;

    [sdk.sessionManager logIn] continueWithSuccessBlock:^id(BFTask *task){
        return [manager createDocumentWithFilename:@"newFile" fromImage:image];
    }]

Usually you want to do something with the created document:
 
    UIImage *image = myImage; // assuming that you already got an image, e.g. from the Gini Vision library.
    GINIDocumentTaskManager *manager = sdk.documentTaskManager;
    
    [sdk.sessionManager logIn] continueWithSuccessBlock:^id(BFTask *loginTask){
        return [manager createDocumentWithFilename:@"newFile" fromImage:image];
    }] continueWithSuccessBlock:^id(BFTask *createTask){
        GINIDocument *document = createTask.result;
        // Do something with the document
    }];
 
And of course you are usually interested in the document's extractions. But the document's extractions are only
available when the document has been fully processed. Because of that, the Gini SDK provides a method to wait until the
document is fully processed:

    UIImage *image = myImage; // assuming that you already got an image, e.g. from the Gini Vision library.
    GINIDocumentTaskManager *manager = sdk.documentTaskManager;

    [[[[[sdk.sessionManager logIn] continueWithSuccessBlock:^id(BFTask *loginTask){
        return [manager createDocumentWithFilename:@"newFile" fromImage:image];
    }] continueWithSuccessBlock:^id(BFTask *createTask){
        GINIDocument *document = task.result;
        return [manager pollDocument:document];
    }] continueWithSuccessBlock:^id(BFTask *pollTask){
        GINIDocument *document = task.result;
        // And the document has a property extractions, which is another task that resolves to the extractions:
        return document.extractions;
    }] continueWithSuccessBlock:^id(BFTask *extractionsTask){
        NSDictionary *extractions = task.result;
        NSLog(@"extractions: %@", extractions);
        return nil;
    }];
    
The extractions object is now a dictionary, where the keys are the specific extraction as documented at 
[Gini's API documentation](http://developer.gini.net/gini-api/html/document_extractions.html#available-specific-extractions) and the values are
corresponding `GINIExtraction` objects.
