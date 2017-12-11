/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINISDKBuilder.h"
#import "GiniSDK.h"
#import "GINISessionManagerAnonymous.h"


NSString *const GINIEmailDomainKey = @"emailDomain";


GINIInjector* GINIDefaultInjector() {
    GINIInjector *injector = [GINIInjector new];

    // API Manager
    [injector setObject:[NSURL URLWithString:@"https://api.gini.net/"] forKey:GINIInjectorAPIBaseURLKey];
    [injector setSingletonFactory:@selector(apiManagerWithURLSession:requestFactory:baseURL:)
                               on:[GINIAPIManager class]
                           forKey:[GINIAPIManager class]
                 withDependencies:@protocol(GINIURLSession), @protocol(GINIAPIManagerRequestFactory), GINIInjectorAPIBaseURLKey, nil];
    
    // URLSessionDelegate
    [injector setSingletonFactory:@selector(urlSessionDelegateWithCertPath:)
                               on:[GINIURLSessionDelegate class]
                           forKey:@protocol(GINIURLSessionDelegate)
                 withDependencies:GINIInjectorCertPathKey, nil];
    
    // URLSession
    [injector setFactory:@selector(urlSession:)
                      on:[GINIURLSession class]
                  forKey:@protocol(GINIURLSession)
        withDependencies:@protocol(GINIURLSessionDelegate), nil];

    // APIRequestFactory
    [injector setSingletonFactory:@selector(requestFactoryWithSessionManager:)
                               on:[GINIAPIManagerRequestFactory class]
                           forKey:@protocol(GINIAPIManagerRequestFactory)
                 withDependencies:@protocol(GINISessionManager), nil];

    // Session manager
    [injector setObject:[NSURL URLWithString:@"https://user.gini.net/"] forKey:GINIInjectorUserBaseURLKey];
    [injector setSingletonFactory:@selector(managerForClientFlowWithClientID:baseURL:URLSession:appURLScheme:)
                               on:[GINISessionManager class]
                           forKey:@protocol(GINISessionManager)
                 withDependencies:GINIInjectorClientIDKey, GINIInjectorUserBaseURLKey, @protocol(GINIURLSession), GINIInjectorURLSchemeKey, nil];

    // DocumentTaskManager
    [injector setSingletonFactory:@selector(documentTaskManagerWithAPIManager:)
                               on:[GINIDocumentTaskManager class]
                           forKey:[GINIDocumentTaskManager class]
                 withDependencies:[GINIAPIManager class], nil];

    // Keychain manager
    [injector setSingletonFactory:@selector(new)
                               on:[GINIKeychainManager class]
                           forKey:[GINIKeychainManager class]
                 withDependencies:nil];

    // Credentials store
    [injector setSingletonFactory:@selector(credentialsStoreWithKeychainManager:)
                               on:[GINIKeychainCredentialsStore class]
                           forKey:@protocol(GINICredentialsStore)
                 withDependencies:[GINIKeychainManager class], nil];

    // User Center Manager
    [injector setSingletonFactory:@selector(userCenterManagerWithURLSession:clientID:clientSecret:baseURL:notificationCenter:)
                               on:[GINIUserCenterManager class]
                           forKey:[GINIUserCenterManager class]
                 withDependencies:@protocol(GINIURLSession), GINIInjectorClientIDKey, GINIInjectorClientSecretKey, GINIInjectorUserBaseURLKey, [NSNotificationCenter class], nil];

    // Use the default notification center as notification center for the Gini API.
    [injector setSingletonFactory:@selector(defaultCenter) on:[NSNotificationCenter class] forKey:[NSNotificationCenter class] withDependencies:nil];

    return injector;
}


@implementation GINISDKBuilder {
    GINIInjector *_injector;
}

#pragma mark - Factories
+ (instancetype)clientFlowWithClientID:(NSString *)clientID urlScheme:(NSString *)urlScheme {
    return [self clientFlowWithClientID:clientID urlScheme:urlScheme certPath:nil];
}

+ (instancetype)clientFlowWithClientID:(NSString *)clientID urlScheme:(NSString *)urlScheme
                              certPath:(NSString *)certPath {
    NSParameterAssert([clientID isKindOfClass:[NSString class]]);
    NSParameterAssert([urlScheme isKindOfClass:[NSString class]]);
    
    return [[self alloc] initWithClientID:clientID urlScheme:urlScheme clientSecret:nil certPath: certPath];
}

+ (instancetype)serverFlowWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret urlScheme:(NSString *)urlScheme {
    return [self serverFlowWithClientID:clientID clientSecret:clientSecret urlScheme:urlScheme certPath:nil];
}

