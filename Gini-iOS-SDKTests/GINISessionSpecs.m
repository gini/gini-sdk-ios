//
// Created by Roberto Miranda González on 05/06/14.
// Copyright (c) 2014 Gini GmbH. All rights reserved.
//

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
                                                       expirartionDate:[NSDate date]];
                }) should] raise];
            });

            it(@"should not allow empty expiration time", ^{
                [[theBlock(^{
                    session = [[GINISession alloc] initWithAccessToken:@"mockToken"
                                                          refreshToken:@"mockToken"
                                                       expirartionDate:nil];
                }) should] raise];
            });
        });

        context(@"when not yet expired", ^{

            it(@"should indicate that one session has not yet expired", ^{
                NSDate *now = [NSDate date];
                NSDate *twoHoursInTheFuture = [now dateByAddingTimeInterval:3600*2];

                session = [[GINISession alloc] initWithAccessToken:@"mockToken" refreshToken:@"mockToken" expirartionDate:twoHoursInTheFuture];

                [[theValue([session hasAlreadyExpired]) should] beNo];
            });
        });

        context(@"when expired", ^{

            it(@"should indicate that one session has expired", ^{
                NSDate *now = [NSDate date];
                NSDate *twoHoursBefore = [now dateByAddingTimeInterval:-3600*2];

                session = [[GINISession alloc] initWithAccessToken:@"mockToken" refreshToken:@"mockToken" expirartionDate:twoHoursBefore];

                [[theValue([session hasAlreadyExpired]) should] beYes];
            });
        });


    });


SPEC_END