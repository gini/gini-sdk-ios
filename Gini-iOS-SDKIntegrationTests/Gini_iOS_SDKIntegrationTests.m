/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import <Gini-iOS-SDK/GiniSDK.h>
#import "GINISessionManagerMock.h"


/** The default timeout when waiting for the result of a task (in seconds). */
float const GINITEST_DEFAULT_TIMEOUT = 15.0;

/**
 * Helper function to create a new `UIImage *` instance representing a test document.
 */
UIImage *GINIcreateTestDocument () {
    NSURL *dataPath = [[NSBundle bundleWithIdentifier:@"net.gini.Gini-iOS-SDKIntegrationTests"] URLForResource:@"invoice" withExtension:@"gif"];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:dataPath]];
}


SPEC_BEGIN(GiniSdkIntegration)

describe(@"The Gini SDK", ^{

    __block GiniSDK* sdk;

    beforeEach(^{
        sdk = [GiniSDK giniSDKWithAppURLScheme:@"gini-sdk-ios" clientID:@"gini-sdk-ios"];
        // We replace the session manager with a mock session manager, so we can use our own access token and bypass the
        // usual authentication flow.
        [sdk.injector setFactory:@selector(sessionManagerWithAccessToken:)
                              on:[GINISessionManagerMock class]
                          forKey:@protocol(GINISessionManager)
                withDependencies:@"accessToken", nil];
        // And we get the access token from a file.
        NSString *dataPath = [[NSBundle bundleWithIdentifier:@"net.gini.Gini-iOS-SDKIntegrationTests"] pathForResource:@"accessToken" ofType:@"txt"];
        NSString* content = [NSString stringWithContentsOfFile:dataPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        [sdk.injector setObject:[content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                         forKey:@"accessToken"];
    });

    it(@"should create a working instance", ^{
        [[sdk should] beKindOfClass:[GiniSDK class]];
    });

    it(@"should have a working session manager", ^{
        BFTask *task = [sdk.sessionManager getSession];
        [[task.result should] beKindOfClass:[GINISession class]];
    });

    it(@"should upload a document", ^{
        BFTask *uploadTask = [sdk.documentTaskManager createDocumentWithFilename:@"test.jpg" fromImage:GINIcreateTestDocument()];
        [[expectFutureValue(uploadTask.result) shouldEventuallyBeforeTimingOutAfter(GINITEST_DEFAULT_TIMEOUT)] beNonNil];
    });

    it(@"should delete a document", ^{
        __block GINIDocument *document;
        __block BOOL deleted = NO;
        UIImage *image = GINIcreateTestDocument();
        BFTask *deleteTask = [[sdk.documentTaskManager createDocumentWithFilename:@"test.jpg" fromImage:image] continueWithSuccessBlock:^id(BFTask *createTask) {
            document = (GINIDocument *)createTask.result;
            deleted = YES;
            return [sdk.documentTaskManager deleteDocument:createTask.result];
        }];

        [deleteTask waitUntilFinished];
        [[theValue(deleted) should] beYes];

        // Getting the document should now raise an error.
        BFTask *checkTask = [sdk.documentTaskManager getDocumentWithId:document.documentId];
        [checkTask waitUntilFinished];
        [checkTask continueWithBlock:^id(BFTask *task) {
            [[task.error should] beNonNil];
            [[task.result should] beNil];
            return nil;
        }];
    });

    it(@"should get extractions via the documentTaskManager", ^{
        BFTask *extractionsTask = [[[sdk.documentTaskManager createDocumentWithFilename:@"foobar.jpg" fromImage:GINIcreateTestDocument()] continueWithSuccessBlock:^id(BFTask *createTask) {
            [[createTask.result should] beNonNil];
            // Wait until the document is available.
            return [sdk.documentTaskManager pollDocument:createTask.result];
        }] continueWithSuccessBlock:^id(BFTask *pollTask) {
            [[pollTask.result should] beNonNil];
            return [sdk.documentTaskManager getExtractionsForDocument:pollTask.result];
        }];

        [extractionsTask waitUntilFinished];
        [[extractionsTask.error should] beNil];

        NSDictionary *result = extractionsTask.result;
        NSDictionary *extractions = result[@"extractions"];
        // This is the flaky part. The extractions respectively API may change, so it could be necessary to adapt this
        // tests in the future.
        [[[(GINIExtraction *)extractions[@"amountToPay"] value] should] equal:@"264.25:EUR"];
        [[[(GINIExtraction *)extractions[@"docType"] value] should] equal:@"Invoice"];
        [[[(GINIExtraction *)extractions[@"documentDate"] value] should] equal:@"2007-06-12"];
        [[[(GINIExtraction *)extractions[@"documentDomain"] value] should] equal:@"Other"];
        [[[(GINIExtraction *)extractions[@"invoiceId"] value] should] equal:@"2007061234"];
        [[[(GINIExtraction *)extractions[@"paymentState"] value] should] equal:@"Paid"];
        [[[(GINIExtraction *)extractions[@"phoneNumber"] value] should] equal:@"0123412345678"];
        [[[(GINIExtraction *)extractions[@"vatRegNumber"] value] should] equal:@"DE123456789"];
    });

    it(@"should get extractions via the document.extractions property", ^{
        BFTask *extractionsTask = [[[sdk.documentTaskManager createDocumentWithFilename:@"foobar.jpg" fromImage:GINIcreateTestDocument()] continueWithSuccessBlock:^id(BFTask *createTask) {
            [[createTask.result should] beNonNil];
            return [sdk.documentTaskManager pollDocument:createTask.result];
        }] continueWithSuccessBlock:^id(BFTask *pollTask) {
            [[pollTask.result should] beNonNil];
            GINIDocument *document = pollTask.result;
            return document.extractions;
        }];

        [extractionsTask waitUntilFinished];
        [[extractionsTask.error should] beNil];

        NSDictionary *extractions = extractionsTask.result;
        // This is the flaky part. The extractions respectively API may change, so it could be necessary to adapt this
        // tests in the future.
        [[[(GINIExtraction *)extractions[@"amountToPay"] value] should] equal:@"264.25:EUR"];
        [[[(GINIExtraction *)extractions[@"docType"] value] should] equal:@"Invoice"];
        [[[(GINIExtraction *)extractions[@"documentDate"] value] should] equal:@"2007-06-12"];
        [[[(GINIExtraction *)extractions[@"documentDomain"] value] should] equal:@"Other"];
        [[[(GINIExtraction *)extractions[@"invoiceId"] value] should] equal:@"2007061234"];
        [[[(GINIExtraction *)extractions[@"paymentState"] value] should] equal:@"Paid"];
        [[[(GINIExtraction *)extractions[@"phoneNumber"] value] should] equal:@"0123412345678"];
        [[[(GINIExtraction *)extractions[@"vatRegNumber"] value] should] equal:@"DE123456789"];

    });
});

SPEC_END
