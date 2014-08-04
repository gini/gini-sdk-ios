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
    });

SPEC_END
