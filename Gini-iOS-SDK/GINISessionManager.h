/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIIncomingURLDelegate.h"

@class BFTask;
@class GINISession;
@class GINIURLTaskFactory;
@protocol GINICredentialsStore;
@class GINIURLSession;

extern NSString * const GINIAuthorizationURLScheme;
extern NSString * const GINIOauthServiceURL;

// TODO: Move to more a general class (common)
extern NSStringEncoding const GINIStringEncoding;

// TODO: Move to GINIError
extern NSString * const GINIErrorDomain;

/**
 * The session manager uses a credentials store for saving the session credentials between
 * sessions.
 */
@interface GINISessionManager : NSObject <GINIIncomingURLDelegate> {
    NSString* _clientID;
    
    // The base URL of the Gini OAuth server
    NSURL *_baseURL;

    GINIURLSession *_URLSession;
    
    // State ivars
    GINISession *_activeSession;
    NSMutableDictionary *_authorizeTasks;
}

/**
 *  Creates a manager that uses client-side authentication flow.
 *
 *  @param clientID         The clientID you received from Gini.
 *  @param baseURL          The base URL of the Gini Oauth Server.
 *
 *  @return The initialized instance
 */
+ (instancetype)managerForClientFlowWithClientID:(NSString *)clientID
                                         baseURL:(NSURL *)baseURL
                                      URLSession:(GINIURLSession *)URLSession;

/**
 *  Creates a manager that uses server-side authentication flow.
 *
 *  @param clientID         The clientID you received from Gini.
 *  @param clientSecret     The client secret you received from Gini.
 *  @param credentialsStore Object that handles the storage of the tokens.
 *  @param baseURL          The base URL of the Gini Oauth Server.
 *
 *  @return The initialized instance
 */
+ (instancetype)managerForServerFlowWithClientID:(NSString *)clientID
                                    clientSecret:(NSString *)clientSecret
                                credentialsStore:(id <GINICredentialsStore>)credentialsStore
                                         baseURL:(NSURL *)baseURL
                                      URLSession:(GINIURLSession *)URLSession;
/**
 * Gets the current session.
 *
 * The method returns an error if the session cannot be created without user
 * intervention.
 *
 * @return A BFTask whose success result is a new GINISession.
 */
- (BFTask*)getSession;

/**
 * Performs a log in
 *
 * @return A BFTask whose success result is a new GINISession.
 */
- (BFTask*)logIn;

@end
