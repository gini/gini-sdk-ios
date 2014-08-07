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
        __block NSString *sampleToken = @"sample_token";

        beforeEach(^{
            GINIKeychainManager *keychainManager = [GINIKeychainManager new];
            store = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
            // Delete all possible entries in the keychain so previous tests won't interfere.
            [keychainManager deleteAllItems];
        });

        context(@"the factory", ^{
            it(@"should create the proper GINIKeychainCredentialsStore instance", ^{
                GINIKeychainManager *keychainManager = [GINIKeychainManager new];
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
    });

SPEC_END
