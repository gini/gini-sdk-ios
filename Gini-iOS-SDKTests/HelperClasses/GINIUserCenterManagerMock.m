/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Bolts/BFTask.h>
#import "GINIUserCenterManagerMock.h"
#import "GINIUser.h"
#import "GINISession.h"


@implementation GINIUserCenterManagerMock {

}


+ (instancetype)userCenterManagerWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL {
    return [[GINIUserCenterManagerMock alloc] initWithURLSession:urlSession clientID:clientID clientSecret:clientSecret baseURL:baseURL];
}

- (instancetype)initWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL {
    // Raise an exception to prevent that someone accidentally uses the mock instead of the real thing.
    @throw [NSException exceptionWithName:@"invalid initializer" reason:@"mock" userInfo:nil];
    return nil;
}

- (instancetype)init {
    if (self = [super init]) {
        _createUserEnabled = YES;
        _getInfoEnabled = YES;
        _loginEnabled = YES;
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
    return [BFTask taskWithResult:[[GINISession alloc] initWithAccessToken:@"1234-456" refreshToken:nil expirationDate:[NSDate dateWithTimeIntervalSinceNow:600]]];
}

- (BFTask *)createUserWithEmail:(NSString *)email password:(NSString *)password {
    if (!_createUserEnabled) {
        [[NSException exceptionWithName:@"Not allowed" reason:@"Disallowed by mock" userInfo:nil] raise];
    }
    GINIUser *user = [GINIUser userWithEmail:email userId:@"1234-5678-9012"];
    return [BFTask taskWithResult:user];
}

@end
