/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

@interface GINISession : NSObject

@property(readonly) NSString *refreshToken;
@property(readonly) NSString *accessToken;
@property(readonly) NSDate *expirationDate;

- (instancetype)initWithAccessToken:(NSString *)at refreshToken:(NSString *)rt expirartionDate:(NSDate*)expirationDate;
- (void)refreshWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate*)expirationTime;
- (BOOL)hasAlreadyExpired;

@end
