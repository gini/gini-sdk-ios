/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManager.h"
#import "NSString+GINIAdditions.h"

@class GINIURLSession;

extern NSString *const GINIAuthorizationURLHost;

@interface GINISessionManager (Private)

+ (NSString *)generateRandomState;

- (instancetype)initWithClientID:(NSString *)clientID baseURL:(NSURL *)baseURL URLSession:(id <GINIURLSession>)urlSession appURLScheme:(NSString *)appURLScheme;

- (NSURL *)authorizationRedirectURL;

- (BFTask *)openAuthorizationPageWithState:(NSString *)state redirectURL:(NSURL *)redirectURL responseType:(NSString *)responseType;

- (NSURL *)URLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters;

@end
