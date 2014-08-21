/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import <Bolts/Bolts.h>
#import "GINIDocument.h"
#import "GINIDocumentTaskManager.h"
#import "GINIAPIManagerMock.h"


SPEC_BEGIN(GINIDocumentSpec)

describe(@"The GINIDocument", ^{
    __block GINIDocumentTaskManager *documentTaskManager;
    __block GINIAPIManagerMock *apiManager;
    __block NSMutableDictionary *jsonData;

    beforeEach(^{
        apiManager = [GINIAPIManagerMock new];
        documentTaskManager = [GINIDocumentTaskManager documentTaskManagerWithAPIManager:apiManager];

        NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"document" withExtension:@"json"];
        jsonData = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                                                 options:NSJSONReadingAllowFragments
                                                                                                   error:nil]];

    });

    it(@"should have a factory which creates a document from the API response", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[instance should] beKindOfClass:[GINIDocument class]];
    });

    it(@"should set the correct page number", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.pageCount) should] equal:theValue(1)];

        jsonData[@"pageCount"] = @"23";
        GINIDocument *secondInstance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[theValue(secondInstance.pageCount) should] equal:theValue(23)];
    });

    it(@"should set the correct filename", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[instance.filename should] equal:@"scanned.jpg"];

        jsonData[@"name"] = @"foobar.jpg";
        instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[instance.filename should] equal:@"foobar.jpg"];
    });

    it(@"should set the correct source classification", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.sourceClassification) should] equal:theValue(GiniDocumentSourceClassificationScanned)];

        jsonData[@"sourceClassification"] = @"NATIVE";
        instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.sourceClassification) should] equal:theValue(GiniDocumentSourceClassificationNative)];
    });

    it(@"should set the correct creation date", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[instance.creationDate should] beKindOfClass:[NSDate class]];
        [[theValue([instance.creationDate isEqualToDate:[NSDate dateWithTimeIntervalSince1970:1360623867]]) should] beYes];
    });

    it(@"should set the correct document state", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.state) should] equal:theValue(GiniDocumentStateComplete)];

        jsonData[@"progress"] = @"PENDING";
        instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.state) should] equal:theValue(GiniDocumentStatePending)];

        jsonData[@"progress"] = @"ERROR";
        instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.state) should] equal:theValue(GiniDocumentStateError)];
    });

    it(@"should have a nice description", ^{
        GINIDocument *document = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[[document description] should] equal:@"<GINIDocument id=626626a0-749f-11e2-bfd6-000000000000>"];
    });

    it(@"should have a property to get the extractions", ^{
        GINIDocument *document = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[document.extractions should] beKindOfClass:[BFTask class]];
    });

    it(@"should have a property to get the candidates", ^{
        GINIDocument *document = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[document.candidates should] beKindOfClass:[BFTask class]];
    });

    // TODO more tests for the document tasks.
});

SPEC_END
