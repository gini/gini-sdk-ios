/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */
#import "GiniSDK.h"
#import "GINIKeychainManager.h"


NSString *const GINIAPIBaseURLKey = @"APIBaseURL";
NSString *const GINIUserBaseURLKey = @"UserBaseURL";
NSString *const GINIURLSchemeKey = @"AppURLScheme";
NSString *const GINIClientSecretKey = @"AppClientSecret";
NSString *const GINIClientIDKey = @"AppClientId";


@implementation GINIInjector (DefaultWiring)

+ (instancetype)defaultInjector{
    GINIInjector *injector = [GINIInjector new];

    // API Manager
    [injector setObject:[NSURL URLWithString:@"https://api.gini.net/"] forKey:GINIAPIBaseURLKey];
    [injector setSingletonFactory:@selector(apiManagerWithURLSession:requestFactory:baseURL:)
                      on:[GINIAPIManager class]
                  forKey:[GINIAPIManager class]
        withDependencies:@protocol(GINIURLSession), @protocol(GINIAPIManagerRequestFactory), GINIAPIBaseURLKey, nil];

    // URLSession
    [injector setFactory:@selector(urlSession)
                      on:[GINIURLSession class]
                  forKey:@protocol(GINIURLSession)
        withDependencies:nil];

    // APIRequestFactory
    [injector setSingletonFactory:@selector(requestFactoryWithSessionManager:)
                      on:[GINIAPIManagerRequestFactory class]
                  forKey:@protocol(GINIAPIManagerRequestFactory)
        withDependencies:@protocol(GINISessionManager), nil];

    // Session manager
    [injector setObject:[NSURL URLWithString:@"https://user.gini.net/"] forKey:GINIUserBaseURLKey];
    [injector setSingletonFactory:@selector(managerForClientFlowWithClientID:baseURL:URLSession:appURLScheme:)
                      on:[GINISessionManager class]
                  forKey:@protocol(GINISessionManager)
        withDependencies:GINIClientIDKey, GINIUserBaseURLKey, @protocol(GINIURLSession), GINIURLSchemeKey, nil];

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

    return injector;
}

@end


@implementation GiniSDK{
    /** The injector instance that is used to get the instances of needed classes */
    GINIInjector *_injector;

    // Properties
    GINIAPIManager *_APIManager;
    id <GINISessionManager, GINIIncomingURLDelegate> _sessionManager;
    GINIDocumentTaskManager *_documentTaskManager;
}

#pragma mark - Factories

+ (instancetype)giniSDKWithAppURLScheme:(NSString *)urlScheme clientID:(NSString *)clientID {
    NSParameterAssert([urlScheme isKindOfClass:[NSString class]]);
    NSParameterAssert([clientID isKindOfClass:[NSString class]]);

    GiniSDK *sdkInstance = [[GiniSDK alloc] initWithInjector:[GINIInjector defaultInjector]];
    GINIInjector *injector = sdkInstance.injector;
    [injector setObject:urlScheme forKey:GINIURLSchemeKey];
    [injector setObject:clientID forKey:GINIClientIDKey];
    return sdkInstance;
}

+ (instancetype)giniSDKWithAppURLScheme:(NSString *)urlScheme clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
    NSParameterAssert([urlScheme isKindOfClass:[NSString class]]);
    NSParameterAssert([clientSecret isKindOfClass:[NSString class]]);
    NSParameterAssert([clientID isKindOfClass:[NSString class]]);

    GiniSDK *sdkInstance = [GiniSDK giniSDKWithAppURLScheme:urlScheme clientID:clientID];
    GINIInjector *injector = sdkInstance.injector;
    // The default injector uses the client based authentication flow. We just set a new factory for the
    // <GINISessionManager> protocol, so the server based authentication flow is used and we're done.
    [injector setSingletonFactory:@selector(managerForServerFlowWithClientID:clientSecret:credentialsStore:baseURL:URLSession:appURLScheme:)
                               on:[GINISessionManager class]
                           forKey:@protocol(GINISessionManager)
                 withDependencies:GINIClientIDKey, GINIClientSecretKey, @protocol(GINICredentialsStore), GINIUserBaseURLKey, @protocol(GINIURLSession), GINIURLSchemeKey, nil];
    [injector setSingletonFactory:@selector(credentialsStoreWithKeychainManager:)
                               on:[GINIKeychainCredentialsStore class]
                           forKey:@protocol(GINICredentialsStore)
                 withDependencies:[GINIKeychainManager class], nil];
    // And provide the client secret for the injector.
    [injector setObject:clientSecret forKey:GINIClientSecretKey];
    return sdkInstance;
}

+ (instancetype)sandboxGiniSDKWithAppURLScheme:(NSString *)urlScheme clientID:(NSString *)clientID {
    // Create a "normal" SDK instance...
    GiniSDK *giniSDK = [GiniSDK giniSDKWithAppURLScheme:urlScheme clientID:clientID];
    // ..but change some configuration values in the injector.
    [giniSDK.injector setObject:[NSURL URLWithString:@"https://api-sandbox.gini.net/"] forKey:GINIAPIBaseURLKey];
    [giniSDK.injector setObject:[NSURL URLWithString:@"https://user-sandbox.gini.net/"] forKey:GINIUserBaseURLKey];
    return giniSDK;
}

+ (instancetype)sandboxGiniSDKWithAppURLScheme:(NSString *)urlScheme clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
    // Create a "normal" SDK instance...
    GiniSDK *giniSDK = [GiniSDK giniSDKWithAppURLScheme:urlScheme clientID:clientID clientSecret:clientSecret];
    // ...but change some configuration values in the injector.
    [giniSDK.injector setObject:[NSURL URLWithString:@"https://api-sandbox.gini.net/"] forKey:GINIAPIBaseURLKey];
    [giniSDK.injector setObject:[NSURL URLWithString:@"https://user-sandbox.gini.net/"] forKey:GINIUserBaseURLKey];
    return giniSDK;
}


#pragma mark - Initializer

- (instancetype)initWithInjector:(GINIInjector *)injector{
    self = [super init];
    if (self) {
        _injector = injector;
    }
    return self;
}

#pragma mark - Properties
- (GINIAPIManager *)APIManager {
    if (!_APIManager) {
        _APIManager = [_injector getInstanceOf:[GINIAPIManager class]];
    }
    return _APIManager;
}

- (id <GINISessionManager, GINIIncomingURLDelegate>)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [_injector getInstanceOf:@protocol(GINISessionManager)];
    }
    return _sessionManager;
}

- (GINIDocumentTaskManager *)documentTaskManager {
    if (!_documentTaskManager) {
        _documentTaskManager = [_injector getInstanceOf:[GINIDocumentTaskManager class]];
    }
    return _documentTaskManager;
}


@end
