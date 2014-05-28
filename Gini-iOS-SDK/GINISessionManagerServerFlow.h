/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManager.h"

@interface GINISessionManagerServerFlow : GINISessionManager {
    NSString* _clientSecret;
    
    id<GINICredentialsStore> _credentialsStore;
}

/**
 *  Initializes the manager to use server-side authentication flow.
 *
 *  @param clientID         The clientID you received from Gini.
 *  @param clientSecret     The client secret you received from Gini.
 *  @param credentialsStore Object that handles the storage of the tokens.
 *  @param baseURL          The base URL of the Gini Oauth Server.
 *  @param urlSession       The NSURLSession used for the network connections.
 *
 *  @return The initialized instance
 */
- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret
                credentialsStore:(id <GINICredentialsStore>)credentialsStore
                         baseURL:(NSURL *)baseURL
                      URLSession:(GINIURLSession *)URLSession;

@end
