/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Kiwi.h>
#import <UIKit/UIKit.h>
#import <Bolts.h>
#import "GINISessionManager.h"
#import "GINISession.h"
#import "GINIURLSessionMock.h"
#import "NSString+GINIAdditions.h"
#import "GINIUIApplicationMock.h"
#import "GINIURLResponse.h"
#import "GINISessionManager_Private.h"
#import "GINICredentialsStoreMock.h"

NSString *const appURLSchemeMock = @"mock.me";

GINIUIApplicationMock *mockApplicationResponderForClientFlow(GINISessionManager *sessionManager, NSString *accessToken, NSString *refreshToken, NSTimeInterval expiresIn, BOOL modifyState) {
    GINIUIApplicationMock *applicationMock;
    __weak GINIUIApplicationMock *weakApplicationMock;
    weakApplicationMock = applicationMock = [[GINIUIApplicationMock alloc] initWithSessionManager:sessionManager openURLBlock:^BOOL(NSURL *URL) {
        NSDictionary *params = [URL.query GINIQueryStringParameterDictionary];
        NSString *redirectURI = params[@"redirect_uri"];
        NSString *state = params[@"state"];
        if (modifyState) {
            state = [state stringByAppendingString:@"foo"];
        }

        NSURL *incomingURL = [GINIUIApplicationMock incomingURLWithRedirectURI:redirectURI
                                                                         state:state
                                                                   accessToken:accessToken
                                                                  refreshToken:refreshToken
                                                                     expiresIn:expiresIn];
        [weakApplicationMock fakeIncomingURL:incomingURL];
        return YES;
    }];
    [UIApplication stub:@selector(sharedApplication) andReturn:applicationMock];
    return applicationMock;
}

GINIUIApplicationMock *mockApplicationResponderForServerFlow(GINISessionManager *sessionManager, NSString *code, BOOL modifyState) {
    GINIUIApplicationMock *applicationMock;
    __weak GINIUIApplicationMock *weakApplicationMock;
    weakApplicationMock = applicationMock = [[GINIUIApplicationMock alloc] initWithSessionManager:sessionManager openURLBlock:^BOOL(NSURL *URL) {
        NSDictionary *params = [URL.query GINIQueryStringParameterDictionary];
        NSString *redirectURI = params[@"redirect_uri"];
        NSString *state = params[@"state"];
        if (modifyState) {
            state = [state stringByAppendingString:@"foo"];
        }

        NSURL *incomingURL = [GINIUIApplicationMock incomingURLWithRedirectURI:redirectURI
                                                                         state:state
                                                                          code:code];
        [weakApplicationMock fakeIncomingURL:incomingURL];
        return YES;
    }];
    [UIApplication stub:@selector(sharedApplication) andReturn:applicationMock];
    return applicationMock;
}



