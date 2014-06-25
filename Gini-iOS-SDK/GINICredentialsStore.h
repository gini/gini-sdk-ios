/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

/**
 * The `GINICredentialsStore` defines the methods required to store and fetch the token necessary for refreshing the
 * session tokens when this is required. E.g the session expired.
 */
@protocol GINICredentialsStore <NSObject>

@required

/**
 * Stores the refresh token.
 *
 * @param refreshToken The token
 */
- (BOOL)storeRefreshToken:(NSString*)refreshToken;

/**
* Fetches the token.
*
* @returns The refresh token
*/
- (NSString*)fetchRefreshToken;

@end
