/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/Bolts.h>
#import "GINIAPIManagerRequestFactory.h"
#import "GINISessionManager.h"
#import "GINISession.h"


@implementation GINIAPIManagerRequestFactory {
    id<GINISessionManager> _sessionManager;
}

+ (instancetype)requestFactoryWithSessionManager:(id <GINISessionManager>)sessionManager {
    return [[self alloc] initWithSessionManager:sessionManager];
}

- (instancetype)initWithSessionManager:(id<GINISessionManager>)sessionManager {
    NSParameterAssert([sessionManager conformsToProtocol:@protocol(GINISessionManager)]);
    self = [super init];
    if (self) {
        _sessionManager = sessionManager;
    }
    return self;
}

#pragma mark - Public Methods
- (BFTask *)asynchronousRequestUrl:(NSURL *)url withMethod:(NSString *)httpMethod {
    return [[_sessionManager getSession] continueWithSuccessBlock:^id(BFTask *task){
        GINISession *session = task.result;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:httpMethod];
        [request setValue:[@"Bearer " stringByAppendingString:session.accessToken] forHTTPHeaderField:@"Authorization"];
        return request;
    }];
}

@end