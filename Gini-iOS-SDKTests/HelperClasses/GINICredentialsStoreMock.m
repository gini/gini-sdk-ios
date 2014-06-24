/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINICredentialsStoreMock.h"


@implementation GINICredentialsStoreMock {
    NSString *_token;
}

- (BOOL)storeRefreshToken:(NSString *)refreshToken {
    _token = refreshToken;
    return YES;
}

- (NSString *)fetchRefreshToken {
    return _token;
}

@end