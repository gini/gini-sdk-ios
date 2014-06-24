/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIInjector.h"
#import "GINIFactoryDescription.h"
#import <objc/runtime.h>


id GINIInjectorKey(id key) {
    if ([key conformsToProtocol:@protocol(NSCopying)]) {
        return key;
    }
    return [NSValue valueWithNonretainedObject:key];
}

@implementation GINIInjector {
    /**
     * A mapping with all available singleton instances.
     */
    NSMutableDictionary *_singletonInstances;
    /**
     * A mapping with all available providers.
     */
    NSMutableDictionary *_factories;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _singletonInstances = [NSMutableDictionary new];
        _factories = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - Factory related methods
- (GINIFactoryDescription *)setFactory:(SEL)method on:(id)classOrObject forKey:(id)key withDependencies:firstDependency, ...{
    NSParameterAssert(method);
    NSParameterAssert([classOrObject respondsToSelector:method]);
    NSParameterAssert(key);

    // Create the list of dependencies
    NSMutableArray *dependencies = [NSMutableArray new];
    va_list args;
    va_start(args, firstDependency);
    for (id dependency = firstDependency; dependency != nil; dependency = va_arg(args, id)) {
        [dependencies addObject:dependency];
    }
    va_end(args);

    GINIFactoryDescription *factoryDescription = [GINIFactoryDescription factoryDescriptionForFactory:method on:classOrObject dependencies:dependencies];
    [_factories setObject:factoryDescription forKey:GINIInjectorKey(key)];
    return factoryDescription;
}

- (GINIFactoryDescription *)setSingletonFactory:(SEL)method on:(id)classOrObject forKey:(id)key withDependencies:firstDependency, ...{
    NSParameterAssert(method);
    NSParameterAssert([classOrObject respondsToSelector:method]);
    NSParameterAssert(key);

    // Create the list of dependencies
    NSMutableArray *dependencies = [NSMutableArray new];
    va_list args;
    va_start(args, firstDependency);
    for (id dependency = firstDependency; dependency != nil; dependency = va_arg(args, id)) {
        [dependencies addObject:dependency];
    }
    va_end(args);

    GINIFactoryDescription *factoryDescription = [GINIFactoryDescription factoryDescriptionForFactory:method on:classOrObject dependencies:dependencies];
    [_factories setObject:factoryDescription forKey:GINIInjectorKey(key)];
    factoryDescription.isSingleton = YES;
    return factoryDescription;
}

- (id)factoryForKey:(id)key {
    return [_factories objectForKey:GINIInjectorKey(key)];
}

- (void)setObject:(id)value forKey:(id)key {
    _factories[GINIInjectorKey(key)] = value;
}


#pragma mark - Getting instances related methods
- (id)getInstanceOf:(id)key {
    return [self getInstanceOf:key provideDependencies:nil];
}

- (id)getInstanceOf:(id)key provideDependencies:(NSDictionary *)givenDependencies {
    id factory = [self factoryForKey:key];
    if (!factory) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"No known factory for key %@", key]
                                     userInfo:nil];
    }

    // Return the value if it is a value
    if (![factory isKindOfClass:[GINIFactoryDescription class]]) {
        return factory;
    }

    GINIFactoryDescription *factoryDescription = (GINIFactoryDescription *)factory;

    // Return a previously created singleton instance if available.
    id instance = [self singletonInstanceForKey:key];
    if (instance) {
        return instance;
    }

    NSMethodSignature *signature = [factoryDescription.object methodSignatureForSelector:factoryDescription.factoryMethod];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:factoryDescription.factoryMethod];

    // Get the instances of the dependencies.
    for (NSUInteger i=0; i < [factoryDescription.dependencies count]; i += 1) {
        id dependencyKey = factoryDescription.dependencies[i];
        id dependencyInstance = [givenDependencies objectForKey:dependencyKey];
        if (!dependencyInstance) {
            dependencyInstance = [self getInstanceOf:dependencyKey provideDependencies:nil];
        }
        [invocation setArgument:&dependencyInstance atIndex:i + 2]; // The first two arguments are always self and _cmd
    }

    // And finally call the factory with all the created dependencies.
    [invocation invokeWithTarget:factoryDescription.object];
    [invocation getReturnValue:&instance];

    if (factoryDescription.isSingleton) {
        [self setSingletonInstance:instance forKey:key];
    }

    return instance;
}

#pragma mark - Private methods
- (void)setSingletonInstance:(id)instance forKey:(id)key {
    _singletonInstances[GINIInjectorKey(key)] = instance;
}

- (id)singletonInstanceForKey:(id)key {
    key = GINIInjectorKey(key);
    GINIFactoryDescription *factoryDescription = _factories[key];
    if (!factoryDescription.isSingleton) {
        return nil;
    }
    return _singletonInstances[key];
}

@end