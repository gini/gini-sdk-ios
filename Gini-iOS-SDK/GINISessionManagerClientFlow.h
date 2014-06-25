/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManager.h"

@protocol GINIURLSession;

@interface GINISessionManagerClientFlow : GINISessionManager {

}

/**
*  Initializes the manager to use client-side authentication flow.
*
*  @param clientID          The clientID you received from Gini.
*  @param baseURL           The base URL of the Gini Oauth Server.
*  @param URLSession        The `GINIURLSession` to make the requests.
*  @param appURLScheme      The URL scheme used for redirection to the app once the login on the browser is done.
*
*  @return The initialized instance.
*/
- (instancetype)initWithClientID:(NSString *)clientID
                         baseURL:(NSURL *)baseURL
                      URLSession:(id <GINIURLSession>)URLSession
                    appURLScheme:(NSString *)appURLScheme;

@end