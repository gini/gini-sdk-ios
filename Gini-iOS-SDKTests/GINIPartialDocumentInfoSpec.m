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
        GINIPartialDocumentInfo *partialDocumentInfo = [[GINIPartialDocumentInfo alloc] initWithDocumentId:@"123456"
                                                                                             rotationDelta:90];
        NSString *formattedString = @"{\"document\":\"123456\", \"rotationDelta\":90}";

        [[[partialDocumentInfo formattedJson] should] equal:formattedString];
    });
});
SPEC_END
