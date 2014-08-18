/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/BFTask.h>
#import "GINIUserCenterManager.h"
#import "GINIURLSession.h"
#import "GINISession.h"
#import "GINIURLResponse.h"
#import "GINISessionParser.h"
#import "NSString+GINIAdditions.h"
#import "GINIUser.h"


@implementation GINIUserCenterManager {
    id<GINIURLSession> _urlSession;
    NSString *_clientID;
    NSString *_clientSecret;
    NSURL *_baseURL;

    /**
     * The active session to use for requests to the Gini User Center API.
     *
     * @warning These sessions have nothing to do with the sessions of the Gini API which are used in the
     * `GINISessionManager`. Do not mix them up.
     */
    GINISession *_activeSession;
}

+ (instancetype)userCenterManagerWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL {
    return [[GINIUserCenterManager alloc] initWithURLSession:urlSession clientID:clientID clientSecret:clientSecret baseURL:baseURL];
}

- (instancetype)initWithURLSession:(id <GINIURLSession>)urlSession clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret baseURL:(NSURL *)baseURL {
    NSParameterAssert([urlSession conformsToProtocol:@protocol(GINIURLSession)]);
    NSParameterAssert([clientID isKindOfClass:[NSString class]]);
    NSParameterAssert([clientSecret isKindOfClass:[NSString class]]);
    NSParameterAssert([baseURL isKindOfClass:[NSURL class]]);

    if (self = [super init]) {
        _urlSession = urlSession;
        _clientID = clientID;
        _clientSecret = clientSecret;
        _baseURL = baseURL;
    }
    return self;
}

#pragma mark - Public methods
- (BFTask *)getUserInfo:(NSString *)userID {
    NSParameterAssert([userID isKindOfClass:[NSString class]]);

    return [[self createMutableURLRequest:[NSString stringWithFormat:@"/api/users/%@", userID] httpMethod:@"GET"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *urlRequest = requestTask.result;
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        return [[_urlSession BFDataTaskWithRequest:urlRequest] continueWithSuccessBlock:^id(BFTask *task) {
            GINIURLResponse *urlResponse = task.result;
            return [GINIUser userFromAPIResponse:urlResponse.data];
        }];
    }];
}

- (BFTask *)createUserWithEmail:(NSString *)email password:(NSString *)password {
    NSParameterAssert([email isKindOfClass:[NSString class]]);
    NSParameterAssert([password isKindOfClass:[NSString class]]);

    // This needs an active session with a bearer token.
    return [[self createMutableURLRequest:@"/api/users" httpMethod:@"POST"] continueWithSuccessBlock:^id(BFTask *requestTask) {
        NSMutableURLRequest *urlRequest = requestTask.result;
        NSDictionary *payload = @{
                @"email" : email,
                @"password" : password
        };
        NSError *serializationError;
        [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:payload options:0 error:&serializationError]];
        if (serializationError) {
            return serializationError;
        }
        return [[_urlSession BFDataTaskWithRequest:urlRequest] continueWithSuccessBlock:^id(BFTask *createTask) {
            GINIURLResponse *urlResponse = createTask.result;
            NSString *location = [urlResponse.response.allHeaderFields valueForKey:@"Location"];
            NSString *userId = [[location componentsSeparatedByString:@"/"] lastObject];
            return [GINIUser userWithEmail:email userId:userId];
        }];
    }];
}

- (BFTask *)loginUser:(NSString *)userName password:(NSString *)password {
    NSParameterAssert([userName isKindOfClass:[NSString class]]);
    NSParameterAssert([password isKindOfClass:[NSString class]]);

    // Login request (Please note that it uses the HTTP Basic authorization and not the Bearer token).
    NSURL *URL = [NSURL URLWithString:@"/oauth/token?grant_type=password" relativeToURL:_baseURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:URL];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:[self createLoginHeader] forHTTPHeaderField:@"Authorization"];
    // Login data (x-www-urlencoded).
    NSData *loginData = [[NSString stringWithFormat:@"username=%@&password=%@", stringByEscapingString(userName), stringByEscapingString(password)] dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:loginData];
    [urlRequest setValue:@"application/x-www-urlencoded" forHTTPHeaderField:@"Content-Type"];

    // Do the request and create the session form the response.
    return [[_urlSession BFDataTaskWithRequest:urlRequest] continueWithSuccessBlock:^id(BFTask *loginTask) {
        GINIURLResponse *response = loginTask.result;
        return [GINISessionParser sessionWithJSONDictionary:response.data];
    }];
}

#pragma mark - Private methods
/**
 * Gets a valid `GINISession` instance with an access token that could be used for requests to the Gini User Center API.
 * If the app has not been logged in yet in this `GINIUserManager` instance or the access token has expired, the app is
 * logged in again.
 *
 * @returns     A `BFTask*` that resolves to a `GINISession` instance.
 */
- (BFTask *)getSession {

    // If there's already an active session, resolve to the session.
    if (_activeSession && !_activeSession.hasAlreadyExpired) {
        return [BFTask taskWithResult:_activeSession];
    }
    // Otherwise log in.
    return [self login];
}

/**
 * Logs-in the app so it gets an authorisation token which can be used to do requests to the Gini User Center API.
 *
 * @returns     A `BFTask*` that resolves to a `GINISession` instance.
 *
 * @warning This login has nothing to do with the Gini API login. Please do not mix them up.
 */
- (BFTask *)login {

    NSURL *loginURL = [NSURL URLWithString:@"/oauth/token?grant_type=client_credentials" relativeToURL:_baseURL];
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginURL];
    [loginRequest setHTTPMethod:@"GET"];
    [loginRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [loginRequest setValue:[self createLoginHeader] forHTTPHeaderField:@"Authorization"];
    return [[_urlSession BFDataTaskWithRequest:loginRequest] continueWithSuccessBlock:^id(BFTask *task) {
        GINIURLResponse *response = task.result;
        NSDictionary *sessionData = response.data;

        GINISession *activeSession =  [GINISessionParser sessionWithJSONDictionary:sessionData];
        _activeSession = activeSession;
        return activeSession;
    }];
}

/**
 * Creates a new `NSString` that can be used as the HTTP Authorization header in a login request (HTTP Basic
 * Authorization).
 */
- (NSString *)createLoginHeader {

    // The HTTP basic authorization is a base64 encoded string with "username:password"
    NSString *loginString = [NSString stringWithFormat:@"%@:%@", _clientID, _clientSecret];
    NSData *loginData = [loginString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64LoginData = [loginData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithFormat:@"Basic %@", [[NSString alloc] initWithData:base64LoginData encoding:NSUTF8StringEncoding]];
}

/**
 * Creates a MutableURLRequest that has always a valid access token.
 */
- (BFTask *)createMutableURLRequest:(NSString *)URL httpMethod:(NSString *)httpMethod {
    return [[self getSession] continueWithSuccessBlock:^id(BFTask *task) {
        GINISession *session = task.result;
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL relativeToURL:_baseURL]];
        [urlRequest setValue:[NSString stringWithFormat:@"BEARER %@", session.accessToken] forHTTPHeaderField:@"Authorization"];
        [urlRequest setHTTPMethod:httpMethod];
        return urlRequest;
    }];
}
@end
