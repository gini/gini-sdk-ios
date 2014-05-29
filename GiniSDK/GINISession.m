//
// Created by Lukas Stührk on 23/05/14.
// Copyright (c) 2014 Gini GmbH. All rights reserved.
//

#import "GINISession.h"


@implementation GINISession

#pragma mark - Initializer
- (instancetype)initWithAccessToken:(NSString *)token andRefreshToken:(NSString *)refresh expiresAt:(NSDate *)expires{
    self = [super init];
    if (self) {
        self.accessToken = token;
        self.refreshToken = refresh;
        self.expiresAt = expires;
    }
    return self;
}

#pragma mark - Public methods
- (NSString *)description {
    return [NSString stringWithFormat:@"<GINISession %@>", self.accessToken];
}

@end