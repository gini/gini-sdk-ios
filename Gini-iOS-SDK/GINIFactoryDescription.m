/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIFactoryDescription.h"


@implementation GINIFactoryDescription

+ (instancetype)factoryDescriptionForFactory:(SEL)method on:(id)classOrObject dependencies:(NSArray *)dependencies {
    NSParameterAssert([classOrObject respondsToSelector:method]);

    GINIFactoryDescription *factoryDescription = [GINIFactoryDescription new];
    factoryDescription.factoryMethod = method;
    factoryDescription.object = classOrObject;
    factoryDescription.dependencies = dependencies;

    return factoryDescription;
}

@end
