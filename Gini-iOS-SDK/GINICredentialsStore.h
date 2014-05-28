/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

@protocol GINICredentialsStore <NSObject>

@required

- (BOOL)storeRefreshToken:(NSString*)refreshToken;
- (NSString*)fetchRefreshToken;

@end
