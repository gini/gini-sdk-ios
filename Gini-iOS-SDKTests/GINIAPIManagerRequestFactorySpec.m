#import <Kiwi/Kiwi.h>
#import <Bolts/Bolts.h>
#import "GINIAPIManagerRequestFactory.h"
#import "GINISessionManagerMock.h"


SPEC_BEGIN(GINIAPIManagerRequestFactorySpec)

describe(@"The GINIAPIManagerRequestFactory", ^{
    __block GINIAPIManagerRequestFactory *requestFactory;
    __block NSString *accessToken;
    __block NSURL *url;

    beforeEach(^{
        accessToken = @"1234";
        GINISessionManagerMock *sessionManager = [GINISessionManagerMock sessionManagerWithAccessToken:accessToken];
        requestFactory = [[GINIAPIManagerRequestFactory alloc] initWithSessionManager:sessionManager];
        // Many tests require a valid NSURL. This is handy so you don't have to create a new NSURL in every test.
        url = [NSURL URLWithString:@"foobar"];
    });

    it(@"should throw an exception if it is initialized with an invalid session manager", ^{
        [[theBlock(^{
            [[GINIAPIManagerRequestFactory alloc] initWithSessionManager:nil];
        }) should] raise];
    });

    context(@"synchronous method to get the session", ^{
        it(@"should set the correct access token", ^{
            NSMutableURLRequest *request = [requestFactory requestUrl:url withMethod:@"POST"];
            NSString *expectedHeader = [@"Bearer " stringByAppendingString:accessToken];
            [[[request valueForHTTPHeaderField:@"Authorization"] should] equal:expectedHeader];
        });
    });

    context(@"asynchronous method to get the session", ^{
        it(@"should set the correct access token", ^{
            __block BOOL called = NO;
            BFTask* requestTask = [requestFactory asynchronousRequestUrl:url withMethod:@"POST"];
            [requestTask continueWithSuccessBlock:^id(BFTask *task){
                NSMutableURLRequest *request = task.result;
                NSString *expectedHeader = [@"Bearer " stringByAppendingString:accessToken];
                [[[request valueForHTTPHeaderField:@"Authorization"] should] equal:expectedHeader];
                called = YES;
                return nil;
            }];
            [[expectFutureValue(theValue(called)) shouldEventually] beYes];
        });
    });
});

SPEC_END