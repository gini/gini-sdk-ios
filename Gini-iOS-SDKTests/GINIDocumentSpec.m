/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import "GINIDocument.h"
#import "GINIDocumentTaskManager.h"
#import "GINIAPIManagerMock.h"


SPEC_BEGIN(GINIDocumentSpec)

describe(@"The GINIDocument", ^{
    __block GINIDocumentTaskManager *documentTaskManager;
    __block GINIAPIManagerMock *apiManager;
    __block NSDictionary *jsonData;

    beforeEach(^{
        apiManager = [GINIAPIManagerMock new];
        documentTaskManager = [GINIDocumentTaskManager documentTaskManagerWithAPIManager:apiManager];

        NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"document" withExtension:@"json"];
        jsonData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
    });

    it(@"should have a factory which creates a document from the API response", ^{
        GINIDocument *instance = [GINIDocument documentFromAPIResponse:jsonData withDocumentManager:documentTaskManager];
        [[instance should] beKindOfClass:[GINIDocument class]];
    });

    // TODO: Tests for document creation.
});

SPEC_END
