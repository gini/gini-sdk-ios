#import <Kiwi/Kiwi.h>
#import "GINISDKBuilder.h"
#import "GiniSDK.h"
#import "GINISessionManagerClientFlow.h"
#import "GINISessionManagerServerFlow.h"
#import "GINISessionManagerAnonymous.h"


SPEC_BEGIN(GINISDKBuilderSpec)

    describe(@"The GINISDKBuilder", ^{

        __block void (^checkSDKProperties)(GiniSDK *) = ^(GiniSDK *sdk) {
            [[sdk.APIManager should] beKindOfClass:[GINIAPIManager class]];
            [[sdk.documentTaskManager should] beKindOfClass:[GINIDocumentTaskManager class]];
        };

        it(@"should throw an exception when not being initialized via the designated initializer", ^{
            [[theBlock(^{
                [GINISDKBuilder new];
            }) should] raise];

            [[theBlock(^{
                [[GINISDKBuilder alloc] init];
            }) should] raise];
        });
        
        it(@"should throw an exception when not being initialized via the designated initializer", ^{
            [[theBlock(^{
                [GINISDKBuilder new];
            }) should] raise];
            
            [[theBlock(^{
                [[GINISDKBuilder alloc] init];
            }) should] raise];
        });

        context(@"the clientFlowWithClientID:urlScheme: factory", ^{
            it(@"should raise an exception when the clientID is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder clientFlowWithClientID:nil urlScheme:@"foobar"];
                }) should] raise];
            });

            it(@"should raise an exception when the urlScheme is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder clientFlowWithClientID:@"foobar" urlScheme:nil];
                }) should] raise];
            });
            
            it(@"should not raise an exception when public key config is nil", ^{
                [[theBlock(^{
                    [GINISDKBuilder clientFlowWithClientID:@"foobar" urlScheme:@"foobar" publicKeyPinningConfig:nil];
                }) shouldNot] raise];
            });

            it(@"should use the correct session manager", ^{
                GiniSDK *sdk = [[GINISDKBuilder clientFlowWithClientID:@"foobar" urlScheme:@"foobar"] build];
                id sessionManager = sdk.sessionManager;
                [[sessionManager should] beKindOfClass:[GINISessionManagerClientFlow class]];
            });

            it(@"should set the SDK properties", ^{
                GiniSDK *sdk = [[GINISDKBuilder clientFlowWithClientID:@"foobar" urlScheme:@"foobar"] build];
                checkSDKProperties(sdk);
            });
        });

        context(@"the serverFlowWithClientID:clientSecret:urlScheme: factory", ^{
            it(@"should raise an exception when the clientID is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder serverFlowWithClientID:nil clientSecret:@"1234" urlScheme:@"foobar"];
                }) should] raise];
            });

            it(@"should raise an exception when the clientSecret is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder serverFlowWithClientID:@"foobar" clientSecret:nil urlScheme:@"foobar"];
                }) should] raise];
            });

            it(@"should raise an exception when the urlScheme is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder serverFlowWithClientID:@"foobar" clientSecret:@"1234" urlScheme:nil];
                }) should] raise];
            });
            
            it(@"should not raise an exception when public key config is nil", ^{
                [[theBlock(^{
                    [GINISDKBuilder serverFlowWithClientID:@"foobar" clientSecret:@"1234" urlScheme:@"foobar" publicKeyPinningConfig:nil];
                }) shouldNot] raise];
            });

            it(@"should use the correct session manager", ^{
                GiniSDK *sdk = [[GINISDKBuilder serverFlowWithClientID:@"foobar" clientSecret:@"1234" urlScheme:@"foobar"] build];
                id sessionManager = sdk.sessionManager;
                [[sessionManager should] beKindOfClass:[GINISessionManagerServerFlow class]];
            });

            it(@"should set the SDK properties", ^{
                GiniSDK *sdk = [[GINISDKBuilder serverFlowWithClientID:@"foobar" clientSecret:@"1234" urlScheme:@"foobar"] build];
                checkSDKProperties(sdk);
            });
        });

        context(@"the anonymousUserWithClientId:userEmailDomain: method", ^{
            it(@"should raise an exception when the clientID is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder anonymousUserWithClientID:nil clientSecret:@"1234" userEmailDomain:@"example.com"];
                }) should] raise];
            });

            it(@"should raise an exception when the userEmailDomain is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder anonymousUserWithClientID:@"foobar" clientSecret:@"1234" userEmailDomain:nil];
                }) should] raise];
            });

            it(@"should raise an exception when the clientSecret is not a string", ^{
                [[theBlock(^{
                    [GINISDKBuilder anonymousUserWithClientID:@"foobar" clientSecret:nil userEmailDomain:@"example.com"];
                }) should] raise];
            });
            
            it(@"should not raise an exception when public key config is nil", ^{
                [[theBlock(^{
                    [GINISDKBuilder anonymousUserWithClientID:@"foobar" clientSecret:@"1234" userEmailDomain:@"example.com" publicKeyPinningConfig:nil];
                }) shouldNot] raise];
            });

            it(@"should use the correct session manager", ^{
                GiniSDK *sdk = [[GINISDKBuilder anonymousUserWithClientID:@"foobar" clientSecret:@"1234" userEmailDomain:@"example.com"] build];
                id sessionManager = sdk.sessionManager;
                [[sessionManager should] beKindOfClass:[GINISessionManagerAnonymous class]];
            });

            it(@"should set the SDK properties", ^{
                GiniSDK *sdk = [[GINISDKBuilder anonymousUserWithClientID:@"foobar" clientSecret:@"1234" userEmailDomain:@"example.com"] build];
                checkSDKProperties(sdk);
            });
        });

        context(@"the build method", ^{
            it(@"should return a GiniSDK instance", ^{
                GINISDKBuilder *builder = [GINISDKBuilder clientFlowWithClientID:@"foo" urlScheme:@"bar"];
                [[[builder build] should] beKindOfClass:[GiniSDK class]];
            });
        });

        context(@"the useSandbox method", ^{
            it(@"should set the URL for the user center correctly", ^{
                GINISDKBuilder *builder = [GINISDKBuilder clientFlowWithClientID:@"foobar" urlScheme:@"foobar"];
                [builder useSandbox];

                // TODO: better test
                GINIInjector *injector = [builder valueForKey:@"_injector"];
                NSURL *url = [injector getInstanceOf:GINIInjectorUserBaseURLKey];
                [[[url absoluteString] should] equal:@"https://user-sandbox.gini.net/"];
            });

            it(@"should set the URL for the Gini API correctly", ^{
                GINISDKBuilder *builder = [GINISDKBuilder clientFlowWithClientID:@"foobar" urlScheme:@"foobar"];
                [builder useSandbox];

                // TODO: better test
                GINIInjector *injector = [builder valueForKey:@"_injector"];
                NSURL *url = [injector getInstanceOf:GINIInjectorAPIBaseURLKey];
                [[[url absoluteString] should] equal:@"https://api-sandbox.gini.net/"];
            });

            it(@"should be chainable", ^{
                GINISDKBuilder *builder = [GINISDKBuilder clientFlowWithClientID:@"foobar" urlScheme:@"foobar"];

                [[[builder useSandbox] should] equal:builder];
            });
        });

        context(@"The useNotificationCenter: method", ^{
            it(@"should set the notification center", ^{

                GINISDKBuilder *builder = [GINISDKBuilder anonymousUserWithClientID:@"foobar"
                                                                       clientSecret:@"1234"
                                                                    userEmailDomain:@"@example.com"];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter new];

                [builder useNotificationCenter:notificationCenter];

                // TODO
                 GiniSDK *sdk = [builder build];
                 GINISessionManagerAnonymous *sessionManager = (id) sdk.sessionManager;
                [[[[sessionManager valueForKey:@"_userCenterManager"] valueForKey:@"_notificationCenter"] should] equal:notificationCenter];
            });
        });

    });

SPEC_END
