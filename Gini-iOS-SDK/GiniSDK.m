/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */
#import "GiniSDK.h"


NSString *const GINIInjectorAPIBaseURLKey = @"APIBaseURL";
NSString *const GINIInjectorUserBaseURLKey = @"UserBaseURL";
NSString *const GINIInjectorURLSchemeKey = @"AppURLScheme";
NSString *const GINIInjectorClientSecretKey = @"AppClientSecret";
NSString *const GINIInjectorClientIDKey = @"AppClientId";


@implementation GiniSDK{
    /** The injector instance that is used to get the instances of needed classes */
    GINIInjector *_injector;

    // Properties
    GINIAPIManager *_APIManager;
    id <GINISessionManager, GINIIncomingURLDelegate> _sessionManager;
    GINIDocumentTaskManager *_documentTaskManager;
}

#pragma mark - Initializer

- (instancetype)initWithInjector:(GINIInjector *)injector{
    NSParameterAssert([injector isKindOfClass:[GINIInjector class]]);

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
