//
// Created by Lukas Stührk on 23/05/14.
// Copyright (c) 2014 Gini GmbH. All rights reserved.
//

#import <Bolts/Bolts.h>
#import "GINISessionManagerMock.h"
#import "GINISession.h"


@implementation GINISessionManagerMock {
    GINISession *_session;
}

+ (instancetype)sessionManagerWithAccessToken:(NSString *)accessToken{
    GINISession *session = [[GINISession alloc] initWithAccessToken:accessToken andRefreshToken:nil expiresAt:nil];
    return [[GINISessionManagerMock alloc] initWithSession:session];
}

- (instancetype)initWithSession:(GINISession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (BFTask *)getSession {
    return [BFTask taskWithResult:_session];
}
@end