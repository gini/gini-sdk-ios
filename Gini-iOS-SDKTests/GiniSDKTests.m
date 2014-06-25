/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */
#import <Kiwi/Kiwi.h>
#import "GiniSDK.h"


SPEC_BEGIN(GiniSDKSpec)

describe(@"The Gini SDK", ^{

    __block GiniSDK *giniSDK;

    beforeEach(^{
        giniSDK = [GiniSDK giniSDKWithAppURLScheme:@"gini-sdk-ios://" clientID:@"gini-sdk-ios"];
    });

    it(@"should provide the API manager", ^{
        [[giniSDK.APIManager should] beKindOfClass:[GINIAPIManager class]];
    });

    it(@"should provide the session manager", ^{
        [[theValue([giniSDK.sessionManager conformsToProtocol:@ protocol(GINISessionManager)]) should] beYes];
    });
});

SPEC_END