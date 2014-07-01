/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIIncomingURLDelegate.h"

@class BFTask, BFTaskCompletionSource, GINISession;
@protocol GINICredentialsStore, GINIURLSession;

// TODO: Move to more a general class (common)
extern NSStringEncoding const GINIStringEncoding;

// TODO: Move to GINIError
extern NSString * const GINIErrorDomain;

/**
* This protocol describes the behaviour of session managers.
*
* The session manager is responsible for the oAuth authentication of Gini accounts. The authentication is required to
* do requests to the GiniAPI.
*
* @see http://developer.gini.net/gini-api/html/guides/oauth2.html.
*/

@protocol GINISessionManager <NSObject>

/**
 * Gets the current session.
 *
 * The method returns an error if the session cannot be created without user intervention.
 *
 * @returns A BFTask that resolves into a new `GINISession`.
 */
- (BFTask*)getSession;

/**
 * Performs a log in
 *
 * @returns A BFTask that resolves into a new `GINISession`.
 */
- (BFTask*)logIn;

@end

/**
* The session manager is responsible for the authentication against the GINI server whenever is needed.
* Authentication is required to perform requests to the GiniAPI.
*
* @see http://developer.gini.net/gini-api/html/guides/oauth2.html
*
*/
@interface GINISessionManager : NSObject <GINISessionManager, GINIIncomingURLDelegate> {

    /// The client ID given by Gini.
    NSString* _clientID;

    /// The base URL of the Gini OAuth server
    NSURL *_baseURL;

    /// The application scheme used for the redirection to the app once the on-browser authentication finishes.
    NSString *_appScheme;

    id<GINIURLSession> _URLSession;

    // State ivars

    /// The active session. Represents the current `GINISession` the user is logged in to.
    GINISession *_activeSession;

    /// The logIn task. Only one logIn task can be active at a time.
    BFTaskCompletionSource *_activeLogInTask;

    /// The logIn state. A unique string to identify which login task was used on the redirection to the OAuth server.
    NSString *_activeLogInState;
}

/**
*  Creates a manager that uses client-side authentication flow.
*
*  @param clientID         The clientID you received from Gini.
*  @param baseURL          The base URL of the Gini Oauth Server.
*  @param URLSession       The URLSession used to create URL requests.
*  @param appURLScheme     The application scheme of the client application. Used to redirect from the browser back to the app.
*
*  @return The initialized instance
*/
+ (instancetype)managerForClientFlowWithClientID:(NSString *)clientID
                                         baseURL:(NSURL *)baseURL
                                      URLSession:(id <GINIURLSession>)URLSession
                                    appURLScheme:(NSString *)appURLScheme;

/**
*  Creates a manager that uses server-side authentication flow.
*
*  @param clientID         The clientID you received from Gini.
*  @param clientSecret     The client secret you received from Gini.
*  @param credentialsStore Object that handles the storage of the tokens.
*  @param baseURL          The base URL of the Gini Oauth Server.
*  @param URLSession       The URLSession used to create URL requests.
*  @param appURLScheme     The application scheme of the client application. Used to redirect from the browser back to the app.
*
*  @return The initialized instance
*/
+ (instancetype)managerForServerFlowWithClientID:(NSString *)clientID
                                    clientSecret:(NSString *)clientSecret
                                credentialsStore:(id <GINICredentialsStore>)credentialsStore
                                         baseURL:(NSURL *)baseURL
                                      URLSession:(id <GINIURLSession>)URLSession
                                    appURLScheme:(NSString *)appURLScheme;

@end
