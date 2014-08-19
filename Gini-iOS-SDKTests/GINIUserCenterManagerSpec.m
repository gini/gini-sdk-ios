#import <Kiwi/Kiwi.h>
#import <Bolts/BFTask.h>
#import "GINIUserCenterManager.h"
#import "GINIURLSession.h"
#import "GINIURLSessionMock.h"
#import "GINIURLResponse.h"
#import "GINIUser.h"
#import "GINISession.h"


// Make the private methods of the GINIUserCenterManager visible in the test so it can be used in tests.
@interface GINIUserCenterManager (TestVisibility)
- (NSString *)createLoginHeader;
@end

SPEC_BEGIN(GINIUserCenterManagerSpec)

    describe(@"The GINIUserCenterManager", ^{

        /* The `GINIUserCenterManager` instance that is tested in the tests */
        __block GINIUserCenterManager *userCenterManager;
        /** The `GINIURLSession` instance used in the tests as the dependency of the userCenterManager. */
        __block GINIURLSessionMock *urlSession;


        /**
         * Helper function which checks that the last request the GINIURLSessionMock received was to the correct URL and
         * used the correct HTTP method.
         */
        __block void (^checkRequest)(NSString *URL, NSString *httpMethod) = ^(NSString *URL, NSString *httpMethod) {
            // Check for the correct URL.
            NSURLRequest *request = urlSession.lastRequest;
            [[request shouldNot] beNil];
            [[[[request URL] absoluteString] should] equal:URL];
            [[request.HTTPMethod should] equal:httpMethod];
        };

        /**
         * Helper function which checks that the last request the GINIURLSessionMock received had an authorization
         * header with the correct bearer token (The token is from the fake server reply, see code below in the
         * beforeEach block).
         */
        __block void (^checkAccessToken)() = ^() {
            NSURLRequest *request = urlSession.lastRequest;
            [[request shouldNot] beNil];
            [[request.allHTTPHeaderFields[@"Authorization"] should] equal:@"BEARER 1234-5678"];
        };

        /**
         * Helper function which checks that the last request the GINIURLSessionMock received had an authorization
         * header with the correct HTTP basic authorization.
         */
        __block void (^checkBasicAuthentication)() = ^() {
            NSURLRequest *request = urlSession.lastRequest;
            [[request shouldNot] beNil];
            [[request.allHTTPHeaderFields[@"Authorization"] should] equal:@"Basic Zm9vOmJhcg=="];
        };

        beforeEach(^{
            urlSession = [GINIURLSessionMock new];
            userCenterManager = [GINIUserCenterManager userCenterManagerWithURLSession:urlSession
                                                                              clientID:@"foo"
                                                                          clientSecret:@"bar"
                                                                               baseURL:[NSURL URLWithString:@"https://user.gini.net/"]];

            // Set the response for an authorization request, so the tests can receive an access token and can create
            // a `GINISession` instance.
            NSDictionary *sessionResponse = @{
                @"access_token": @"1234-5678",
                @"expires_in": @5000,
                @"token_type": @"bearer"
            };
            [urlSession createAndSetResponse:sessionResponse forURL:@"https://user.gini.net/oauth/token?grant_type=client_credentials"];
        });

        it(@"should raise an error if instantiated with the wrong dependencies", ^{
            [[theBlock(^{
                [GINIUserCenterManager userCenterManagerWithURLSession:nil clientID:nil clientSecret:nil baseURL:nil];
            }) should] raise];

            [[theBlock(^{
                [GINIUserCenterManager userCenterManagerWithURLSession:nil clientID:nil clientSecret:@"foo" baseURL:nil];
            }) should] raise];

            [[theBlock(^{
                [GINIUserCenterManager userCenterManagerWithURLSession:nil clientID:@"foo" clientSecret:@"bar" baseURL:nil];
            }) should] raise];
        });

        it(@"should build the correct login header", ^{
            // Base64 of "foo:bar" (client ID : client secret)
            [[[userCenterManager createLoginHeader] should] equal:@"Basic Zm9vOmJhcg=="];
        });

        context(@"the getUserInfo: method", ^{
            it(@"should throw an error if getting the wrong arguments", ^{
                [[theBlock(^{
                    [userCenterManager getUserInfo:nil];
                }) should] raise];
            });

            it(@"should do the HTTP request to the correct URL", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users/88a28076-18e8-4275-b39c-eaacc240d406"];
                [userCenterManager getUserInfo:@"88a28076-18e8-4275-b39c-eaacc240d406"];
                checkRequest(@"https://user.gini.net/api/users/88a28076-18e8-4275-b39c-eaacc240d406", @"GET");
            });

            it(@"should set the correct access token", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users/88a28076-18e8-4275-b39c-eaacc240d406"];
                [userCenterManager getUserInfo:@"88a28076-18e8-4275-b39c-eaacc240d406"];
                checkAccessToken();
            });

            it(@"should return a BFTask instance", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users/88a28076-18e8-4275-b39c-eaacc240d406"];
                BFTask *infoTask = [userCenterManager getUserInfo:@"88a28076-18e8-4275-b39c-eaacc240d406"];
                [[infoTask should] beKindOfClass:[BFTask class]];
            });

            it(@"should return a task that resolves to a GINIUser instance", ^{
                NSURL *responseURL = [NSURL URLWithString:@"https://user.gini.net/api/users/88a28076-18e8-4275-b39c-eaacc240d406"];
                NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:responseURL
                                                                          statusCode:201
                                                                         HTTPVersion:@"1.1"
                                                                        headerFields:nil];
                GINIURLResponse *giniResponse = [GINIURLResponse urlResponseWithResponse:response data:@{
                    @"id":    @"88a28076-18e8-4275-b39c-eaacc240d406",
                    @"email": @"foobar@example.com"
                }];
                [urlSession setResponse:[BFTask taskWithResult:giniResponse]
                                 forURL:@"https://user.gini.net/api/users/88a28076-18e8-4275-b39c-eaacc240d406"];

                BFTask *userTask = [userCenterManager getUserInfo:@"88a28076-18e8-4275-b39c-eaacc240d406"];
                [[userTask.result should] beKindOfClass:[GINIUser class]];
                GINIUser *user = userTask.result;
                [[user.userId should] equal:@"88a28076-18e8-4275-b39c-eaacc240d406"];
                [[user.userEmail should] equal:@"foobar@example.com"];
            });
        });

        context(@"the createUserWithEmail:password: method", ^{
            it(@"should throw an error if getting the wrong arguments", ^{
                [[theBlock(^{
                    [userCenterManager createUserWithEmail:nil password:nil];
                }) should] raise];

                [[theBlock(^{
                    [userCenterManager createUserWithEmail:@"foobar" password:nil];
                }) should] raise];

            });

            it(@"should do the HTTP request to the correct URL", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users"];
                [userCenterManager createUserWithEmail:@"foobar@example.com" password:@"1234"];
                checkRequest(@"https://user.gini.net/api/users", @"POST");
            });

            it(@"should set the correct access token", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users"];
                [userCenterManager createUserWithEmail:@"foobar@example.com" password:@"1234"];
                checkAccessToken();
            });

            it(@"should submit the correct data", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users"];
                [userCenterManager createUserWithEmail:@"foobar@example.com" password:@"1234"];
                NSURLRequest *lastRequest = urlSession.lastRequest;
                NSString *expectedData = @"{\"password\":\"1234\",\"email\":\"foobar@example.com\"}";
                NSString *actualData = [[NSString alloc] initWithData:lastRequest.HTTPBody encoding:NSUTF8StringEncoding];
                [[expectedData should] equal:actualData];
            });

            it(@"should return a BFTask instance", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users"];
                BFTask *createTask = [userCenterManager createUserWithEmail:@"foobar@example.com" password:@"1234"];
                [[createTask should] beKindOfClass:[BFTask class]];
            });

            it(@"should return a task that resolves to a GINIUser instance", ^{
                NSURL *responseURL = [NSURL URLWithString:@"https://user.gini.net/api/users"];
                NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:responseURL
                                                                          statusCode:201
                                                                         HTTPVersion:@"1.1"
                                                                        headerFields:@{
                                                                            @"Location": @"https://user.gini.net/api/users/c1e60c6b-a0a4-4d80-81eb-c1c6de729a0e"
                                                                        }];
                GINIURLResponse *giniResponse = [GINIURLResponse urlResponseWithResponse:response];
                [urlSession setResponse:[BFTask taskWithResult:giniResponse] forURL:@"https://user.gini.net/api/users"];

                BFTask *createTask = [userCenterManager createUserWithEmail:@"foobar@example.com" password:@"1234"];
                [[createTask.result should] beKindOfClass:[GINIUser class]];
                GINIUser *user = createTask.result;
                [[user.userId should] equal:@"c1e60c6b-a0a4-4d80-81eb-c1c6de729a0e"];
                [[user.userEmail should] equal:@"foobar@example.com"];
            });

            it(@"should set the proper HTTP headers", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users"];
                BFTask *createTask = [userCenterManager createUserWithEmail:@"foobar@example.com" password:@"1234"];
                NSURLRequest *lastRequest = urlSession.lastRequest;
                [[[lastRequest valueForHTTPHeaderField:@"Content-Type"] should] equal:@"application/json"];
                [[[lastRequest valueForHTTPHeaderField:@"Accept"] should] equal:@"application/json"];
            });
        });

        context(@"the loginUser:password: method", ^{
            it(@"should throw an error if getting the wrong arguments", ^{
                [[theBlock(^{
                    [userCenterManager createUserWithEmail:nil password:nil];
                }) should] raise];

                [[theBlock(^{
                    [userCenterManager createUserWithEmail:@"foobar" password:nil];
                }) should] raise];

            });

            it(@"should do the HTTP request to the correct URL", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/oauth/token?grant_type=password"];
                [userCenterManager loginUser:@"foobar@example.com" password:@"1234"];
                checkRequest(@"https://user.gini.net/oauth/token?grant_type=password", @"POST");
            });

            it(@"should set the correct authentication headers", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/oauth/token?grant_type=password"];
                [userCenterManager loginUser:@"foobar@example.com" password:@"1234"];
                checkBasicAuthentication();
            });

            it(@"should submit the correct data", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/api/users"];
                [userCenterManager loginUser:@"foobar@example.com" password:@"1234"];
                NSURLRequest *lastRequest = urlSession.lastRequest;
                NSString *expectedData = @"username=foobar%40example.com&password=1234";
                NSString *actualData = [[NSString alloc] initWithData:lastRequest.HTTPBody encoding:NSUTF8StringEncoding];
                [[expectedData should] equal:actualData];
            });

            it(@"should return a BFTask instance", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/oauth/token?grant_type=password"];
                BFTask *loginTask = [userCenterManager loginUser:@"foobar@example.com" password:@"1234"];
                [[loginTask should] beKindOfClass:[BFTask class]];
            });

            it(@"should return a BFTask instance that resolves to a GINISession instance", ^{
                NSURL *responseURL = [NSURL URLWithString:@"https://user.gini.net/oauth/token?grant_type=password"];
                NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:responseURL
                                                                          statusCode:201
                                                                         HTTPVersion:@"1.1"
                                                                        headerFields:nil];
                GINIURLResponse *giniResponse = [GINIURLResponse urlResponseWithResponse:response data:@{
                    @"access_token": @"6c470ffa-abf1-41aa-b866-cd3be0ee84f4",
                    @"token_type":   @"bearer",
                    @"expires_in":   @3599
                }];
                [urlSession setResponse:[BFTask taskWithResult:giniResponse] forURL:@"https://user.gini.net/oauth/token?grant_type=password"];

                BFTask *loginTask = [userCenterManager loginUser:@"foobar@example.com" password:@"1234"];
                [[loginTask.result should] beKindOfClass:[GINISession class]];
                GINISession *session = loginTask.result;
                [[session.accessToken should] equal:@"6c470ffa-abf1-41aa-b866-cd3be0ee84f4"];
            });

            it(@"should set the proper HTTP headers", ^{
                [urlSession setResponse:[BFTask taskWithError:nil] forURL:@"https://user.gini.net/oauth/token?grant_type=password"];
                BFTask *loginTask = [userCenterManager loginUser:@"foobar@example.com" password:@"1234"];
                NSURLRequest *lastRequest = urlSession.lastRequest;
                [[[lastRequest valueForHTTPHeaderField:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            });
        });
    });

SPEC_END
