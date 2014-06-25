/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import <Bolts/BFTask.h>
#import "GINIDocumentTaskManager.h"
#import "GINIDocument.h"
#import "GINIAPIManagerMock.h"


SPEC_BEGIN(GINIDocumentTaskManagerSpec)

describe(@"The GINIDocumentTaskManager", ^{
    __block GINIDocumentTaskManager *documentTaskManager;
    __block GINIAPIManagerMock *apiManager;

    beforeEach(^{
        apiManager = [GINIAPIManagerMock new];
        documentTaskManager = [GINIDocumentTaskManager documentTaskManagerWithAPIManager:apiManager];
    });

    context(@"The factory", ^{
        it(@"should return a GINIDocumentTaskManager instance", ^{
            GINIDocumentTaskManager *taskManager = [GINIDocumentTaskManager documentTaskManagerWithAPIManager:[GINIAPIManagerMock new]];
            [[taskManager should] beKindOfClass:[GINIDocumentTaskManager class]];
        });

        it(@"should raise an exception when given the wrong argument", ^{
            [[theBlock(^{
                [GINIDocumentTaskManager documentTaskManagerWithAPIManager:nil];
            }) should] raise];
        });
    });

    context(@"The getDocument method", ^{
        it(@"should return a BFTask*", ^{
            BFTask *task = [documentTaskManager getDocumentWithId:@"1234"];
            [[task should] beKindOfClass:[BFTask class]];
        });

        it(@"should resolve to a GINIDocument", ^{
            BFTask *task = [documentTaskManager getDocumentWithId:@"1234"];
            [[task should] beKindOfClass:[BFTask class]];
        });
    });

    context(@"The pollDocument method", ^{
        it(@"should throw an exception if the argument is not a document", ^{
            [[theBlock(^{
                [documentTaskManager pollDocument:nil];
            }) should] raise];
        });

        it(@"should return a BFTask*", ^{
            GINIDocument *document = [[GINIDocument alloc] initWithId:@"1234" state:GiniDocumentStateComplete sourceClassification:GiniDocumentSourceClassificationNative documentManager:nil];
            BFTask *task = [documentTaskManager pollDocument:document];
            [[task should] beKindOfClass:[BFTask class]];
        });

        it(@"should immediately return the document if it is in the processing state COMPLETED", ^{
            GINIDocument *document = [[GINIDocument alloc] initWithId:@"1234" state:GiniDocumentStateComplete sourceClassification:GiniDocumentSourceClassificationNative documentManager:nil];
            [documentTaskManager pollDocument:document];
            [[theValue(apiManager.getDocumentCalled) should] equal:theValue(0)];
        });

        it(@"should poll if it is in the processing state pending", ^{
            GINIDocument *document = [[GINIDocument alloc] initWithId:@"1234" state:GiniDocumentStatePending sourceClassification:GiniDocumentSourceClassificationNative documentManager:nil];
            BFTask *task = [documentTaskManager pollDocument:document];
            [[theValue(apiManager.getDocumentCalled) should] equal:theValue(1)];
            GINIDocument *updatedDocument = task.result;
            [[updatedDocument should] beKindOfClass:[GINIDocument class]];
            [[theValue(updatedDocument.state) should] equal:theValue(GiniDocumentStateComplete)];

        });
    });
});

SPEC_END
