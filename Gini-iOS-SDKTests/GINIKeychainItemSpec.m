/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import "GINIKeychainItem.h"


SPEC_BEGIN(GINIKeychainItemSpec)

    describe(@"The GINIKeychainItem", ^{
        context(@"the keychainItemWithIdentifier:value: factory", ^{
            it(@"should set the identifier", ^{
                GINIKeychainItem *item = [GINIKeychainItem keychainItemWithIdentifier:@"foobar" value:@"narf"];
                [[item.identifier should] equal:@"foobar"];
            });

            it(@"should set the value", ^{
                GINIKeychainItem *item = [GINIKeychainItem keychainItemWithIdentifier:@"foobar" value:@"narf"];
                [[item.value should] equal:@"narf"];
            });
        });
    });

SPEC_END
