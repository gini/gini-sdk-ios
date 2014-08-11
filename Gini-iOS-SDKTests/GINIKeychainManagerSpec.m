/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi/Kiwi.h>
#import "GINIKeychainManager.h"
#import "GINIKeychainItem.h"


SPEC_BEGIN(GINIKeychainManagerSpec)

    describe(@"The GINIKeychainManager", ^{

        __block GINIKeychainManager *keychainManager;

        beforeEach(^{
            keychainManager = [GINIKeychainManager new];
            // Delete the keychain items before every test, so previous tests don't interfere with the current tests.
            [keychainManager deleteAllItems];
        });

        context(@"the getItem: method", ^{
            it(@"should throw an exception if the argument is not an NSString*", ^{
                [[theBlock(^{
                    [keychainManager getItem:nil];
                }) should] raise];
            });

            it(@"should return nil if there's no item stored with the given identifier", ^{
                [[[keychainManager getItem:@"foobar"] should] beNil];
            });

            it(@"should return the correct value", ^{
                GINIKeychainItem *item = [GINIKeychainItem keychainItemWithIdentifier:@"foobar" value:@"GINI!"];
                [keychainManager storeItem:item];

                GINIKeychainItem *storedItem = [keychainManager getItem:@"foobar"];
                [[storedItem should] beKindOfClass:[GINIKeychainItem class]];
                [[storedItem.value should] equal:@"GINI!"];
            });
        });

        context(@"the storeItem: method", ^{
            it(@"should throw an exception if the argument is not a GINIKeyItem instance", ^{
                [[theBlock(^{
                    [keychainManager storeItem:nil];
                }) should] raise];
            });

            it(@"should store an item", ^{
                GINIKeychainItem *item = [GINIKeychainItem keychainItemWithIdentifier:@"foobar" value:@"gini"];
                [[theValue([keychainManager storeItem:item]) should] beYes];

                [[[keychainManager getItem:@"foobar"] should] beKindOfClass:[GINIKeychainItem class]];
            });

            it(@"should update an existing item", ^{
                // First value.
                GINIKeychainItem *item = [GINIKeychainItem keychainItemWithIdentifier:@"multiTest" value:@"firstValue"];
                [keychainManager storeItem:item];
                // Second value.
                item.value = @"nextValue";
                [keychainManager storeItem:item];

                GINIKeychainItem *storedItem = [keychainManager getItem:@"multiTest"];
                [[storedItem should] beKindOfClass:[GINIKeychainItem class]];
                [[storedItem.value should] equal:@"nextValue"];
            });

            it(@"should store multiple items", ^{
                GINIKeychainItem *firstItem = [GINIKeychainItem keychainItemWithIdentifier:@"firstItem" value:@"1"];
                GINIKeychainItem *secondItem = [GINIKeychainItem keychainItemWithIdentifier:@"secondItem" value:@"2"];
                GINIKeychainItem *thirdItem = [GINIKeychainItem keychainItemWithIdentifier:@"thirdItem" value:@"3"];
                [keychainManager storeItem:firstItem];
                [keychainManager storeItem:secondItem];
                [keychainManager storeItem:thirdItem];

                [[[keychainManager getItem:@"firstItem"].value should] equal:@"1"];
                [[[keychainManager getItem:@"secondItem"].value should] equal:@"2"];
                [[[keychainManager getItem:@"thirdItem"].value should] equal:@"3"];
            });
        });

        context(@"the deleteItem: method", ^{
            it(@"should throw an exception if the argument is not a GINIKeychainItem instance", ^{
                [[theBlock(^{
                    [keychainManager deleteItem:nil];
                }) should] raise];
            });

            it(@"should delete an item", ^{
                GINIKeychainItem *item = [GINIKeychainItem keychainItemWithIdentifier:@"foobar" value:@"gini"];
                [keychainManager storeItem:item];

                [keychainManager deleteItem:item];
                [[[keychainManager getItem:@"foobar"] should] beNil];
            });
        });

        context(@"the deleteAllItems method", ^{
            it(@"should delete all items", ^{
                GINIKeychainItem *foobarItem = [GINIKeychainItem keychainItemWithIdentifier:@"foobar" value:@"raboof"];
                [keychainManager storeItem:foobarItem];
                GINIKeychainItem *raboofItem = [GINIKeychainItem keychainItemWithIdentifier:@"raboof" value:@"foobar"];
                [keychainManager storeItem:raboofItem];

                [[[keychainManager getItem:@"foobar"] should] beNonNil];

                [keychainManager deleteAllItems];

                [[[keychainManager getItem:@"foobar"] should] beNil];
                [[[keychainManager getItem:@"raboof"] should] beNil];
            });
        });
    });
SPEC_END
