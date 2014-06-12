/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManagerClientFlow.h"

#import "GINISession.h"
#import "GINISessionManager_Private.h"
#import "GINISessionParser.h"
#import "GINIURLSession.h"
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

    if (_activeSession && ![_activeSession hasAlreadyExpired]) {
        return [BFTask taskWithResult:_activeSession];
    }

    NSError *credentialsNeededError = [NSError errorWithDomain:GINIErrorDomain code:1 userInfo:nil];
    return [BFTask taskWithError:credentialsNeededError];
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
        _activeLogInTask = logInTask;
        _activeLogInState = state;
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