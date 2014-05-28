/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManagerClientFlow.h"
#import <Bolts/Bolts.h>
#import "GINISessionManager_Private.h"
#import "GINISession.h"
#import "GINISessionParser.h"

@interface GINISessionManagerClientFlow () {
}
@end

@implementation GINISessionManagerClientFlow

- (instancetype)initWithClientID:(NSString *)clientID baseURL:(NSURL *)baseURL URLSession:(GINIURLSession *)URLSession {
    
    self = [super initWithBaseURL:baseURL URLSession:URLSession];
    if (self) {
        // TODO: Use GINIException when available
        if (!clientID) {
            [NSException raise:@"Invalid parameter value" format:@"'clientID' must be non-nil"];
        }

        if (!baseURL) {
            [NSException raise:@"Invalid parameter value" format:@"'baseURL' must be non-nil"];
        }
        
        _clientID = clientID;
    }
    return self;
}

- (BFTask*)getSession {
    
    if (_activeSession && ![_activeSession hasAlreadyExpired]) {
        return [BFTask taskWithResult:_activeSession];
    }
    
    NSError *credentialsNeededError = [NSError errorWithDomain:GINIErrorDomain code:1 userInfo:nil];
    return [BFTask taskWithError:credentialsNeededError];
}

- (BFTask *)logIn {
    
    // Remove all previous logIn tasks. Usually only one is removed.
    [[_authorizeTasks allValues] makeObjectsPerformSelector:@selector(cancel)];
    [_authorizeTasks removeAllObjects];
    
    NSString *state = [GINISessionManager generateRandomState];
    NSURL *redirectURL = [GINISessionManager authorizationRedirectURL];

    return [[self openAuthorizationPageWithState:state redirectURL:redirectURL responseType:@"token"] continueWithSuccessBlock:^id(BFTask *task) {
        BFTaskCompletionSource *loginTask = [BFTaskCompletionSource taskCompletionSource];
        _authorizeTasks[state] = loginTask;
        return loginTask.task;
    }];
}


#pragma mark - GINIIncomingURLResponder

- (BOOL)handleURL:(NSURL *)URL {
    
    if ([URL.scheme isEqualToString:GINIAuthorizationURLScheme] && [URL.host isEqualToString:GINIAuthorizationURLHost]) {
        
        NSDictionary *params = [GINISessionManager fragmentParametersForURL:URL];
        
        NSString *state = params[@"state"];
        BFTaskCompletionSource *loginTask = _authorizeTasks[state];
        
        if (loginTask) {
            GINISession *session = [GINISessionParser sessionWithFragmentParametersDictionary:params];
            _activeSession = session;
            [loginTask setResult:session];
            [_authorizeTasks removeObjectForKey:state];
            return YES;
        }
    }
    return NO;
}

@end