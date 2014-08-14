/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import "GINIUser.h"


SPEC_BEGIN(GINIUserSpec)

    describe(@"The GINIUser", ^{
        __block GINIUser *user;

        beforeEach(^{
            user = [GINIUser userWithEmail:@"testdummy@gini.net" userId:@"c1e60c6b-a0a4-4d80-81eb-c1c6de729a0e"];
        });

        it(@"should create an instance of GINIUser", ^{
            [[user should] beKindOfClass:[GINIUser class]];
        });

        it(@"should correctly set the properties", ^{
            [[[user userEmail] should] equal:@"testdummy@gini.net"];
            [[[user userId] should] equal:@"c1e60c6b-a0a4-4d80-81eb-c1c6de729a0e"];
        });

        context(@"The userFromAPIResponse: factory", ^{
            it(@"should return nil if getting nil as argument", ^{
                [[[GINIUser userFromAPIResponse:nil] should] beNil];
            });

            it(@"should return nil if getting a dictionary with the wrong structure", ^{
                [[[GINIUser userFromAPIResponse:@{}] should] beNil];
            });

            it(@"should return the correct user info", ^{
                GINIUser *userFromAPI =[GINIUser userFromAPIResponse:@{
                    @"email": @"foobar@example.com",
                    @"id": @"1234-5678-9101-2342"
                }];

                [[userFromAPI should] beKindOfClass:[GINIUser class]];
                [[userFromAPI.userEmail should] equal:@"foobar@example.com"];
                [[userFromAPI.userId should] equal:@"1234-5678-9101-2342"];
            });
        });
    });

SPEC_END
