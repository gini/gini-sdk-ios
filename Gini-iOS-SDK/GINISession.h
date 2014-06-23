/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

/*
 * This class represents a session of the GINI authentication system.
 */
@interface GINISession : NSObject

/*
 * The refresh token of the session. Used to get a new access token when the latter has expired.
 */
@property(readonly) NSString *refreshToken;

/*
 * The access token of the session. Used to access to the different resources in the GINI API.
 */
@property(readonly) NSString *accessToken;

/*
 * The expiration date of the validity of the access token.
 */
@property(readonly) NSDate *expirationDate;

/*
 * Initializes the session with the access token, refresh token and expiration date. The refresh token can be nil.
 */
- (instancetype)initWithAccessToken:(NSString *)at refreshToken:(NSString *)rt expirationDate:(NSDate*)expirationDate;

/*
 * Refreshes the session with new tokens.
 *
 * It gives the same result as in the init method but its existence makes sense semantically when a new pair of tokens
 * is received and the current session just needs to be updated.
 */
- (void)refreshWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate*)expirationTime;

/*
 * A convenient check on whether the access token has expired.
 */
- (BOOL)hasAlreadyExpired;

@end
