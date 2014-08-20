/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import "GINIExtraction.h"


SPEC_BEGIN(GINIExtractionSpec)

describe(@"The GINIExtraction", ^{
    __block GINIExtraction *extraction;

    beforeEach(^{
        extraction = [GINIExtraction extractionWithName:@"amountToPay" value:@"42:EUR" entity:@"someEntity" box:nil];
    });

    it(@"should mark the extraction as dirty when changing the value", ^{
        [[theValue(extraction.isDirty) should] beNo];
        extraction.value = @"another value";
        [[theValue(extraction.isDirty) should] beYes];
    });

    it(@"should mark the extraction as dirty when changing the box", ^{
        [[theValue(extraction.isDirty) should] beNo];
        extraction.box = [NSDictionary new];
        [[theValue(extraction.isDirty) should] beYes];
    });

    it(@"should have a helping description", ^{
        [[extraction.description should] equal:@"<GINIExtraction amountToPay=42:EUR>"];
    });
});

SPEC_END
