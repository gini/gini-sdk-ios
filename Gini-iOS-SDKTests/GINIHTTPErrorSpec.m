//
//  GINIHTTPErrorSpec.m
//  Gini-iOS-SDK
//
//  Created by Gini on 04/11/15.
//  Copyright © 2015 Gini GmbH. All rights reserved.
//

#import "GINIError.h"
#import "GINIHTTPError.h"
#import "GINIURLResponse.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(GINIHTTPErrorSpec)

describe(@"the GINIHTTPError class", ^{
    it(@"should provide a factory for http errors", ^{
        GINIHTTPError *httpError = [GINIHTTPError errorWithResponse:[GINIURLResponse urlResponseWithResponse:nil]];
        [[httpError should] beKindOfClass:[GINIHTTPError class]];
    });
    
    it(@"should be a subclass of GINIError", ^{
        GINIHTTPError *httpError = [GINIHTTPError errorWithResponse:[GINIURLResponse urlResponseWithResponse:nil]];
        [[httpError should] beKindOfClass:[GINIError class]];
    });
    
    it(@"should set the properties correctly", ^{
        GINIHTTPError *httpError = [GINIHTTPError errorWithResponse:[GINIURLResponse urlResponseWithResponse:nil]];
        [[httpError.response should] beNonNil];
        [[theValue(httpError.code) should] equal:theValue(GINIHTTPErrorRequestError)];
        [[httpError.domain should] equal:GINIErrorDomain];
    });
});

SPEC_END
