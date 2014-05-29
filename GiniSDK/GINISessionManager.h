#import <Foundation/Foundation.h>

@class BFTask;


/**
 * The GINISessionManager handles all communication and tasks related to the user authentication and authorization.
 */
@protocol GINISessionManager <NSObject>

@required
/**
 * Method to get a valid session of the currently active user. Returns a BFTask* that will resolve to a GINISession
 * model with the active session.
 */
- (BFTask *)getSession;

@end
