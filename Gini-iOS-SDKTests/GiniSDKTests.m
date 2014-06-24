//
//  GiniSDKTests.m
//  GiniSDKTests
//
//  Created by Lukas Stührk on 27/05/14.
//  Copyright (c) 2014 Gini GmbH. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "GiniSDK.h"


SPEC_BEGIN(GINISDKSpec)

describe(@"The GiniSDK", ^{
    __block GiniSDK *giniSDK;

    beforeEach(^{
        giniSDK = [GiniSDK new];
    });
});

SPEC_END
