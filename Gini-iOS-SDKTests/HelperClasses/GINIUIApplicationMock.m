/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIUIApplicationMock.h"
#import "GINISessionManager.h"
#import "NSString+GINIAdditions.h"

@implementation GINIUIApplicationMock {
    BOOL(^_openURLBlock)(NSURL *URL);
}

- (instancetype)initWithSessionManager:(GINISessionManager *)sessionManager openURLBlock:(BOOL(^)(NSURL *URL))openURLBlock {
    self = [super init];
    if (self) {
        _sessionManager = sessionManager;
        _openURLBlock = openURLBlock;
    }
    return self;
}


- (BOOL)canOpenURL:(NSURL*)URL {
    NSLog(@"%@%@", NSStringFromSelector(_cmd), URL.absoluteString);
    return YES;
}

- (BOOL)openURL:(NSURL*)URL {
    NSLog(@"%@%@", NSStringFromSelector(_cmd), URL.absoluteString);

    self.openingURL = URL;
    return _openURLBlock(URL);
}

+ (NSURL*)incomingURLWithRedirectURI:(NSString*)redirectURI state:(NSString*)state accessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiresIn:(NSTimeInterval)expiresIn {

    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:redirectURI];
    NSString *query = [NSString GINIQueryStringWithParameterDictionary:@{
            @"state" : state,
            @"access_token" : accessToken,
            @"refresh_token" : refreshToken,
            @"expires_in" : @(expiresIn)
    }];
    [urlComponents setPercentEncodedQuery:query];
    return [urlComponents URL];
}

+ (NSURL*)incomingURLWithRedirectURI:(NSString*)redirectURI state:(NSString*)state code:(NSString *)code {

    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:redirectURI];
    NSString *query = [NSString GINIQueryStringWithParameterDictionary:@{
            @"state" : state,
            @"code" : code}];
    [urlComponents setPercentEncodedQuery:query];
    return [urlComponents URL];
}

- (void)fakeIncomingURL:(NSURL *)URL {

    [self didOpenURL:URL];
}

- (void)didOpenURL:(NSURL*)URL {
    
    if ([_sessionManager handleURL:URL]) {
        return;
    }
}

@end
