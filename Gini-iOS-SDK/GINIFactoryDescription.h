/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>


/**
* A value object for storing information about a factory. Used by the GINIInjector.
*/
@interface GINIFactoryDescription : NSObject

/**
* Whether or not the created instance is thought as a singleton. Please notice that a singleton is a singleton per
* injector, not per application.
*/
@property BOOL isSingleton;

/**
* The method of the object that will get called to create the instance.
*/
@property SEL factoryMethod;

/**
* The object that has the factory method.
*/
@property id object;

/**
* An array containing dependency keys. Instances of the object for the given key are given as arguments to the factory
* in the order they are appearing in this array.
*/
@property NSArray *dependencies;

/**
 * Factory to create a new factory description :-).
 *
 * @param method            A selector for the method on the class or object.
 *
 * @param classOrObject     The class or object on which the factory method is available.
 *
 * @param dependencies      An array describing the method's arguments (as a collection of dependency keys, see the
 *                          discussion on keys at the `GINIInjector` class.
 */
+ (instancetype)factoryDescriptionForFactory:(SEL)method on:(id)classOrObject dependencies:(NSArray *)dependencies;
@end
