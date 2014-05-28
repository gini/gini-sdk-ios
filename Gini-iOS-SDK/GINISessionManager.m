/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/Bolts.h>
#import <UIKit/UIApplication.h>
#import "GINISessionManager.h"
#import "GINICredentialsStore.h"

#import "GINISessionManagerClientFlow.h"
#import "GINISessionManagerServerFlow.h"
#import "GINIURLSession.h"

NSString * const GINIAuthorizationURLScheme = @"gini-ios-sdk";
NSString * const GINIAuthorizationURLHost = @"authorize_done";

NSString * const GINIOauthServiceURL = @"https://user.gini.net/";

NSUInteger const GINIAuthorizationStateLength = 8;



// TODO: Move to more a general class (common)
NSStringEncoding const GINIStringEncoding = NSUTF8StringEncoding;

// TODO: Move to GINIError
NSString * const GINIErrorDomain = @"net.gini.error";

@interface GINISessionManager () {
}
@end

@implementation GINISessionManager

#pragma mark - Factory

+ (instancetype)managerForClientFlowWithClientID:(NSString *)clientID baseURL:(NSURL *)baseURL URLSession:(GINIURLSession *)URLSession {
    return [[GINISessionManagerClientFlow alloc] initWithClientID:clientID baseURL:baseURL URLSession:URLSession];
}

+ (instancetype)managerForServerFlowWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret credentialsStore:(id <GINICredentialsStore>)credentialsStore baseURL:(NSURL *)baseURL URLSession:(GINIURLSession *)URLSession {
    return [[GINISessionManagerServerFlow alloc] initWithClientID:clientID clientSecret:clientSecret credentialsStore:credentialsStore baseURL:baseURL URLSession:URLSession];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL URLSession:(GINIURLSession *)urlSession {
    self = [self init];
    if (self) {
        _authorizeTasks = [NSMutableDictionary dictionary];
        _baseURL = baseURL;
        _URLSession = urlSession;

        if (!_URLSession) {
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
            _URLSession = [[GINIURLSession alloc] initWithNSURLSession:session];
        }
    }
    return self;
}

#pragma mark - Abstract methods

- (BFTask*)getSession {
    
    [NSException raise:@"GINISessionManager 'getSession' method must never be accessed directly. Use any of the subclasses instead." format:nil];
    return nil;
}

- (BFTask *)logIn {
    
    [NSException raise:@"GINISessionManager 'logIn' method must never be accessed directly. Use any of the subclasses instead." format:nil];
    return nil;
}

#pragma mark - Private helpers

- (BFTask *)openAuthorizationPageWithState:(NSString *)state redirectURL:(NSURL *)redirectURL responseType:(NSString *)responseType {
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    NSURLRequest *request = [self requestWithMethod:@"GET"
                                          URLString:@"authorize"
                                         parameters:@{@"response_type" : responseType,
                                                      @"client_id" : _clientID,
                                                      @"redirect_uri" : redirectURL.absoluteString,
                                                      @"state" : state}];
    NSURL *URL = request.URL;
    NSLog(@"URL = %@", URL);
    
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
        [task setResult:@YES];
    } else {
        NSError *unableToOpenURL = [NSError errorWithDomain:GINIErrorDomain code:1 userInfo:nil];
        [task setError:unableToOpenURL];
    }
    
    return task.task;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString*)URLString parameters:(NSDictionary *)parameters {

    NSMutableString *parametersString = [NSMutableString string];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [parametersString appendFormat:@"%@=%@&", key, obj];
    }];
    
    if (parametersString.length > 0) {
        [parametersString deleteCharactersInRange:NSMakeRange(parametersString.length - 1, 1)];
    }
    [parametersString setString:[parametersString stringByAddingPercentEscapesUsingEncoding:GINIStringEncoding]];
    
    if ([method isEqualToString:@"GET"]) {
        
        if (parametersString.length > 0) {
            URLString = [NSString stringWithFormat:@"%@?%@", URLString, parametersString];
        }
    }
    
    NSURL *URL = [NSURL URLWithString:URLString relativeToURL:_baseURL];
    NSLog(@"Absolute URL: %@", URL.absoluteString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[parametersString dataUsingEncoding:GINIStringEncoding]];
    }
    
    return request;
}

#pragma mark - GINIIncomingURLResponder

- (BOOL)handleURL:(NSURL *)URL {
    return NO;
}

#pragma mark - Utils

+ (NSString*) generateRandomState {
    return [[[NSUUID UUID] UUIDString] substringToIndex:GINIAuthorizationStateLength];
}

+ (NSURL *)authorizationRedirectURL {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    [urlComponents setScheme:GINIAuthorizationURLScheme];
    [urlComponents setHost:GINIAuthorizationURLHost];
    return [urlComponents URL];
}

+ (NSString *)decodeURLString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL,
                                                                                    (__bridge CFStringRef)string,
                                                                                    CFSTR("")));
}

+ (NSDictionary *)fragmentParametersForURL:(NSURL *)url {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *fragment = url.fragment;
    if ([fragment isEqualToString:@""]) {
        return @{};
    }
    NSArray *queryComponents = [fragment componentsSeparatedByString:@"&"];
    for (NSString *component in queryComponents) {
        NSRange equalsLocation = [component rangeOfString:@"="];
        if (equalsLocation.location == NSNotFound) {
            // There's no equals, so associate the key with NSNull
            parameters[[self decodeURLString:component]] = [NSNull null];
        } else {
            NSString *key = [self decodeURLString:[component substringToIndex:equalsLocation.location]];
            NSString *value = [self decodeURLString:[component substringFromIndex:equalsLocation.location + 1]];
            parameters[key] = value;
        }
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
