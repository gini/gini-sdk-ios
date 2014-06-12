/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi.h>
#import "GINISession.h"

SPEC_BEGIN(GINISessionSpecs)

    describe(@"GINISession", ^{

        __block GINISession *session;

        context(@"when initialized", ^{
            it(@"should not allow empty access token", ^{

                [[theBlock(^{
                    session = [[GINISession alloc] initWithAccessToken:nil
                                                          refreshToken:@"mockToken"
                                                        expirationDate:[NSDate date]];
                }) should] raise];
            });

            it(@"should not allow empty expiration time", ^{
                [[theBlock(^{
                    session = [[GINISession alloc] initWithAccessToken:@"mockToken"
                                                          refreshToken:@"mockToken"
                                                        expirationDate:nil];
                }) should] raise];
            });
        });

        context(@"when not yet expired", ^{

            it(@"should indicate that it has not yet expired", ^{
                NSDate *now = [NSDate date];
                NSDate *twoHoursFromNow = [now dateByAddingTimeInterval:3600*2];

                session = [[GINISession alloc] initWithAccessToken:@"mockToken"
                                                      refreshToken:@"mockToken"
                                                    expirationDate:twoHoursFromNow];

                [[theValue([session hasAlreadyExpired]) should] beNo];
            });
        });

        context(@"when expired", ^{

            it(@"should indicate that it has expired", ^{
                NSDate *now = [NSDate date];
                NSDate *twoHoursAgo = [now dateByAddingTimeInterval:-3600*2];

                session = [[GINISession alloc] initWithAccessToken:@"mockToken"
                                                      refreshToken:@"mockToken"
                                                    expirationDate:twoHoursAgo];

                [[theValue([session hasAlreadyExpired]) should] beYes];
            });
        });
    });
SPEC_END
