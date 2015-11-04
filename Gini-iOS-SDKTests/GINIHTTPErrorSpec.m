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
        GINIHTTPError *httpError = [GINIHTTPError HTTPErrrorWithCode:1 userInfo:nil];
        [[httpError should] beKindOfClass:[GINIHTTPError class]];
    });
    
    it(@"should be a subclass of NSError", ^{
        GINIHTTPError *httpError = [GINIHTTPError HTTPErrrorWithCode:1 userInfo:nil];
        [[httpError should] beKindOfClass:[NSError class]];
    });
    
    it(@"should set the properties correctly", ^{
        NSDictionary *userInfo = @{@"foo": @"bar"};
        NSInteger errorCode = 23;
        GINIHTTPError *httpError = [GINIHTTPError HTTPErrrorWithCode:errorCode userInfo:userInfo];
        [[theValue(httpError.code) should] equal:theValue(errorCode)];
        [[httpError.userInfo should] equal:userInfo];
        [[httpError.domain should] equal:GINIErrorDomain];
    });
});

SPEC_END