+ (instancetype)serverFlowWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret urlScheme:(NSString *)urlScheme
                              certPath:(NSString *)certPath {
    NSParameterAssert([clientID isKindOfClass:[NSString class]]);
    NSParameterAssert([clientSecret isKindOfClass:[NSString class]]);
    NSParameterAssert([urlScheme isKindOfClass:[NSString class]]);
    
    GINISDKBuilder *instance = [[self alloc] initWithClientID:clientID urlScheme:urlScheme clientSecret:clientSecret certPath:certPath];
    [instance useServerFlow];
    return instance;
}

+ (instancetype)anonymousUserWithClientID:(NSString *)clientId clientSecret:(NSString *)clientSecret userEmailDomain:(NSString *)emailDomain {
    return [self anonymousUserWithClientID:clientId clientSecret:clientSecret userEmailDomain:emailDomain certPath:nil];
}

+ (instancetype)anonymousUserWithClientID:(NSString *)clientId clientSecret:(NSString *)clientSecret userEmailDomain:(NSString *)emailDomain
                                 certPath:(NSString *)certPath {
    NSParameterAssert([clientId isKindOfClass:[NSString class]]);
    NSParameterAssert([emailDomain isKindOfClass:[NSString class]]);
    NSParameterAssert([clientSecret isKindOfClass:[NSString class]]);
    
    GINISDKBuilder *instance = [[self alloc] initWithClientID:clientId urlScheme:nil clientSecret:clientSecret certPath:certPath];
    [instance useAnonymousUser:emailDomain];
    return instance;
}

#pragma mark - Initializer
- (instancetype)init{
    @throw [NSException exceptionWithName:@"Not allowed"
                                   reason:@"Use the designated initializer to initialize the SDK builder"
                                 userInfo:nil];
}

- (instancetype)initWithClientID:(NSString *)clientID urlScheme:(NSString *)urlScheme clientSecret:(NSString *)clientSecret
                        certPath:(NSString *)certPath {
    NSParameterAssert([clientID isKindOfClass:[NSString class]]);

    if (self = [super init]) {
        _injector = GINIDefaultInjector();
        [_injector setObject:clientID forKey:GINIInjectorClientIDKey];
        if (urlScheme != nil) {
            [_injector setObject:urlScheme forKey:GINIInjectorURLSchemeKey];
        }
        if (clientSecret != nil) {
            [_injector setObject:clientSecret forKey:GINIInjectorClientSecretKey];
        }
        if (certPath != nil) {
            [_injector setObject:certPath forKey:GINIInjectorCertPathKey];
        }
    }
    return self;
}


#pragma mark - Public Methods
- (instancetype)useSandbox {
    [_injector setObject:[NSURL URLWithString:@"https://api-sandbox.gini.net/"] forKey:GINIInjectorAPIBaseURLKey];
    [_injector setObject:[NSURL URLWithString:@"https://user-sandbox.gini.net/"] forKey:GINIInjectorUserBaseURLKey];
    return self;
}

- (instancetype)useNotificationCenter:(NSNotificationCenter *)notificationCenter {
    [_injector setObject:notificationCenter forKey:[NSNotificationCenter class]];
    return self;
}


- (GiniSDK *)build {
    return [[GiniSDK alloc] initWithInjector:_injector];
}


#pragma mark - Private configuration helpers
- (void)useServerFlow {
    // The default injector uses the client based authentication flow. We just set a new factory for the
    // <GINISessionManager> protocol, so the server based authentication flow is used and we're done.
    [_injector setSingletonFactory:@selector(managerForServerFlowWithClientID:clientSecret:credentialsStore:baseURL:URLSession:appURLScheme:)
                                on:[GINISessionManager class]
                            forKey:@protocol(GINISessionManager)
                  withDependencies:GINIInjectorClientIDKey, GINIInjectorClientSecretKey, @protocol(GINICredentialsStore), GINIInjectorUserBaseURLKey, @protocol(GINIURLSession), GINIInjectorURLSchemeKey, nil];
    [_injector setSingletonFactory:@selector(credentialsStoreWithKeychainManager:)
                                on:[GINIKeychainCredentialsStore class]
                            forKey:@protocol(GINICredentialsStore)
                  withDependencies:[GINIKeychainManager class], nil];
}

- (void)useAnonymousUser:(NSString *)emailDomain {
    [_injector setObject:emailDomain forKey:GINIEmailDomainKey];
    [_injector setSingletonFactory:@selector(sessionManagerWithCredentialsStore:userCenterManager:emailDomain:notificationCenter:)
                                on:[GINISessionManagerAnonymous class]
                            forKey:@protocol(GINISessionManager)
                  withDependencies:@protocol(GINICredentialsStore), [GINIUserCenterManager class], GINIEmailDomainKey, [NSNotificationCenter class], nil];
}

@end
