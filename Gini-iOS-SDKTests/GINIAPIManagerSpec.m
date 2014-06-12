/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import <UIKit/UIKit.h>
#import "GINIAPIManager.h"
#import "GINIURLSessionMock.h"
#import "GINIAPIManagerRequestFactory.h"
#import "GINISessionManagerMock.h"
#import "BFTask.h"
#import "GINIURLResponse.h"


SPEC_BEGIN(GINIAPIManagerSpec)

describe(@"The GINIAPIManager", ^{
    __block GINIAPIManager *apiManager;
    __block GINIURLSessionMock *urlSessionMock;

    /**
     * Many tests do requests to the Gini API. This helper function does some tests that all HTTP requests have in
     * common:
     *   - It checks that the request is to the given URL.
     *   - It checks that the request sent the correct credentials.
     *   - It checks that only the expected amount of HTTP requests are done.
     */
    __block void (^checkRequest)(NSString *URL, NSUInteger requestCount) = ^(NSString *URL, NSUInteger requestCount) {
        // Check for the correct URL.
        NSURLRequest *request = urlSessionMock.lastRequest;
        [[request shouldNot] beNil];
        [[[[request URL] absoluteString] should] equal:URL];
        // Check for the correct authorization headers
        [[[request valueForHTTPHeaderField:@"Authorization"] should] equal:[@"Bearer " stringByAppendingString:@"1234"]];
        // Check for the correct count of requests
        [[theValue(urlSessionMock.requestCount == requestCount) should] beYes];
    };

    /**
     * Many tests do requests to the Gini API. This helper function does some tests that all HTTP requests have in
     * common:
     *   - It checks that the request is to the given URL.
     *   - It checks that the request has the correct Accept header for JSON data.
     *   - It checks that the request sent the correct credentials.
     *   - It checks that only the expected amount of HTTP requests are done.
     */
    __block void (^checkJSONRequest)(NSString *URL, NSUInteger requestCount) = ^(NSString *URL, NSUInteger requestCount){
        checkRequest(URL, requestCount);
        // Check for the correct URL.
        NSURLRequest *request = urlSessionMock.lastRequest;
        // Check for the correct content type
        [[[request valueForHTTPHeaderField:@"Accept"] should] equal:@"application/vnd.gini.v1+json"];
    };

    /**
     * Many tests require a document id. This document id can be used for such tests.
     */
    __block NSString *documentId;

    beforeEach(^{
        // Create an instance of the apiManager that can be used in every test. This instance does not use a real
        // GINIURLSession but instead uses a mock that provides some handy functionality to test the HTTP communication.
        GINISessionManagerMock *sessionManager = [GINISessionManagerMock sessionManagerWithAccessToken:@"1234"];
        GINIAPIManagerRequestFactory *requestFactory = [[GINIAPIManagerRequestFactory alloc] initWithSessionManager:(GINISessionManager*)sessionManager];
        urlSessionMock = [GINIURLSessionMock new];
        apiManager = [[GINIAPIManager alloc] initWithURLSession:urlSessionMock requestFactory:requestFactory baseURL:[NSURL URLWithString:@"https://api.gini.net"]];
        documentId = @"Foobar"; // TODO
    });

    it(@"should throw an exception when initalized with the wrong types", ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://example.com"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
        [[theBlock(^{
            [[GINIAPIManager alloc] initWithURLSession:nil requestFactory:nil baseURL:nil ];
        }) should] raise];

        [[theBlock(^{
            [[GINIAPIManager alloc] initWithURLSession:nil requestFactory:nil baseURL:baseURL];
        }) should] raise];

        [[theBlock(^{
            [[GINIAPIManager alloc] initWithURLSession:nil requestFactory:(id)@"foo" baseURL:baseURL];
        }) should] raise];
#pragma clang diagnostic pop
        // TODO
    });

    context(@"The getDocument method", ^{
        it(@"should throw an error if the wrong argument is given", ^{
            [[theBlock(^{
                [apiManager getDocument:nil];
            }) should] raise];
        });

        it(@"should return a BFTask*", ^{
            [[[apiManager getDocument:documentId] should] beKindOfClass:[BFTask class]];
        });

        it(@"should do the correct request to the Gini API", ^{
            [apiManager getDocument:documentId];
            checkJSONRequest(@"https://api.gini.net/documents/Foobar", 1);
        });

        it(@"should return the correct data", ^{
            NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"document" withExtension:@"json"];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:json];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:@"https://api.gini.net/documents/Foobar"];
            BFTask *documentTask = [apiManager getDocument:documentId];
            [[theValue(documentTask.isCompleted) should] beYes];
            [[documentTask.error should] beNil];
            [[documentTask.result should] beKindOfClass:[NSDictionary class]];
            [[documentTask.result should] equal:json];
        });
    });

    context(@"The getPreviewForPage:ofDocument:withSize method", ^{
        it(@"should return a BFTask*", ^{
            [[[apiManager getPreviewForPage:1 ofDocument:documentId withSize:GiniApiPreviewSizeMedium] should] beKindOfClass:[BFTask class]];
        });

        it(@"should do the correct request to the Gini API", ^{
            [apiManager getPreviewForPage:1 ofDocument:documentId withSize:GiniApiPreviewSizeMedium];
            checkRequest(@"https://api.gini.net/documents/Foobar/pages/1/750x900", 1);

            [apiManager getPreviewForPage:1 ofDocument:documentId withSize:GiniApiPreviewSizeBig];
            checkRequest(@"https://api.gini.net/documents/Foobar/pages/1/1280x1810", 2);
        });

        it(@"should return the correct data", ^{
            NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"yoda" withExtension:@"jpg"];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:dataPath];
            [urlSessionMock setResponse:[BFTask taskWithResult:response]
                                 forURL:@"https://api.gini.net/documents/Foobar/pages/1/750x900"];
            BFTask *imageTask = [apiManager getPreviewForPage:1 ofDocument:documentId withSize:GiniApiPreviewSizeMedium];
            [[theValue(imageTask.isCompleted) should] beYes];
            [[imageTask.error should] beNil];
            [[imageTask.result should] beKindOfClass:[UIImage class]];
        });
    });

    context(@"The uploadDocumentWithData:contentType:fileName method", ^{
        it(@"should return a BFTask*", ^{
            [[[apiManager uploadDocumentWithData:[NSData new] contentType:@"image/png" fileName:@"foo.png"] should] beKindOfClass:[BFTask class]];
        });

        it(@"should do the correct request to the GINI API", ^{
            NSString *uploadURL = @"https://api.gini.net/documents/?filename=foo.png";
            NSString *createdDocumentsURL = @"https://api.gini.net/documents/Foobar";
            NSHTTPURLResponse *nsURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:uploadURL]
                                                                           statusCode:201
                                                                          HTTPVersion:@"1.1"
                                                                         headerFields:@{
                                                                             @"Location": createdDocumentsURL,
                                                                             @"Content-Type": @"application/vnd.gini.v1+json"
                                                                         }];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nsURLResponse data:[NSData new]];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:uploadURL];
            [apiManager uploadDocumentWithData:[NSData new] contentType:@"image/png" fileName:@"foo.png"];
            checkRequest(createdDocumentsURL, 2);
        });
    });
});


SPEC_END