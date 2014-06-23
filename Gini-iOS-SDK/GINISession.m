/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISession.h"

@interface GINISession ()
@end

@implementation GINISession

- (instancetype)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate*)expirationDate {
    self = [super init];
    if (self) {
        [self refreshWithAccessToken:accessToken refreshToken:refreshToken expirationDate:expirationDate];
    }
    return self;
}

- (void)refreshWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate*)expirationDate {

    if (!accessToken) {
        [NSException raise:@"Invalid parameter value" format:@"'accessToken' must be non-nil"];
    }

    if (!expirationDate) {
        [NSException raise:@"Invalid parameter value" format:@"'expirationDate' must be non-nil"];
    }

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expirationDate = expirationDate;
}

- (BOOL)hasAlreadyExpired {
    NSDate *now = [NSDate date];
    return [now compare:_expirationDate] == NSOrderedDescending;
}

@end
