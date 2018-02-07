//
//  GINIURLSessionDelegate.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 12/11/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

#import "GINIURLSessionDelegate.h"
#import <TrustKit/TrustKit.h>

@implementation GINIURLSessionDelegate {
}

+ (instancetype)urlSessionDelegate {
    return [self alloc];
}

-(void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))
completionHandler {
    TSKPinningValidator *pinningValidator = [[TrustKit sharedInstance] pinningValidator];

    if (![pinningValidator handleChallenge:challenge completionHandler:completionHandler]) {
        // TrustKit did not handle this challenge: perhaps it was not for server trust
        // or the domain was not pinned. Fall back to the default behavior
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
