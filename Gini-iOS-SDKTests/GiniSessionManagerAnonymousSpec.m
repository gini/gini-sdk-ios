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
#import "GININSNotificationCenterMock.h"

#pragma mark - Test Helpers
@interface GINIUserCenterManagerTestProxy : NSProxy

@property GINIUserCenterManagerMock *target;
+ (instancetype)proxyForObject:(GINIUserCenterManagerMock *)target;

@end


@implementation GINIUserCenterManagerTestProxy

+ (id)proxyForObject:(GINIUserCenterManagerMock *)target {
    GINIUserCenterManagerTestProxy *proxy = [self alloc];
    proxy->_target = target;
    return proxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];

    // Raise login errors only on the first login attempt.
    if (invocation.selector == @selector(loginUser:password:)) {
        _target.raiseWrongCredentialsOnLogin = NO;
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_target methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

@end


@interface GINISessionManagerAnonymous (TestVisibility)
- (BFTask *)getUserCredentials;
@end


#pragma mark - Tests
SPEC_BEGIN(GINISessionManagerAnonymousSpec)

    describe(@"The GINISessionManagerAnonymous", ^{
        __block GINIKeychainManager *keychainManager;

        __block GININSNotificationCenterMock *notificationCenter;
        
        __block GINISessionManagerAnonymous *(^SessionManagerFactoryWithEmailDomain)(GINIUserCenterManager *, NSString *) = ^GINISessionManagerAnonymous * (GINIUserCenterManager *userCenterManager, NSString *emailDomain){
            if (userCenterManager == nil) {
                GINIURLSession *giniurlSession = [GINIURLSession urlSessionWithNSURLSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]];
                userCenterManager = [GINIUserCenterManager userCenterManagerWithURLSession:giniurlSession
                                                                                  clientID:@"gini-sdk-ios"
                                                                              clientSecret:@"1234"
                                                                                   baseURL:[NSURL URLWithString:@"https://user.gini.net"]
                                                                        notificationCenter:nil];
                
            }
            notificationCenter = [GININSNotificationCenterMock new];
            GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
            return [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:credentialsStore
                                                                 userCenterManager:userCenterManager
                                                                       emailDomain:emailDomain
                                                                notificationCenter:notificationCenter];
        };
        
        __block GINISessionManagerAnonymous *(^SessionManagerFactory)(GINIUserCenterManager *) = ^GINISessionManagerAnonymous * (GINIUserCenterManager *userCenterManager){
            return SessionManagerFactoryWithEmailDomain(userCenterManager, @"example.com");
        };

        beforeEach(^{
            keychainManager = [GINIKeychainManager new];
            [keychainManager deleteAllItems];
        });

        context(@"The factory", ^{
            it(@"should raise an exception if called with skipped arguments", ^{
                [[theBlock(^{
                    [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:nil userCenterManager:nil emailDomain:nil notificationCenter:nil];
                }) should] raise];

                [[theBlock(^{
                    GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:[GINIKeychainManager new]];
                    [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:credentialsStore userCenterManager:nil emailDomain:nil notificationCenter:nil];
                }) should] raise];

                [[theBlock(^{
                    GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:[GINIKeychainManager new]];
                    [GINISessionManagerAnonymous sessionManagerWithCredentialsStore:credentialsStore userCenterManager:nil emailDomain:@"example.com" notificationCenter:nil];
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
                [[theValue(credentialsTask.error.code) should] equal:theValue(GINIErrorNoCredentials)];
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

            it(@"should store and reuse the session", ^{
                BFTask *initialTask = [sessionManager getSession];
                GINISession *initialSession = (GINISession *) initialTask.result;
                
                // Disable login and user creation to make sure no new session is created
                userCenterManagerMock.loginEnabled = NO;
                userCenterManagerMock.createUserEnabled = NO;
                
                BFTask *task = [sessionManager getSession];
                [[[task result] should] beKindOfClass:[GINISession class]];
                GINISession *session = (GINISession *) task.result;
                [[session should] equal:initialSession];
            });
            
            it(@"should create a new session if existing one expired", ^{
                GINISession *expiredSession = [[GINISession alloc] initWithAccessToken:@"1234-456" refreshToken:nil expirationDate:[NSDate dateWithTimeIntervalSince1970:0]];
                userCenterManagerMock.sessionForNextLogin = expiredSession;
                // Let the expired session be the current session
                [sessionManager getSession];
                
                // Request the session again to verify that a new session will be created
                BFTask *task = [sessionManager getSession];
                GINISession *actualSession = (GINISession *) task.result;
                [[actualSession shouldNot] equal:expiredSession];
            });

            it(@"should use stored user credentials", ^{
                GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
                [credentialsStore storeUserCredentials:@"foo@example.com" password:@"1234"];

                userCenterManagerMock.createUserEnabled = NO;
                BFTask *task = [sessionManager getSession];
                [[task.result should] beKindOfClass:[GINISession class]];
            });

            it(@"should create a new user if there are no stored credentials", ^{
                // The credentials are deleted before each test, so there are no stored credentials.
                BFTask *task = [sessionManager getSession];

                [[task.error should] beNil];
                [[task.result should] beKindOfClass:[GINISession class]];
                [[theValue(userCenterManagerMock.createUserCalled) should] equal:theValue(1)];
            });

            it(@"should avoid infinite login attempts", ^{
                // Create the needed credentials.
                GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
                [credentialsStore storeUserCredentials:@"foo@example.com" password:@"1234"];
                // But the mock will raise an error.
                userCenterManagerMock.raiseWrongCredentialsOnLogin = YES;

                BFTask *task = [sessionManager getSession];
                [[task.error should] beKindOfClass:[GINIError class]];
                // It tried to create a new user two times since each old user caused a login error.
                [[theValue(userCenterManagerMock.createUserCalled) should] equal:theValue(2)];
            });

            it(@"should create a new user if the stored user credentials cause a login error.", ^{
                // Create the needed credentials.
                GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
                [credentialsStore storeUserCredentials:@"foo@example.com" password:@"1234"];
                // But the mock will raise an error.
                userCenterManagerMock.raiseWrongCredentialsOnLogin = YES;

                GINIUserCenterManagerTestProxy *userCenterProxy = [GINIUserCenterManagerTestProxy proxyForObject:userCenterManagerMock];
                sessionManager = SessionManagerFactory((id) userCenterProxy);

                BFTask *task = [sessionManager getSession];
                [[task.error should] beNil];
                [[task.result should] beKindOfClass:[GINISession class]];
                [[theValue(userCenterManagerMock.createUserCalled) should] equal:theValue(1)];
            });

            it(@"should post a notification if the credentials of an existing user are used", ^{
                // Create the needed credentials.
                GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
                [credentialsStore storeUserCredentials:@"foo@example.com" password:@"1234"];

                [sessionManager getSession];

                [[[notificationCenter lastNotification] shouldNot] beNil];
                [[notificationCenter.lastNotification.name should] equal:GINIUsingExistingUserNotification];
                [[notificationCenter.lastNotification.object should] equal:@"foo@example.com"];
            });

            it(@"should not post a notification if there is no existing user", ^{
                [sessionManager getSession];

                [notificationCenter.lastNotification.name shouldBeNil];
            });

            it(@"should resolve to a user creation error", ^{
                userCenterManagerMock.createUserEnabled = YES;
                userCenterManagerMock.raiseHTTPErrorOnCreateUser = YES;

                BFTask *sessionTask = [sessionManager getSession];
                [[sessionTask.error should] beKindOfClass:[GINIError class]];
                [[theValue(sessionTask.error.code) should] equal:theValue(GINIErrorUserCreationError)];
            });
            
            it(@"should update email domain if changed", ^{
                NSString *newEmailDomain = @"beispiel.com";
                NSString *oldEmailDomain = @"example.com";
                GINIKeychainCredentialsStore *credentialsStore = [GINIKeychainCredentialsStore credentialsStoreWithKeychainManager:keychainManager];
                [credentialsStore storeUserCredentials:[NSString stringWithFormat:@"1234@%@", oldEmailDomain] password:@"5678"];
                
                userCenterManagerMock = [GINIUserCenterManagerMock new];
                sessionManager = SessionManagerFactoryWithEmailDomain(userCenterManagerMock, newEmailDomain);
                
                [sessionManager getSession];
                
                NSString *username;
                NSString *password;
                [credentialsStore fetchUserCredentials:&username password:&password];
                
                [[username should] endWithString:[NSString stringWithFormat:@"@%@",newEmailDomain]];
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
