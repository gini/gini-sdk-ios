/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManagerServerFlow.h"

#import "GINICredentialsStore.h"
#import "GINISession.h"
#import "GINISessionManager_Private.h"
#import "GINISessionParser.h"
#import "GINIURLSession.h"
#import "GINIError.h"
#import <Bolts/Bolts.h>


@implementation GINISessionManagerServerFlow

NSString *const GINIServerFlowResponseType = @"code";

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret credentialsStore:(id <GINICredentialsStore>)credentialsStore baseURL:(NSURL *)baseURL URLSession:(id <GINIURLSession>)URLSession appURLScheme:(NSString *)appURLScheme {

    self = [super initWithClientID:clientID baseURL:baseURL URLSession:URLSession appURLScheme:appURLScheme];
    if (self) {
        NSParameterAssert([clientSecret isKindOfClass:[NSString class]]);
        NSParameterAssert([credentialsStore conformsToProtocol:@protocol(GINICredentialsStore)]);

        _clientSecret = clientSecret;
        _credentialsStore = credentialsStore;
    }
    return self;
}

#pragma mark - Tasks

- (void)setActiveSession:(GINISession *)session {
    _activeSession = session;
    [_credentialsStore storeRefreshToken:session.refreshToken];
}

- (BFTask *)getSession {

    if (_activeSession) {

        if (![_activeSession hasAlreadyExpired]) {

            return [BFTask taskWithResult:_activeSession];
        } else {

            return [self refreshTokensWithToken:_activeSession.refreshToken];
        }
    } else {

        NSString *storedRefreshToken = [_credentialsStore fetchRefreshToken];

        if (storedRefreshToken) {
            return [self refreshTokensWithToken:storedRefreshToken];
        } else {

            // Unable to get session without user interaction.
            return [BFTask taskWithError:[GINIError errorWithCode:GINIErrorNoValidSession userInfo:nil]];
        }
    }
}

- (BFTask *)refreshTokensWithToken:(NSString *)refreshToken {

    NSURLRequest *request = [self requestWithMethod:@"POST"
                                          URLString:@"token"
                                         parameters:@{@"grant_type" : @"refresh_token",
                                                 @"client_id" : _clientID,
                                                 @"client_secret" : _clientSecret,
                                                 @"refresh_token" : refreshToken}];

    return [[_URLSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *dictionary = task.result;
        GINISession *session = [GINISessionParser sessionWithJSONDictionary:dictionary];
        [self setActiveSession:session];
        return session;
    }];
}

- (BFTask *)getSessionWithCode:(NSString *)code redirectURL:(NSURL *)redirectURL {

    NSURLRequest *request = [self requestWithMethod:@"POST"
                                          URLString:@"token"
                                         parameters:@{@"grant_type" : @"authorization_code",
                                                 @"client_id" : _clientID,
                                                 @"client_secret" : _clientSecret,
                                                 @"code" : code,
                                                 @"redirect_uri" : redirectURL.absoluteString}];
    return [[_URLSession BFDataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *dictionary = task.result;
        return [GINISessionParser sessionWithJSONDictionary:dictionary];
    }];
}

- (BFTask *)logIn {

    // Remove the previous authorize task.
    if (_activeLogInTask) {
        [_activeLogInTask cancel];
        _activeLogInState = nil;
    }

    NSString *state = [GINISessionManager generateRandomState];
    NSURL *redirectURL = [self authorizationRedirectURL];

    return [[[[self openAuthorizationPageWithState:state redirectURL:redirectURL responseType:GINIServerFlowResponseType] continueWithSuccessBlock:^id(BFTask *task) {
        BFTaskCompletionSource *getCodeTask = [BFTaskCompletionSource taskCompletionSource];
        _activeLogInTask = getCodeTask;
        _activeLogInState = state;
        return getCodeTask.task;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        NSString *code = task.result;
        return [self getSessionWithCode:code redirectURL:redirectURL];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        GINISession *session = task.result;
        [self setActiveSession:session];
        return session;
    }];
}

#pragma mark - GINIIncomingURLDelegate

- (BOOL)handleURL:(NSURL *)URL {

    if ([URL.scheme isEqualToString:_appScheme] && [URL.host isEqualToString:GINIAuthorizationURLHost]) {

        NSDictionary *fragmentParams = [URL.fragment GINIQueryStringParameterDictionary];
        NSString *state = fragmentParams[@"state"];

        if ([_activeLogInState isEqualToString:state]) {
            NSString *code = fragmentParams[@"code"];
            if (code) {
                [_activeLogInTask setResult:code];
            }
            else {
                // TODO: Add no code found error
                [_activeLogInTask setError:nil];
            }
            _activeLogInTask = nil;
            _activeLogInState = nil;
            return YES;
        }
    }

    return NO;
}

@end
