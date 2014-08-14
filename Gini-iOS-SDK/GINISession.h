/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

/**
 * This class represents a session of the GINI authorisation system.
 */
@interface GINISession : NSObject

/**
 * The refresh token of the session. Used to get a new access token when the latter has expired.
 */
@property(readonly) NSString *refreshToken;

/**
 * The access token of the session. Used to access resources of the Gini API.
 */
@property(readonly) NSString *accessToken;

/**
 * The expiration date of the validity of the access token.
 */
@property(readonly) NSDate *expirationDate;

/**
 * Initializes the session with the access token, refresh token and expiration date. The refresh token can be nil.
 *
 * @param accessToken       The `accessToken` used to create the session instance.
 * @param refreshToken      The `refreshToken` used to create the session instance.
 * @param expirationDate    The expiration date of the `accessToken`.
 *
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate *)expirationDate;

/**
 * Refreshes the session with new tokens.
 *
 * It gives the same result as in the init method but its existence makes sense semantically when a new pair of tokens
 * is received and the current session just needs to be updated.
 *
 * @param accessToken       The `accessToken` used to create the session instance.
 * @param refreshToken      The `refreshToken` used to create the session instance.
 * @param expirationDate    The expiration date of the `accessToken`.
 *
 */
- (void)refreshWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate *)expirationDate;

/**
 * A convenient check on whether the access token has expired.
 *
 * @returns True if the `accessToken` has expired, False otherwise.
 */
- (BOOL)hasAlreadyExpired;

@end
