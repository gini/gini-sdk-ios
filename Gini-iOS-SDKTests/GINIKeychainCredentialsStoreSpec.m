/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import "GINIKeychainCredentialsStore.h"
#import "GINIKeychainManager.h"


SPEC_BEGIN(GINIKeychainCredentialsStoreSpec)

    describe(@"The GINIKeychainCredentialsStore", ^{
        __block GINIKeychainCredentialsStore *store;
        __block GINIKeychainManager *keychainManager;
        __block NSString *sampleToken = @"sample_token";

        beforeEach(^{
            keychainManager = [GINIKeychainManager new];
            store = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
            // Delete all possible entries in the keychain so previous tests won't interfere.
            [keychainManager deleteAllItems];
        });

        context(@"the factory", ^{
            it(@"should create the proper GINIKeychainCredentialsStore instance", ^{
                store = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];

                [[store should] beKindOfClass:[GINIKeychainCredentialsStore class]];
            });

            it(@"should throw an exception if not called with a GINIKeychainManager instance", ^{
                [[theBlock(^{
                    [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:nil];
                }) should] raise];
            });
        });

        context(@"the refresh token methods", ^{
            it(@"should not allow storing a nil token", ^{
                [[theBlock(^{
                    [store storeRefreshToken:nil];
                }) should] raise];
            });

            it(@"should properly store the refresh token", ^{
                BOOL success = [store storeRefreshToken:sampleToken];

                [[theValue(success) should] beYes];
                [[[store fetchRefreshToken] should] equal:sampleToken];
            });

            it(@"should fetch the refresh token", ^{
                [store storeRefreshToken:sampleToken];

                [[[store fetchRefreshToken] should] equal:sampleToken];
            });

        });

        context(@"the fetchCredentials:: method", ^{
            beforeEach(^{
                [store storeUserCredentials:@"foobar" password:@"1234"];
            });

            it(@"should fetch stored credentials", ^{
                NSString *userName;
                NSString *password;
                [store fetchUserCredentials:&userName password:&password];
                [[userName should] equal:@"foobar"];
                [[password should] equal:@"1234"];
            });
        });

        context(@"The storeCredentials:password: method", ^{
            it(@"should store credentials", ^{
                BOOL success = [store storeUserCredentials:@"foobar" password:@"1234"];

                [[theValue(success) should] beYes];

                NSString *username;
                NSString *password;
                [store fetchUserCredentials:&username password:&password];
                [[username should] equal:@"foobar"];
                [[password should] equal:@"1234"];
            });

            it(@"should only accept NSString* instances", ^{
                [[theBlock(^{
                    [store storeUserCredentials:nil password:nil];
                }) should] raise];

                [[theBlock(^{
                    [store storeUserCredentials:@"foobar" password:nil];
                }) should] raise];
            });
        });
    });

SPEC_END
