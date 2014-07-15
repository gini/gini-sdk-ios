/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIError.h"
#import <Kiwi/Kiwi.h>


SPEC_BEGIN(GiniErrorSpec)

describe(@"the GINIErrorClass", ^{
    it(@"should provide a factory for errors", ^{
        GINIError *error = [GINIError errorWithCode:1 userInfo:nil];
        [[error should] beKindOfClass:[GINIError class]];
    });

    it(@"should be a subclass of NSError", ^{
        GINIError *error = [GINIError errorWithCode:1 userInfo:nil];
        [[error should] beKindOfClass:[NSError class]];
    });

    it(@"should set the properties correctly", ^{
        NSDictionary *userInfo = @{@"foo": @"bar"};
        NSInteger errorCode = 23;
        GINIError *error = [GINIError errorWithCode:errorCode userInfo:userInfo];
        [[theValue(error.code) should] equal:theValue(errorCode)];
        [[error.userInfo should] equal:userInfo];
        [[error.domain should] equal:GINIErrorDomain];
    });
});

SPEC_END
