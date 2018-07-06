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
    __block NSMutableDictionary *documentJsonData;

    beforeEach(^{
        apiManager = [GINIAPIManagerMock new];
        documentTaskManager = [GINIDocumentTaskManager documentTaskManagerWithAPIManager:apiManager];

        NSURL *documentDataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"document" withExtension:@"json"];
        documentJsonData = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:documentDataPath]
                                                                                                 options:NSJSONReadingAllowFragments
                                                                                                   error:nil]];
    });

    it(@"should have a factory which creates a document from the API response", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[instance should] beKindOfClass:[GINIDocument class]];
    });

    it(@"should set the correct page number", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.pageCount) should] equal:theValue(1)];

        documentJsonData[@"pageCount"] = @23;
        GINIDocument *secondInstance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(secondInstance.pageCount) should] equal:theValue(23)];
    });

    it(@"should set the correct filename", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[instance.filename should] equal:@"scanned.jpg"];

        documentJsonData[@"name"] = @"foobar.jpg";
        instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[instance.filename should] equal:@"foobar.jpg"];
    });

    it(@"should set the correct source classification", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.sourceClassification) should] equal:theValue(GiniDocumentSourceClassificationScanned)];

        documentJsonData[@"sourceClassification"] = @"NATIVE";
        instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.sourceClassification) should] equal:theValue(GiniDocumentSourceClassificationNative)];
    });

    it(@"should set the correct creation date", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[instance.creationDate should] beKindOfClass:[NSDate class]];
        [[theValue([instance.creationDate isEqualToDate:[NSDate dateWithTimeIntervalSince1970:1360623867]]) should] beYes];
    });

    it(@"should set the correct document state", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.state) should] equal:theValue(GiniDocumentStateComplete)];

        documentJsonData[@"progress"] = @"PENDING";
        instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.state) should] equal:theValue(GiniDocumentStatePending)];

        documentJsonData[@"progress"] = @"ERROR";
        instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.state) should] equal:theValue(GiniDocumentStateError)];
    });
    
    it(@"should have the correct links", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[instance.links.document should] equal:@"https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000"];
        [[instance.links.extractions should] equal:@"https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/extractions"];
        [[instance.links.layout should] equal:@"https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/layout"];
        [[instance.links.processed should] equal:@"https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/processed"];
    });

    it(@"should have a nice description", ^{
        GINIDocument *document = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[[document description] should] equal:@"<GINIDocument id=626626a0-749f-11e2-bfd6-000000000000>"];
    });
    
    it(@"should have the correct amount of composite documents", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue([instance.compositeDocuments count]) should] equal:theValue(2)];
    });
    
});

describe(@"The composite GINIDocument", ^{
    __block GINIDocumentTaskManager *documentTaskManager;
    __block GINIAPIManagerMock *apiManager;
    __block NSMutableDictionary *documentJsonData;
    
    beforeEach(^{
        apiManager = [GINIAPIManagerMock new];
        documentTaskManager = [GINIDocumentTaskManager documentTaskManagerWithAPIManager:apiManager];
        
        NSURL *documentDataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"compositedocument" withExtension:@"json"];
        documentJsonData = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:documentDataPath]
                                                                                                         options:NSJSONReadingAllowFragments
                                                                                                           error:nil]];
    });
    
    it(@"should have a factory which creates a document from the API response", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[instance should] beKindOfClass:[GINIDocument class]];
    });
    
    it(@"should have the correct amount of partial documents", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue([instance.partialDocumentInfos count]) should] equal:theValue(2)];
    });
    
    it(@"should set the correct source classification", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:documentJsonData withDocumentManager:documentTaskManager];
        [[theValue(instance.sourceClassification) should] equal:theValue(GiniDocumentSourceClassificationComposite)];
    });
    
});

SPEC_END
