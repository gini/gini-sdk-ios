/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManager.h"

extern NSString * const GINIAuthorizationURLHost;

@interface GINISessionManager (Private)

+ (NSDictionary *)fragmentParametersForURL:(NSURL *)url;

+ (NSURL *)authorizationRedirectURL;

+ (NSString*)generateRandomState;


- (instancetype)initWithBaseURL:(NSURL *)baseURL URLSession:(GINIURLSession *)urlSession;

- (BFTask *)openAuthorizationPageWithState:(NSString *)state redirectURL:(NSURL *)redirectURL responseType:(NSString *)responseType;
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString*)URLString parameters:(NSDictionary *)parameters;

@end
