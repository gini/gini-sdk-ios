#import <Kiwi/Kiwi.h>
#import <Bolts/BFTask.h>
#import "GINISessionManagerAnonymous.h"
#import "GINIKeychainCredentialsStore.h"
#import "GINIKeychainManager.h"
#import "GINIUserCenterManager.h"
#import "GINIURLSession.h"
#import "GINIUserCenterManagerMock.h"
#import "GINISession.h"
#import "GINIError.h"


@interface GINISessionManagerAnonymous (TestVisibility)
- (BFTask *)getUserCredentials;
@end


SPEC_BEGIN(GINISessionManagerAnonymousSpec)

    describe(@"The GINISessionManagerAnonymous", ^{
        __block GINIKeychainManager *keychainManager;

        __block GINISessionManagerAnonymous *(^SessionManagerFactory)(GINIUserCenterManager *) = ^GINISessionManagerAnonymous * (GINIUserCenterManager *userCenterManager){
            if (userCenterManager == nil) {
                GINIURLSession *giniurlSession = [GINIURLSession urlSessionWithNSURLSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]];
                userCenterManager = [GINIUserCenterManager userCenterManagerWithURLSession:giniurlSession
                                                                                  clientID:@"gini-sdk-ios"
                                                                              clientSecret:@"1234"
                                                                                   baseURL:[NSURL URLWithString:@"https://user.gini.net"]];

            }
            GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
            return [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:credentialsStore
                                                                 userCenterManager:userCenterManager
                                                                       emailDomain:@"example.com"];
        };

        beforeEach(^{
            keychainManager = [GINIKeychainManager new];
            [keychainManager deleteAllItems];
        });

        context(@"The factory", ^{
            it(@"should raise an exception if called with skipped arguments", ^{
                [[theBlock(^{
                    [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:nil userCenterManager:nil emailDomain:nil];
                }) should] raise];

                [[theBlock(^{
                    GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:[GINIKeychainManager new]];
                    [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:credentialsStore userCenterManager:nil emailDomain:nil];
                }) should] raise];

                [[theBlock(^{
                    GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:[GINIKeychainManager new]];
                    [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:credentialsStore userCenterManager:nil emailDomain:@"example.com"];
                }) should] raise];
            });

            it(@"should return a GINISessionManagerAnonymous instance", ^{
                GINISessionManagerAnonymous *sessionManager = SessionManagerFactory(nil);
                [[sessionManager should] beKindOfClass:[GINISessionManagerAnonymous class]];
            });
        });


        context(@"The getUserCredentials method", ^{
            __block GINISessionManagerAnonymous *sessionManager;

            beforeEach(^{
                sessionManager = SessionManagerFactory(nil);
            });

            it(@"should return a BFTask *", ^{
                [[[sessionManager getUserCredentials] should] beKindOfClass:[BFTask class]];
            });

            it(@"should return the user's credentials", ^{
                GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
                [credentialsStore storeUserCredentials:@"foo@example.com" password:@"1234"];

                BFTask *credentialsTask = [sessionManager getUserCredentials];
                [[credentialsTask.result should] beKindOfClass:[NSDictionary class]];
                NSDictionary *result = credentialsTask.result;
                [[result[GINIUserNameKey] should] equal:@"foo@example.com"];
                [[result[GINIPasswordKey] should] equal:@"1234"];
            });

            it(@"should resolve to an error if there are no stored credentials", ^{
                BFTask *credentialsTask = [sessionManager getUserCredentials];
                [[credentialsTask.result should] beNil];
                [[credentialsTask.error should] beKindOfClass:[GINIError class]];
            });
        });


        context(@"The getSession method", ^{
            __block GINISessionManagerAnonymous *sessionManager;
            __block GINIUserCenterManagerMock *userCenterManagerMock;

            beforeEach(^{
                userCenterManagerMock = [GINIUserCenterManagerMock new];
                sessionManager = SessionManagerFactory(userCenterManagerMock);
            });

            it(@"should return a BFTask", ^{
                BFTask *task = [sessionManager getSession];

                [[task should] beKindOfClass:[BFTask class]];
            });

            it(@"should resolve to a GINISession instance", ^{
                BFTask *task = [sessionManager getSession];

                [[[task result] should] beKindOfClass:[GINISession class]];
            });

            it(@"should resolve to an error if the credentials are wrong", ^{
                userCenterManagerMock.wrongCredentials = YES;
                BFTask *task = [sessionManager getSession];

                [[task.error should] beKindOfClass:[GINIError class]];
            });

            it(@"should store and reuse the session", ^{
                [sessionManager getSession];
                userCenterManagerMock.loginEnabled = NO;
                userCenterManagerMock.createUserEnabled = NO;

                [sessionManager getSession];
            });

            it(@"should use stored user credentials", ^{
                GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
                [credentialsStore storeUserCredentials:@"foo@example.com" password:@"1234"];

                userCenterManagerMock.createUserEnabled = NO;
                BFTask *task = [sessionManager getSession];
                [[task.result should] beKindOfClass:[GINISession class]];
            });
        });

        context(@"The login method", ^{
            __block GINISessionManagerAnonymous *sessionManager;

            beforeEach(^{
                GINIUserCenterManagerMock *giniUserCenterManagerMock = [GINIUserCenterManagerMock new];
                sessionManager = SessionManagerFactory(giniUserCenterManagerMock);
            });

            it(@"should return a BFTask", ^{
                BFTask *task = [sessionManager logIn];

                [[task should] beKindOfClass:[BFTask class]];
            });

            it(@"should resolve to a GINISession instance", ^{
                BFTask *task = [sessionManager getSession];

                [[[task result] should] beKindOfClass:[GINISession class]];
            });
        });
    });

SPEC_END
