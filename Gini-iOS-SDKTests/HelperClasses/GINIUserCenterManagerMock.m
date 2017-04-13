/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Bolts/BFTask.h>
#import "GINIUserCenterManagerMock.h"
#import "GINIUser.h"
#import "GINISession.h"
#import "GINIError.h"


@implementation GINIUserCenterManagerMock {

}


+ (instancetype)userCenterManagerWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL notificationCenter:(NSNotificationCenter *)notificationCenter {
    return [[GINIUserCenterManagerMock alloc] initWithURLSession:urlSession clientID:clientID clientSecret:clientSecret baseURL:baseURL notificationCenter:nil];
}

- (instancetype)initWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL notificationCenter:(NSNotificationCenter *)notificationCenter {
    // Raise an exception to prevent that someone accidentally uses the mock instead of the real thing.
    @throw [NSException exceptionWithName:@"invalid initializer" reason:@"mock" userInfo:nil];
    return nil;
}

- (instancetype)init {
    if (self = [super init]) {
        _createUserEnabled = YES;
        _getInfoEnabled = YES;
        _loginEnabled = YES;
        _raiseWrongCredentialsOnLogin = NO;
        _createUserCalled = 0;
    }
    return self;
}

- (BFTask *)getUserInfo:(NSString *)userID {
    if (!_getInfoEnabled) {
        [[NSException exceptionWithName:@"Not allowed" reason:@"Disallowed by mock" userInfo:nil] raise];
    }
    return [BFTask taskWithResult:[GINIUser userWithEmail:@"foo@example.comm" userId:@"1234-5678-9012"]];
}

- (BFTask *)loginUser:(NSString *)userName password:(NSString *)password {
    if (!_loginEnabled) {
        [[NSException exceptionWithName:@"Not allowed" reason:@"Disallowed by mock" userInfo:nil] raise];
    }
    if (_raiseWrongCredentialsOnLogin) {
        return [BFTask taskWithError:[GINIError errorWithCode:GINIErrorInvalidCredentials userInfo:nil]];
    } else {
        return [BFTask taskWithResult:[[GINISession alloc] initWithAccessToken:@"1234-456" refreshToken:nil expirationDate:[NSDate dateWithTimeIntervalSinceNow:600]]];
    }
}

- (BFTask *)createUserWithEmail:(NSString *)email password:(NSString *)password {
    _createUserCalled += 1;
    if (!_createUserEnabled) {
        [[NSException exceptionWithName:@"Not allowed" reason:@"Disallowed by mock" userInfo:nil] raise];
    }
    if (_raiseHTTPErrorOnCreateUser) {
        // Connection lost error.
        return [BFTask taskWithError:[NSError errorWithDomain:NSURLErrorDomain code:-1005 userInfo:nil]];
    }
    GINIUser *user = [GINIUser userWithEmail:email userId:@"1234-5678-9012"];
    return [BFTask taskWithResult:user];
}

- (BFTask *)updateEmail:(NSString *)newEmail
               oldEmail:(NSString *)oldEmail
         giniApiSession:(GINISession *)giniApiSession {
    return [BFTask taskWithResult:nil];
   }

@end
