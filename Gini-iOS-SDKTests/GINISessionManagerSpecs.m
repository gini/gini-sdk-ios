/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi.h>
#import "GINISessionManager.h"

SPEC_BEGIN(GINISessionManagerSpecs)

    describe(@"Session manager", ^{

        NSString *mockClientId = @"clientId";
        NSString *mockClientSecret = @"clientSecret";
        NSURL *mockBaseURL = [NSURL URLWithString:@"mockBaseURL://mock"];

        it(@"should raise exception when initialized without client ID", ^{
            [[theBlock(^{
                GINISessionManager *manager __attribute__((unused)) = [GINISessionManager managerForClientFlowWithClientID:nil
                                                                                                                   baseURL:mockBaseURL
                                                                                                                URLSession:nil];
            }) should] raise];

            [[theBlock(^{
                GINISessionManager *manager __attribute__((unused)) = [GINISessionManager managerForServerFlowWithClientID:nil
                                                                                                              clientSecret:mockClientSecret
                                                                                                          credentialsStore:nil
                                                                                                                   baseURL:mockBaseURL
                                                                                                                URLSession:nil];
            }) should] raise];
        });

        it(@"should cause exception when initialized with authentication flow GINIAuthenticationFlowServerSide but no client secret is provided", ^{
            [[theBlock(^{
                GINISessionManager *manager  __attribute__((unused)) = [GINISessionManager managerForServerFlowWithClientID:mockClientId
                                                                                                               clientSecret:nil
                                                                                                           credentialsStore:nil
                                                                                                                    baseURL:mockBaseURL
                                                                                                                 URLSession:nil];
            }) should] raise];
        });

        it(@"should cause exception when initialized with authentication flow GINIAuthenticationFlowServerSide and a credentials store that does not conform the GINICredentialStore protocol", ^{

            id invalidCredentialStore = [[NSObject alloc] init];

            [[theBlock(^{
                GINISessionManager *manager __attribute__((unused)) = [GINISessionManager managerForServerFlowWithClientID:mockClientId
                                                                                                              clientSecret:mockClientSecret
                                                                                                          credentialsStore:invalidCredentialStore
                                                                                                                   baseURL:mockBaseURL
                                                                                                                URLSession:nil];
            }) should] raise];
        });
    });

SPEC_END


