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
#import "NSString+GINIAdditions.h"


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

    context(@"The getPagesForDocument method", ^{
        it(@"should return a BFTask*", ^{
            [[[apiManager getPagesForDocument:documentId] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager getPagesForDocument:documentId];
            checkJSONRequest(@"https://api.gini.net/documents/Foobar/pages", 1);
        });
        
        it(@"should do a GET request", ^{
            [apiManager getPagesForDocument:documentId];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"GET"];
        });
        
        it(@"should return the correct data", ^{
            NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"pages" withExtension:@"json"];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:json];
            [urlSessionMock setResponse:[BFTask taskWithResult:response]
                                 forURL:@"https://api.gini.net/documents/Foobar/pages"];
            BFTask *pagesTask = [apiManager getPagesForDocument:documentId];
            [[pagesTask.error should] beNil];
            [[pagesTask.result should] beKindOfClass:[NSArray class]];
            [[pagesTask.result should] equal:json];
        });
    });
    
    context(@"The getLayoutForDocument method", ^{
        it(@"should return a BFTask*", ^{
            [[[apiManager getLayoutForDocument:documentId] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager getLayoutForDocument:documentId];
            checkJSONRequest(@"https://api.gini.net/documents/Foobar/layout", 1);
        });
        
        it(@"should do a GET request", ^{
            [apiManager getLayoutForDocument:documentId];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"GET"];
        });
        
        it(@"should return the correct data", ^{
            NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"layout" withExtension:@"json"];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:json];
            [urlSessionMock setResponse:[BFTask taskWithResult:response]
                                 forURL:@"https://api.gini.net/documents/Foobar/layout"];
            BFTask *layoutTask = [apiManager getLayoutForDocument:documentId];
            [[layoutTask.error should] beNil];
            [[layoutTask.result should] beKindOfClass:[NSDictionary class]];
            [[layoutTask.result should] equal:json];
        });
    });
    
    context(@"The uploadDocumentWithData:contentType:fileName:docType method", ^{
        it(@"should return a BFTask*", ^{
            [[[apiManager uploadDocumentWithData:[NSData new] contentType:@"image/png" fileName:@"foo.png" docType:nil] should] beKindOfClass:[BFTask class]];
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
            [apiManager uploadDocumentWithData:[NSData new] contentType:@"image/png" fileName:@"foo.png" docType:nil];
            checkRequest(createdDocumentsURL, 2);
        });

        it(@"should accept a doctype hint", ^{
            NSString *uploadURL = @"https://api.gini.net/documents/?filename=foo.png&doctype=Invoice";
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
            [apiManager uploadDocumentWithData:[NSData new] contentType:@"image/png" fileName:@"foo.png" docType:@"Invoice"];
            checkRequest(createdDocumentsURL, 2);
        });
    });
    
    context(@"The deleteDocument method", ^{
        it(@"should return a BFTask", ^{
            [[[apiManager deleteDocument:documentId] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager deleteDocument:documentId];
            checkRequest(@"https://api.gini.net/documents/Foobar", 1);
        });

        it(@"should do a DELETE request", ^{
            [apiManager deleteDocument:documentId];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"DELETE"];
        });

        it(@"should react correctly on the HTTP response", ^{
            NSString *documentURL = @"https://api.gini.net/documents/Foobar";
            NSHTTPURLResponse *nsURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:documentURL]
                                                                           statusCode:204
                                                                          HTTPVersion:@"1.1"
                                                                         headerFields:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nsURLResponse];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:documentURL];
            BFTask *documentTask = [apiManager deleteDocument:documentId];
            [[documentTask.error should] beNil];
            [[documentTask.result should] beNil];
        });
    });
    
    context(@"The getDocumentsWithLimit:offset method", ^{
        it(@"should return a BFTask", ^{
            [[[apiManager getDocumentsWithLimit:10 offset:0] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager getDocumentsWithLimit:10 offset:0];
            checkJSONRequest(@"https://api.gini.net/documents?limit=10&offset=0", 1);
        });
        
        it(@"should do a GET request", ^{
            [apiManager getDocumentsWithLimit:10 offset:0];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"GET"];
        });
        
        it(@"should react correctly on the HTTP response", ^{
            NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"documents" withExtension:@"json"];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:json];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:@"https://api.gini.net/documents?limit=10&offset=0"];
            BFTask *documentsTask = [apiManager getDocumentsWithLimit:10 offset:0];
            [[documentsTask.error should] beNil];
            [[documentsTask.result should] beKindOfClass:[NSDictionary class]];
            [[documentsTask.result should] equal:json];
        });
    });
    
    context(@"The getExtractionsForDocument method", ^{
        it(@"should return a BFTask", ^{
            [[[apiManager getExtractionsForDocument:documentId] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager getExtractionsForDocument:documentId];
            checkJSONRequest(@"https://api.gini.net/documents/Foobar/extractions", 1);
        });

        it(@"should do a GET request", ^{
            [apiManager getExtractionsForDocument:documentId];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"GET"];
        });
        
        it(@"should react correctly on the HTTP response", ^{
            NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"extractions" withExtension:@"json"];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:json];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:@"https://api.gini.net/documents/Foobar/extractions"];
            BFTask *extractionsTask = [apiManager getExtractionsForDocument:documentId];
            [[extractionsTask.error should] beNil];
            [[extractionsTask.result should] beKindOfClass:[NSDictionary class]];
            [[extractionsTask.result should] equal:json];
        });
    });
    
    context(@"The submitFeedbackForDocument:label:value:boundingBox method", ^{
        NSString *label = @"amountToPay";
        NSString *value = @"29.0:EUR";
        NSDictionary *boundingBox = @{@"page": @1, @"height": @14, @"left": @405, @"top": @421, @"width": @36};
        
        it(@"should return a BFTask", ^{
            [[[apiManager submitFeedbackForDocument:documentId label:label value:value boundingBox:boundingBox] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should perform a PUT request", ^{
            [apiManager submitFeedbackForDocument:documentId label:label value:value boundingBox:boundingBox];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"PUT"];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager submitFeedbackForDocument:documentId label:label value:value boundingBox:boundingBox];
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/Foobar/extractions/%@", label];
            checkRequest(urlString, 1);
        });
        
        it(@"should react correctly on the HTTP response", ^{
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/Foobar/extractions/%@", label];
            NSHTTPURLResponse *nsURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                           statusCode:204
                                                                          HTTPVersion:@"1.1"
                                                                         headerFields:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nsURLResponse];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:urlString];
            BFTask *submitFeedbackTask = [apiManager submitFeedbackForDocument:documentId
                                                                         label:label
                                                                         value:value
                                                                   boundingBox:boundingBox];
            [[submitFeedbackTask.error should] beNil];
            [[submitFeedbackTask.result should] beNil];
        });
    });
    
    context(@"The deleteFeedbackForDocument:label method", ^{
        NSString *label = @"amountToPay";
        
        it(@"should return a BFTask", ^{
            [[[apiManager deleteFeedbackForDocument:documentId label:label] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should perform a DELETE request", ^{
            [apiManager deleteFeedbackForDocument:documentId label:label];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"DELETE"];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager deleteFeedbackForDocument:documentId label:label];
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/Foobar/extractions/%@", label];
            checkRequest(urlString, 1);
        });
        
        it(@"should react correctly on the HTTP response", ^{
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/Foobar/extractions/%@", label];
            NSHTTPURLResponse *nsURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                           statusCode:204
                                                                          HTTPVersion:@"1.1"
                                                                         headerFields:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nsURLResponse];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:urlString];
            BFTask *documentTask = [apiManager deleteFeedbackForDocument:documentId label:label];
            [[documentTask.error should] beNil];
            [[documentTask.result should] beNil];
        });
    });
    
    context(@"The search method", ^{
        NSString *searchTerm = @"kitten";
        NSString *docType = @"invoice";
        
        it(@"should return a BFTask", ^{
            [[[apiManager search:searchTerm limit:(unsigned long)10 offset:(unsigned long)0 docType:docType] should] beKindOfClass:[BFTask class]];
        });
        
        it(@"should do the correct request to the Gini API", ^{
            [apiManager search:searchTerm limit:(unsigned long)10 offset:(unsigned long)0 docType:docType];
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/search?q=%@&limit=%lu&offset=%lu&docType=%@", searchTerm, (unsigned long)10, (unsigned long)0, docType];
            checkRequest(urlString, 1);
        });
        
        it(@"should react correctly on the HTTP response", ^{
            NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"search" withExtension:@"json"];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:json];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:@"https://api.gini.net/search?q=kitten&limit=10&offset=0&docType=invoice"];
            BFTask *extractionsTask = [apiManager search:searchTerm limit:(unsigned long)10 offset:(unsigned long)0 docType:docType];
            [[extractionsTask.error should] beNil];
            [[extractionsTask.result should] beKindOfClass:[NSDictionary class]];
            [[extractionsTask.result should] equal:json];
        });
    });

    context(@"The error report method", ^{
        NSString *summary = @"A test error report";
        NSString *summaryEncoded = stringByEscapingString(summary);
        NSString *description = @"This is a more detailed description of the error report";
        NSString *descriptionEncoded = stringByEscapingString(description);

        NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"errorreport" withExtension:@"json"];
        NSDictionary *errorReportJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];

        it(@"should return a BFTask", ^{
            [[[apiManager reportErrorForDocument:documentId summary:summary description:description] should] beKindOfClass:[BFTask class]];
        });

        it(@"should do the correct request to the Gini API", ^{
            [apiManager reportErrorForDocument:documentId summary:summary description:description];
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/%@/errorreport?summary=%@&description=%@", documentId, summaryEncoded, descriptionEncoded];
            checkRequest(urlString, 1);
        });

        it(@"should react correctly on the HTTP response", ^{
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/%@/errorreport?summary=%@&description=%@", documentId, summaryEncoded, descriptionEncoded];
            NSHTTPURLResponse *nsURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                           statusCode:200
                                                                          HTTPVersion:@"1.1"
                                                                         headerFields:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nsURLResponse data:errorReportJson];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:urlString];
            BFTask *errorReportTask = [apiManager reportErrorForDocument:documentId summary:summary description:description];
            [[errorReportTask.error should] beNil];
            [[errorReportTask.result should] beNonNil];
        });

        it(@"should pass-through transparently HTTP errors", ^{
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/Foobar/errorreport?summary=%@&description=%@", summaryEncoded, descriptionEncoded];
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            [urlSessionMock setResponse:[BFTask taskWithError:error] forURL:urlString];
            BFTask *errorReportTask = [apiManager reportErrorForDocument:documentId summary:summary description:description];
            [[errorReportTask.result should] beNil];
            [[errorReportTask.error should] beNonNil];
        });
    });

    context(@"The method to submit batch feedback", ^{
        NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"feedback" withExtension:@"json"];
        NSDictionary *feedback = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];

        it(@"should return a BFTask", ^{
            [[[apiManager submitBatchFeedbackForDocument:documentId feedback:feedback] should] beKindOfClass:[BFTask class]];
        });

        it(@"should perform a PUT request", ^{
            [apiManager submitBatchFeedbackForDocument:documentId feedback:feedback];
            NSURLRequest *request = urlSessionMock.lastRequest;
            [[request.HTTPMethod should] equal:@"PUT"];
        });

        it(@"should do the correct request to the Gini API", ^{
            [apiManager submitBatchFeedbackForDocument:documentId feedback:feedback];
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/%@/extractions", documentId];
            checkRequest(urlString, 1);
        });

        it(@"should react correctly on the HTTP response", ^{
            NSString *urlString = [NSString stringWithFormat:@"https://api.gini.net/documents/%@/extractions", documentId];
            NSHTTPURLResponse *nsURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                           statusCode:204
                                                                          HTTPVersion:@"1.1"
                                                                         headerFields:nil];
            GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nsURLResponse data:nil];
            [urlSessionMock setResponse:[BFTask taskWithResult:response] forURL:urlString];
            BFTask *errorReportTask = [apiManager submitBatchFeedbackForDocument:documentId feedback:feedback];
            [[errorReportTask.error should] beNil];
            [[errorReportTask.result should] beNil];
        });

        it(@"should build the correct payload", ^{
            [apiManager submitBatchFeedbackForDocument:documentId feedback:feedback];
            NSData *httpBody = urlSessionMock.lastRequest.HTTPBody;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:httpBody options:NSJSONReadingAllowFragments error:nil];
            [[json should] beNonNil];
            [[json[@"feedback"] should] beKindOfClass:[NSDictionary class]];
            [[json[@"feedback"] should] equal:feedback];
        });
    });;
});


SPEC_END