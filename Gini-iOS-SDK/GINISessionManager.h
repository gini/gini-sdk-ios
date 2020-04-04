/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIIncomingURLDelegate.h"

@class BFTask, BFTaskCompletionSource, GINISession;
@protocol GINICredentialsStore, GINIURLSession;

// TODO: Move to more a general class (common)
extern NSStringEncoding const GINIStringEncoding;


/**
* This protocol describes the behaviour of session managers.
*
* The session manager is responsible for the OAuth authorisation of Gini accounts. The authorisation is required to
* do requests to the GiniAPI.
*
* See http://developer.gini.net/gini-api/html/guides/oauth2.html for details.
*/

@protocol GINISessionManager <NSObject>

/**
 * Gets the current session.
 *
 * The returned task will fail if the session manager can't reuse or create a session without user intervention (which
 * means that the user has to log in again). This expected error is a `GINIError` instance. If the task fails with a
 * `GINIError`, the application must log in the user via the session manager's `logIn` method. There may be other errors
 * (like network errors when there is no internet connection and so on). Those errors are a `NSError` instance.
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
* The session manager is responsible for the authorization against the GINI server whenever is needed.
* authorization is required to perform requests to the GiniAPI.
*
* @see http://developer.gini.net/gini-api/html/guides/oauth2.html
*
*/
@interface GINISessionManager : NSObject <GINISessionManager, GINIIncomingURLDelegate> {

    /// The client ID given by Gini.
    NSString* _clientID;

    /// The application scheme used for the redirection to the app once the on-browser authorization finishes.
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

/// The base URL of the Gini OAuth server
@property (readonly) NSURL *baseURL;

/**
*  Creates a manager that uses client-side authorization flow.
*
*  @param clientID         The clientID you received from Gini.
*  @param baseURL          The base URL of the Gini OAuth Server.
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
*  Creates a manager that uses server-side authorization flow.
*
*  @param clientID         The clientID you received from Gini.
*  @param clientSecret     The client secret you received from Gini.
*  @param credentialsStore Object that handles the storage of the tokens.
*  @param baseURL          The base URL of the Gini OAuth Server.
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
