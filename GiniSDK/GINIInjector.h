/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>


@class GINIFactoryDescription;


/**
 * Helper function to use an an arbitrary Objective C object in dictionaries that describe or provide dependencies.
 * Wraps the given object into a NSValue* if it does not conform to the <NSCopying> protocol, otherwise returns the
 * same object. The returned value can always be used as the key for the given object in a NSDictionary, e.g. in a
 * mapping when providing dependencies.
 */
id GINIInjectorKey(id key);


/**
 * The GINIInjector is used to have some kind of dependency injection. It provides methods to register factories and
 * getting instances of objects which are created by the previously registered factories.
 *
 * Base concepts and design decisions
 * ----------------------------------
 * The base concept of the injector is that all object instances must be created via factories.
 *
 * Factories
 * =========
 * Every dependency that is injectable must have a factory. The factory is responsible to create an instance of the
 * dependency.
 *
 * At the moment, the injector only supports factories that are either a class method or an instance method.
 *
 * Keys
 * ====
 * Unfortunately, Objective-C does not have true reflection, so it is not possible to get information on needed
 * dependencies of factories by simply looking at the function signature. Because of that, every dependency is
 * identified by a key. A key is unique per injector instance, which means that you should chose a key that is somehow
 * connected to the dependency to avoid having key collisions.
 *
 * Values
 * ======
 * Some dependencies are just configuration issues (e.g. the base URL for a remote API) and it would be some kind of
 * overhead to have factories for such cases. Because of that, the injector provides the possibility to have so called
 * Values. The values are already created instances.
 *
 */
@interface GINIInjector : NSObject

/**
 * Method to register the factory for the dependency with the given key.
 *
 * Sets the given method of the given class or object as the factory for the given key. There can only be one factory
 * for a key, so this method overwrites any previously registered factory with the same key.
 *
 * @param method            The selector for a method (either class method or instance method). This method is the
 *                          factory and should return an object instance.
 *                          It gets called by the injector with its needed dependencies if an instance of the object
 *                          with the registered key is wanted.
 *
 * @param classOrObject     The class (if the `method` selector is for a class method) or the object (if the `method`
 *                          selector is for an instance method) on which the factory method is called.
 *
 * @param key               The identifier that identifies the dependency (see the discussion on keys).
 *
 * @param firstDependency   A nil terminated list of keys. If the factory is called by the injector, the injector
 *                          passes-in instances of the dependencies as the arguments of the factory in exactly the same
 *                          order as they appear in this list.
 *
 */
- (GINIFactoryDescription *)setFactory:(SEL)method on:(id)classOrObject forKey:(id)key withDependencies:firstDependency, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Method to register the singleton factory for the dependency with the given key. The factory is called by the injector
 * only the first time an instance of the object with the given key is requested. All other times, the instance which
 * was created on the first time is returned (making the instance a singleton for the injector).
 *
 * Sets the given method of the given class or object as the factory for the given key. There can only be one factory
 * for a key, so this method overwrites any previously registered factory with the same key.
 *
 * @param method            The selector for a method (either class method or instance method). This method is the
 *                          factory and should return an object instance.
 *                          It gets called by the injector with its needed dependencies if an instance of the object
 *                          with the registered key is wanted.
 *
 * @param classOrObject     The class (if the `method` selector is for a class method) or the object (if the `method`
 *                          selector is for an instance method) on which the factory method is called.
 *
 * @param key               The identifier that identifies the dependency (see the discussion on keys).
 *
 * @param firstDependency   A nil terminated list of keys. If the factory is called by the injector, the injector
 *                          passes-in instances of the dependencies as the arguments of the factory in exactly the same
 *                          order as they appear in this list.
 *
 */
- (GINIFactoryDescription *)setSingletonFactory:(SEL)method on:(id)classOrObject forKey:(id)key withDependencies:(id)firstDependency, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Returns either the factory description for the factory which has been registered for the given key or the object that
 * has been registered as the value for the given key.
 *
 * Returns nil if there isn't any factory or value registered for the key.
 *
 * @param key               The key identifying the dependency.
 */
- (id)factoryForKey:(id)key;

/**
 * Set the given object as the value for the given key. This is a shortcut for values that do not really need a factory,
 * e.g. configuration strings. Instead of calling a factory, the injector always returns the given object when an
 * instance for the given key is requested.
 *
 * @param value             The object that is the value that should be returned if an instance for the dependency
 *                          with the given key is requested.
 *
 * @param key               The key identifying the dependency.
 */
- (void)setObject:(id)value forKey:(id)key;

/**
* Returns an instance of the dependency with the given key.
*
* @param key                   The key identifying the dependency.
*/
- (id)getInstanceOf:(id)key;

/**
 * Returns an instance of the dependency with the given key but provides the possibility to bypass the injector for its
 * dependencies.
 *
 * You can use the helper function `GINIInjectorKey` to create the mapping keys which identify dependencies.
 *
 * @warning
 * Please notice that singletons will not be initialized a second time, even if the provided dependencies differ!
 *
 * @param key               The key identifying the dependency.
 * @param givenDependencies A mapping containing already instantiated dependencies. The injector then injects this
 *                          provided instances instead of calling the corresponding factories.
 */
- (id)getInstanceOf:(id)key provideDependencies:(NSDictionary *)givenDependencies;

@end
