/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManager.h"

@protocol GINIURLSession;
@protocol GINICredentialsStore;

/**
 * The `GINISessionManagerServerFlow` implements the server flow oauth authentication flow.
 *
 * @warning Never use this subclass directly. Instead, use the factory methods on the `GINISessionManager` class to
 *          create the correct session manager depending on your application's authentication flow.
 */
@interface GINISessionManagerServerFlow : GINISessionManager {

    /// The client secret given by Gini.
    NSString *_clientSecret;

    /// The credential store where the tokens will be saved
    id <GINICredentialsStore> _credentialsStore;
}

/**
*  Initializes the manager to use server-side authentication flow.
*
*  @param clientID         The clientID you received from Gini.
*  @param clientSecret     The client secret you received from Gini.
*  @param credentialsStore Object that handles the storage of the tokens.
*  @param baseURL          The base URL of the Gini Oauth Server.
*  @param URLSession       The NSURLSession used for the network connections.
*  @param appURLScheme     The URL scheme used for redirection to the app once the login on the browser is done.
*
*  @return The initialized instance
*/
- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret
                credentialsStore:(id <GINICredentialsStore>)credentialsStore
                         baseURL:(NSURL *)baseURL
                      URLSession:(id <GINIURLSession>)URLSession
                    appURLScheme:(NSString *)appURLScheme;

@end