SPEC_BEGIN(GINISessionManagerSpecs)

    describe(@"Session manager", ^{

        NSString *const clientIdMock = @"clientId";
        NSString *const clientSecretMock = @"clientSecret";
        NSURL *const baseURLMock = [NSURL URLWithString:@"https://user.gini.net"];
        __block GINIURLSessionMock *URLSessionMock;
        __block GINISessionManager *sessionManager;

        context(@"Client-Flow", ^{

            beforeEach(^{
                URLSessionMock = [GINIURLSessionMock new];
                sessionManager = [GINISessionManager managerForClientFlowWithClientID:clientIdMock
                                                                              baseURL:baseURLMock
                                                                           URLSession:URLSessionMock
                                                                         appURLScheme:appURLSchemeMock];
            });

            it(@"should raise an exception when initialized without client ID", ^{
                [[theBlock(^{
                    sessionManager = [GINISessionManager managerForClientFlowWithClientID:nil
                                                                                  baseURL:baseURLMock
                                                                               URLSession:URLSessionMock
                                                                             appURLScheme:appURLSchemeMock];
                }) should] raise];
            });

            context(@"getSession", ^{

                it(@"should return a task", ^{
                    [[[sessionManager getSession] should] beKindOfClass:[BFTask class]];
                });

                it(@"should give error when logging in has not happened", ^{
                    BFTask *task = [[sessionManager getSession] continueWithBlock:^id(BFTask *task) {
                        [[task.error shouldNot] beNil];
                        return nil;
                    }];
                    [task waitUntilFinished];
                });

                it(@"should return a valid session when login session has ocurred", ^{

                    NSString *accessToken= @"1234";
                    NSString *refreshToken= @"1234";
                    NSTimeInterval expiresIn = 3600;
                    mockApplicationResponderForClientFlow(sessionManager, accessToken, refreshToken, expiresIn, NO);

                    BFTask *login = [sessionManager logIn];
                    __block GINISession *theSession;

                    [[login continueWithBlock:^id(BFTask *task) {
                        [[task.result should] beKindOfClass:[GINISession class]];
                        theSession = task.result;
                        return [sessionManager getSession];
                    }] continueWithBlock:^id(BFTask *task) {
                        [[task.result should] beKindOfClass:[GINISession class]];
                        [[theSession should] beIdenticalTo:task.result];
                        return nil;
                    }];
                });
            });

            context(@"logIn", ^{

                it(@"should return a task", ^{
                    [[[sessionManager logIn] should] beKindOfClass:[BFTask class]];
                });

                it(@"should not return a session if the state received does not match with the state sent", ^{

                    NSString *accessToken= @"1234";
                    NSString *refreshToken= @"1234";
                    NSTimeInterval expiresIn = 3600;
                    mockApplicationResponderForClientFlow(sessionManager, accessToken, refreshToken, expiresIn, YES);

                    NSLog(@"sessionManager = %@", sessionManager);
                    BFTask *login = [sessionManager logIn];

                    [login continueWithBlock:^id(BFTask *task) {
                        // Just to ensure this block is not called;
                        [[@"foo" should] beNil];
                        return nil;
                    }];

                    [[expectFutureValue(theValue([login isCompleted])) shouldAfterWaitOf(2)] beNo];
                });
            });
        });

        context(@"Server-Flow", ^{

            __block GINICredentialsStoreMock *credentialsStoreMock;

            beforeEach(^{
                URLSessionMock = [GINIURLSessionMock new];
                credentialsStoreMock = [GINICredentialsStoreMock new];
                sessionManager = [GINISessionManager managerForServerFlowWithClientID:clientIdMock
                                                                         clientSecret:clientSecretMock
                                                                     credentialsStore:credentialsStoreMock
                                                                              baseURL:baseURLMock
                                                                           URLSession:URLSessionMock
                                                                         appURLScheme:appURLSchemeMock];
            });

            it(@"should raise an exception when initialized for server flow and no client secret is provided", ^{
                [[theBlock(^{
                    sessionManager = [GINISessionManager managerForServerFlowWithClientID:clientIdMock
                                                                             clientSecret:nil
                                                                         credentialsStore:credentialsStoreMock
                                                                                  baseURL:baseURLMock
                                                                               URLSession:URLSessionMock
                                                                             appURLScheme:appURLSchemeMock];
                }) should] raise];
            });

            it(@"should raise an exception when initialized for server flow and a credentials store that does not conform the GINICredentialStore protocol", ^{

                id invalidCredentialStore = [[NSObject alloc] init];
                [[theBlock(^{
                    sessionManager = [GINISessionManager managerForServerFlowWithClientID:clientIdMock
                                                                             clientSecret:clientSecretMock
                                                                         credentialsStore:invalidCredentialStore
                                                                                  baseURL:baseURLMock
                                                                               URLSession:URLSessionMock
                                                                             appURLScheme:appURLSchemeMock];
                }) should] raise];
            });

            context(@"getSession", ^{

                it(@"should return a task", ^{
                    [[[sessionManager getSession] should] beKindOfClass:[BFTask class]];
                });

                it(@"should give error when logging in has not happened", ^{
                    BFTask *task = [[sessionManager getSession] continueWithBlock:^id(BFTask *task) {
                        [[task.error shouldNot] beNil];
                        return nil;
                    }];
                    [task waitUntilFinished];
                });

                it(@"should return a valid session when login session has ocurred", ^{

                    NSString *code = @"theCode1234";
                    mockApplicationResponderForServerFlow(sessionManager, code, NO);

                    // Stub the HTTP request 'token' to return a valid session
                    NSURL *dataPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"session" withExtension:@"json"];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:dataPath]
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:nil];

                    GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:nil data:json];

                    NSString *redirectURI = [NSString stringWithFormat:@"%@://%@", appURLSchemeMock, GINIAuthorizationURLHost];
                    NSDictionary *expectedParameters = @{
                            @"grant_type" : @"authorization_code",
                            @"client_id" : clientIdMock,
                            @"client_secret" : clientSecretMock,
                            @"code" : code,
                            @"redirect_uri" : redirectURI};
                    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:baseURLMock resolvingAgainstBaseURL:NO];
                    [urlComponents setPath:@"/token"];
                    [urlComponents setPercentEncodedQuery:[NSString GINIQueryStringWithParameterDictionary:expectedParameters]];
                    NSString *URLString = [[urlComponents URL] absoluteString];
                    [URLSessionMock setResponse:[BFTask taskWithResult:response] forURL:URLString];

                    BFTask *login = [sessionManager logIn];
                    __block GINISession *theSession;

                    [[login continueWithBlock:^id(BFTask *task) {
                        [[task.result should] beKindOfClass:[GINISession class]];
                        theSession = task.result;
                        return [sessionManager getSession];
                    }] continueWithBlock:^id(BFTask *task) {
                        [[task.result should] beKindOfClass:[GINISession class]];
                        [[theSession should] beIdenticalTo:task.result];
                        return nil;
                    }];
                });
            });

            context(@"logIn", ^{

                it(@"should return a task", ^{
                    [[[sessionManager logIn] should] beKindOfClass:[BFTask class]];
                });

                it(@"should not return a session if the state received does not match with the state sent", ^{

                    mockApplicationResponderForServerFlow(sessionManager, @"aRandomCode", YES);

                    NSLog(@"sessionManager = %@", sessionManager);
                    BFTask *login = [sessionManager logIn];

                    [login continueWithBlock:^id(BFTask *task) {
                        // Just to ensure this block is not called;
                        [[@"foo" should] beNil];
                        return nil;
                    }];

                    [[expectFutureValue(theValue([login isCompleted])) shouldAfterWaitOf(2)] beNo];
                });
            });
        });
    });

SPEC_END
