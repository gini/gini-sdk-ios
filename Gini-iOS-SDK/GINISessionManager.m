/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManager.h"
#import "GINICredentialsStore.h"
#import "GINISessionManagerClientFlow.h"
#import "GINISessionManagerServerFlow.h"
#import "GINIURLSession.h"
#import "GINIError.h"
#import "NSString+GINIAdditions.h"
#import <Bolts/Bolts.h>
#import <UIKit/UIApplication.h>

NSString *const GINIAuthorizationURLHost = @"gini-authorization-finished";
NSUInteger const GINIAuthorizationStateLength = 8;


// TODO: Move to more a general class (common)
NSStringEncoding const GINIStringEncoding = NSUTF8StringEncoding;


@implementation GINISessionManager

#pragma mark - Factory

+ (instancetype)managerForClientFlowWithClientID:(NSString *)clientID
                                         baseURL:(NSURL *)baseURL
                                      URLSession:(id <GINIURLSession>)URLSession
                                    appURLScheme:(NSString *)appURLScheme {

    return [[GINISessionManagerClientFlow alloc] initWithClientID:clientID
                                                          baseURL:baseURL
                                                       URLSession:URLSession
                                                     appURLScheme:appURLScheme];
}

+ (instancetype)managerForServerFlowWithClientID:(NSString *)clientID
                                    clientSecret:(NSString *)clientSecret
                                credentialsStore:(id <GINICredentialsStore>)credentialsStore
                                         baseURL:(NSURL *)baseURL
                                      URLSession:(id <GINIURLSession>)URLSession
                                    appURLScheme:(NSString *)appURLScheme {

    return [[GINISessionManagerServerFlow alloc] initWithClientID:clientID
                                                     clientSecret:clientSecret
                                                 credentialsStore:credentialsStore
                                                          baseURL:baseURL
                                                       URLSession:URLSession
                                                     appURLScheme:appURLScheme];
}

- (instancetype)initWithClientID:(NSString *)clientID baseURL:(NSURL *)baseURL URLSession:(id <GINIURLSession>)urlSession appURLScheme:(NSString *)appURLScheme  {
    self = [super init];
    if (self) {
        NSParameterAssert([clientID isKindOfClass:[NSString class]]);
        NSParameterAssert([baseURL isKindOfClass:[NSURL class]]);
        NSParameterAssert([appURLScheme isKindOfClass:[NSString class]]);

        _clientID = [clientID copy];
        _baseURL = [baseURL copy];
        _URLSession = urlSession;
        _appScheme = [appURLScheme copy];

        if (!_URLSession) {
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
            _URLSession = [[GINIURLSession alloc] initWithNSURLSession:session];
        }
    }
    return self;
}

#pragma mark - Abstract methods

- (BFTask *)getSession {
    [NSException raise:@"GINISession 'getSession' accessed directly" format:@"GINISessionManager 'getSession' method must never be accessed directly. Use any of the subclasses instead."];
    return nil;
}

- (BFTask *)logIn {

    [NSException raise:@"GINISession 'logIn' accessed directly" format:@"GINISessionManager 'logIn' method must never be accessed directly. Use any of the subclasses instead."];
    return nil;
}

#pragma mark - Private helpers

- (BFTask *)openAuthorizationPageWithState:(NSString *)state redirectURL:(NSURL *)redirectURL responseType:(NSString *)responseType {

    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];

    NSURL *URL = [self URLWithString:@"oauth/authorize"
                          parameters:@{@"response_type" : responseType,
                                  @"client_id" : _clientID,
                                  @"redirect_uri" : redirectURL.absoluteString,
                                  @"state" : state}];

    UIApplication *theApplication = [UIApplication sharedApplication];
    if ([theApplication canOpenURL:URL]) {
        [theApplication openURL:URL];
        [task setResult:@YES];
    } else {
        // TODO: Add the proper errors
        NSError *unableToOpenURL = [NSError errorWithDomain:GINIErrorDomain code:1 userInfo:nil];
        [task setError:unableToOpenURL];
    }

    return task.task;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:method];

    if ([method isEqualToString:@"GET"]) {

        [request setURL:[self URLWithString:URLString parameters:parameters]];
    }
    else if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {

        [request setURL:[self URLWithString:URLString parameters:nil]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *query = [NSString GINIQueryStringWithParameterDictionary:parameters];
        [request setHTTPBody:[query dataUsingEncoding:GINIStringEncoding]];
    }
    return request;
}


- (NSURL *)URLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters {

    NSURL *URL = [NSURL URLWithString:URLString relativeToURL:_baseURL];
    NSURLComponents *URLComponents = [[NSURLComponents alloc] initWithString:[URL absoluteString]];
    NSString *query = [NSString GINIQueryStringWithParameterDictionary:parameters];
    [URLComponents setPercentEncodedQuery:query];
    return [URLComponents URL];
}

#pragma mark - GINIIncomingURLResponder

- (BOOL)handleURL:(NSURL *)URL {

    return NO;
}

#pragma mark - Utils

+ (NSString *)generateRandomState {

    return [[[NSUUID UUID] UUIDString] substringToIndex:GINIAuthorizationStateLength];
}

- (NSURL *)authorizationRedirectURL {

    NSURLComponents *URLComponents = [[NSURLComponents alloc] init];
    [URLComponents setScheme:_appScheme];
    [URLComponents setHost:GINIAuthorizationURLHost];
    return [URLComponents URL];
}

@end
