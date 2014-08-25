/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

/**
 * The `GINICredentialsStore` defines the methods required to store and fetch user-related data. This can be refresh
 * token when the server-side OAuth authorization flow is used or the actual user data when the "anonymous" user feature
 * is used.
 */
@protocol GINICredentialsStore <NSObject>

@required

/**
 * Stores the refresh token.
 *
 * @param refreshToken  The token
 * @returns             Whether or not storing the token was successful.
 */
- (BOOL)storeRefreshToken:(NSString*)refreshToken;

/**
 * Fetches the refresh token.
 *
 * @returns             The refresh token
*/
- (NSString*)fetchRefreshToken;

/**
 * Stores the user credentials.
 *
 * @param userName      The user's username. Can't be nil.
 * @param password      The user's password. Can't be nil.
 */
- (BOOL)storeUserCredentials:(NSString *)userName password:(NSString *)password;

/**
 * Fetches the user credentials.
 *
 * @param userName      A reference to a string instance. The string instance will be populated with the user's username.
 * @param password      A reference to a string instance. The string instance will be populates with the user's password.
 */
- (void)fetchUserCredentials:(NSString **)userName password:(NSString **)password;

/**
 * Deletes stored user credentials.
 */
- (void)removeCredentials;

@end
