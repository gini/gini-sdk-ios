#import <Foundation/Foundation.h>


/**
 * GINISession
 *
 * @abstract
 * The GINISession is the data model for the currently active session. It stores all needed data that is needed to
 * handle the oAuth-related communication of the application.
 */
@interface GINISession : NSObject

/**
 * The access token of this session.
 */
@property NSString *accessToken;
/**
 * The refresh token of this session that can be used to get a new access token.
 */
@property NSString *refreshToken;
/**
 * The date when the session will expire.
 */
@property NSDate *expiresAt;


/**
 * The designated initializer.
 */
- (instancetype)initWithAccessToken:(NSString *)token andRefreshToken:(NSString *)refresh expiresAt:(NSDate *)expires;
@end