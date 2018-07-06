//
//  GINIPartialDocumentInfoSpec.m
//  Gini-iOS-SDKTests
//
//  Created by Gini GmbH on 4/25/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "GINIPartialDocumentInfo.h"

SPEC_BEGIN(GINIPartialDocumentInfoSpec)

describe(@"the GINIPartialDocumentInfo", ^{
    it(@"should create the correct formatted json string", ^{
        GINIPartialDocumentInfo *partialDocumentInfo = [[GINIPartialDocumentInfo alloc] initWithDocumentUrl:@"https://api.gini.net/documents/626626a0-749f-11e2-bfd6-123456"
                                                                                              rotationDelta:90];
        NSString *formattedString = @"{\"document\":\"https://api.gini.net/documents/626626a0-749f-11e2-bfd6-123456\", \"rotationDelta\":90}";

        [[[partialDocumentInfo formattedJson] should] equal:formattedString];
    });
    it(@"should have the correct id", ^{
        GINIPartialDocumentInfo *partialDocumentInfo = [[GINIPartialDocumentInfo alloc] initWithDocumentUrl:@"https://api.gini.net/documents/626626a0-749f-11e2-bfd6-123456"
                                                                                              rotationDelta:90];
        [[[partialDocumentInfo documentId] should] equal:@"626626a0-749f-11e2-bfd6-123456"];
    });
});
SPEC_END
