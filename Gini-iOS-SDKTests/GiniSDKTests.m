/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */
#import <Kiwi/Kiwi.h>
#import "GiniSDK.h"


SPEC_BEGIN(GiniSDKSpec)

describe(@"The Gini SDK", ^{

    __block GiniSDK *giniSDK;

    context(@"The normal client flow", ^{
        beforeEach(^{
            giniSDK = [GiniSDK giniSDKWithAppURLScheme:@"gini-sdk-ios://" clientID:@"gini-sdk-ios"];
        });

        it(@"should provide the API manager", ^{
            [[giniSDK.APIManager should] beKindOfClass:[GINIAPIManager class]];
        });

        it(@"should provide the session manager", ^{
            [[theValue([giniSDK.sessionManager conformsToProtocol:@ protocol(GINISessionManager)]) should] beYes];
            [[theValue([giniSDK.sessionManager conformsToProtocol:@ protocol(GINIIncomingURLDelegate)]) should] beYes];
        });

        it(@"should provide the document task manager", ^{
            [[giniSDK.documentTaskManager should] beKindOfClass:[GINIDocumentTaskManager class]];
        });

        it(@"should configure the base URLs correctly", ^{
            [[[[giniSDK.APIManager valueForKey:@"_baseURL"] absoluteString] should] equal:@"https://api.gini.net/"];
            GINISessionManager *sessionManager = giniSDK.sessionManager;
            [[[[sessionManager valueForKey:@"_baseURL"] absoluteString] should] equal:@"https://user.gini.net/"];
        });
    });

    context(@"The sandbox client flow", ^{
        beforeEach(^{
            giniSDK = [GiniSDK sandboxGiniSDKWithAppURLScheme:@"gini-sdk-ios://" clientID:@"gini-sdk-ios"];
        });

        it(@"should provide the API manager", ^{
            [[giniSDK.APIManager should] beKindOfClass:[GINIAPIManager class]];
        });

        it(@"should provide the session manager", ^{
            [[theValue([giniSDK.sessionManager conformsToProtocol:@ protocol(GINISessionManager)]) should] beYes];
            [[theValue([giniSDK.sessionManager conformsToProtocol:@ protocol(GINIIncomingURLDelegate)]) should] beYes];
        });

        it(@"should provide the document task manager", ^{
            [[giniSDK.documentTaskManager should] beKindOfClass:[GINIDocumentTaskManager class]];
        });

        it(@"should configure the base URLs correctly", ^{
            [[[[giniSDK.APIManager valueForKey:@"_baseURL"] absoluteString] should] equal:@"https://api-sandbox.gini.net/"];
            GINISessionManager *sessionManager = giniSDK.sessionManager;
            [[[[sessionManager valueForKey:@"_baseURL"] absoluteString] should] equal:@"https://user-sandbox.gini.net/"];
        });
    });

    context(@"The normal server flow", ^{
        beforeEach(^{
            giniSDK = [GiniSDK giniSDKWithAppURLScheme:@"gini-sdk-ios://" clientID:@"gini-sdk-ios" clientSecret:@"1234-5678-9012"];
        });

        it(@"should provide the API manager", ^{
            [[giniSDK.APIManager should] beKindOfClass:[GINIAPIManager class]];
        });

        it(@"should provide the session manager", ^{
            [[theValue([giniSDK.sessionManager conformsToProtocol:@ protocol(GINISessionManager)]) should] beYes];
            [[theValue([giniSDK.sessionManager conformsToProtocol:@ protocol(GINIIncomingURLDelegate)]) should] beYes];
        });

        it(@"should provide the document task manager", ^{
            [[giniSDK.documentTaskManager should] beKindOfClass:[GINIDocumentTaskManager class]];
        });

        it(@"should configure the base URLs correctly", ^{
            [[[[giniSDK.APIManager valueForKey:@"_baseURL"] absoluteString] should] equal:@"https://api.gini.net/"];
            GINISessionManager *sessionManager = giniSDK.sessionManager;
            [[[[sessionManager valueForKey:@"_baseURL"] absoluteString] should] equal:@"https://user.gini.net/"];
        });
    });
});

SPEC_END
