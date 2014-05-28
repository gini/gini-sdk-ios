/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManagerServerFlow.h"
#import <Bolts/Bolts.h>
#import "GINISessionManager_Private.h"
#import "GINICredentialsStore.h"
#import "GINIURLSession.h"
#import "GINISession.h"
#import "GINISessionParser.h"

@implementation GINISessionManagerServerFlow

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret credentialsStore:(id <GINICredentialsStore>)credentialsStore baseURL:(NSURL *)baseURL URLSession:(GINIURLSession *)URLSession {
    
    self = [super initWithBaseURL:baseURL URLSession:URLSession];
    if (self) {
        // TODO: Use GINIException when available
        if (!clientID) {
            [NSException raise:@"Invalid parameter value" format:@"'clientID' must be non-nil"];
        }
        
        if (!clientSecret) {
            [NSException raise:@"Invalid parameter value" format:@"'clientSecret' must be non-nil"];
        }
        
        if (![credentialsStore conformsToProtocol:@protocol(GINICredentialsStore)]) {
            [NSException raise:@"Invalid parameter value" format:@"The credentials store object must conform GINICredentialsStore protocol"];
        }
        

        _clientID = clientID;
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

- (BFTask*)getSession {
    
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
            // Unable to get session without user interaction
            
            // TODO: Use GINIError when available
            NSError *error = [NSError errorWithDomain:GINIErrorDomain code:1 userInfo:nil];
            return [BFTask taskWithError:error];
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
    
    return [[_URLTaskFactory dataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *dictionary = task.result;
        GINISession *session = [GINISessionParser sessionWithJSONDictionary:dictionary];
        [self setActiveSession:session];
        return session;
    }];
}

- (BFTask *)getSessionWithCode:(NSString *)code redirectURL:(NSURL*)redirectURL {

    NSURLRequest *request = [self requestWithMethod:@"POST"
                                          URLString:@"token"
                                         parameters:@{@"grant_type" : @"authorization_code",
                                                 @"client_id" : _clientID,
                                                 @"client_secret" : _clientSecret,
                                                 @"code" : code,
                                                 @"redirect_uri" : redirectURL.absoluteString}];
    return [[_URLTaskFactory dataTaskWithRequest:request] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *dictionary = task.result;
        GINISession *session = [GINISessionParser sessionWithJSONDictionary:dictionary];
        return session;
    }];
}

- (BFTask *)logIn {
    
    // Cancel and remove all previous authorize tasks. Usually only one is present every time.
    [[_authorizeTasks allValues] makeObjectsPerformSelector:@selector(cancel)];
    [_authorizeTasks removeAllObjects];
    
    NSString *state = [GINISessionManager generateRandomState];
    NSURL *redirectURL = [GINISessionManager authorizationRedirectURL];
    
    return [[[[self openAuthorizationPageWithState:state redirectURL:redirectURL responseType:@"code"] continueWithSuccessBlock:^id(BFTask *task) {
        BFTaskCompletionSource *getCodeTask = [BFTaskCompletionSource taskCompletionSource];
        _authorizeTasks[state] = getCodeTask;
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

#pragma mark - Workflow

- (BOOL)handleURL:(NSURL *)URL {
    
    BFURL *parsedURL = [BFURL URLWithURL:URL];
    NSDictionary *params = [parsedURL targetQueryParameters];
    NSString *state = params[@"state"];
    BFTaskCompletionSource *authorizationTask = _authorizeTasks[state];
    
    if (authorizationTask) {
        
        NSString *code = params[@"code"];
        [authorizationTask setResult:code];
        [_authorizeTasks removeObjectForKey:state];
        return YES;
    }
    
    return NO;
}

@end
