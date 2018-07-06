/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManagerClientFlow.h"

#import "GINISession.h"
#import "GINISessionManager_Private.h"
#import "GINISessionParser.h"
#import "GINIURLSession.h"
#import "GINIError.h"
#import <Bolts/Bolts.h>

@interface GINISessionManagerClientFlow () {
}
@end

@implementation GINISessionManagerClientFlow

NSString *const GINIClientFlowResponseType = @"token";

- (instancetype)initWithClientID:(NSString *)clientID baseURL:(NSURL *)baseURL URLSession:(id <GINIURLSession>)URLSession appURLScheme:(NSString *)appURLScheme {

    self = [super initWithClientID:clientID baseURL:baseURL URLSession:URLSession appURLScheme:appURLScheme];
    if (self) {

    }
    return self;
}

- (BFTask *)getSession {

    // The client-side flow can't get a new access token with the help of a refresh token.
    if (_activeSession && ![_activeSession hasAlreadyExpired]) {
        return [BFTask taskWithResult:_activeSession];
    }

    return [BFTask taskWithError:[GINIError errorWithCode:GINIErrorNoValidSession userInfo:nil]];
}

- (BFTask *)logIn {

    // Remove the previous authorize task.
    if (_activeLogInTask) {
        [_activeLogInTask cancel];
        _activeLogInState = nil;
    }

    NSString *state = [GINISessionManager generateRandomState];
    NSURL *redirectURL = [self authorizationRedirectURL];

    return [[self openAuthorizationPageWithState:state redirectURL:redirectURL responseType:GINIClientFlowResponseType] continueWithSuccessBlock:^id(BFTask *task) {
        BFTaskCompletionSource *logInTask = [BFTaskCompletionSource taskCompletionSource];
        self->_activeLogInTask = logInTask;
        self->_activeLogInState = state;
        return logInTask.task;
    }];
}


#pragma mark - GINIIncomingURLDelegate

- (BOOL)handleURL:(NSURL *)URL {

    if ([URL.scheme isEqualToString:_appScheme] && [URL.host isEqualToString:GINIAuthorizationURLHost]) {

        NSDictionary *fragmentParams = [URL.fragment GINIQueryStringParameterDictionary];
        NSString *state = fragmentParams[@"state"];

        if ([_activeLogInState isEqualToString:state]) {
            GINISession *session = [GINISessionParser sessionWithJSONDictionary:fragmentParams];
            _activeSession = session;
            [_activeLogInTask setResult:session];
            _activeLogInTask = nil;
            _activeLogInState = nil;
            return YES;
        }
    }
    return NO;
}

@end
