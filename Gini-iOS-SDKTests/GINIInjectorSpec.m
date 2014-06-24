#import <Kiwi/Kiwi.h>
#import "GINIInjector.h"
#import "GINIFactoryDescription.h"


// How many times the factory was called
NSUInteger GINICreateFoobarCalled;

@protocol GINIInjectorTestProtocol
@end

@protocol GININotImplementedInjectorTestProtocol
@end;


@interface GINIINjectorTestClass : NSObject <GINIInjectorTestProtocol>
- (instancetype)initWithFoobar:(id)foobar;
@end

@implementation GINIINjectorTestClass
- (instancetype)initWithFoobar:(id)foobar {
    return nil;
}
@end


@interface GINIInjectorTestFactory : NSObject
+ (id)createFoobar;
+ (id)createRaboofWithFoobar:(NSString *)foobar;
+ (id)createFoobarWithRaboof:(NSString *)raboof andFoobar:(NSString *)foobar;

- (id)instanceCreateFoobar;
@end

@implementation GINIInjectorTestFactory
/** Test factory that creates a "foobar" instance */
+ (id)createFoobar{
    GINICreateFoobarCalled += 1;
    return @"foobar";
}

/** Test factory that creates a "raboof" instance which is dependent on the "foobar" instance. */
+(id)createRaboofWithFoobar:(NSString *)foobar{
    return [@"raboof" stringByAppendingString:foobar];
}

/** Test factory that has two dependencies */
+(id)createFoobarWithRaboof:(NSString *)raboof andFoobar:(NSString *)foobar{
    return [NSString stringWithFormat:@"foobar%@%@", raboof, foobar];
}

/** Test factory that creates a "foobar" instance, but this time the factory is an instance method, not a class method. */
- (id)instanceCreateFoobar {
    return @"foobar";
}

@end

SPEC_BEGIN(GINIInjectorSpec)

describe(@"The GINIInjector", ^{
    __block GINIInjector* giniInjector;

    beforeEach(^{
        giniInjector = [GINIInjector new];
        GINICreateFoobarCalled = 0;
    });


    it(@"should provide a method to register a factory (class method)", ^{
        [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                             forKey:@protocol(GINIInjectorTestProtocol)
                withDependencies:nil];

        [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                          forKey:@"foobar"
                withDependencies:nil];
    });

    it(@"should provide a method to register a factory (instance method)", ^{
        [giniInjector setFactory:@selector(instanceCreateFoobar)
                              on:[GINIInjectorTestFactory new]
                          forKey:@protocol(GINIInjectorTestProtocol)
                withDependencies:nil];

        [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                          forKey:@"foobar"
                withDependencies:nil];
    });

    it(@"should return the correct factory description for a given key", ^{
        id descriptionForProtocolKey = [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                          forKey:@protocol(GINIInjectorTestProtocol)
                withDependencies:nil];

        id descriptionForStringKey = [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                          forKey:@"foobar"
                withDependencies:nil];

        [[[giniInjector factoryForKey:@protocol(GINIInjectorTestProtocol)] should] equal:descriptionForProtocolKey];
        [[[giniInjector factoryForKey:@"foobar"] should] equal:descriptionForStringKey];
    });

    it(@"should return an instance", ^{
        [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                          forKey:@protocol(GINIInjectorTestProtocol)
                withDependencies:nil];

        id instance = [giniInjector getInstanceOf:@protocol(GINIInjectorTestProtocol) provideDependencies:nil];
        [[instance should] equal:@"foobar"];
    });

    it(@"should be able to instantiate dependencies", ^{
        [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                          forKey:@"foobar"
                withDependencies:nil];

        [giniInjector setFactory:@selector(createRaboofWithFoobar:)
                              on:[GINIInjectorTestFactory class]
                          forKey:@"raboof"
                withDependencies:@"foobar", nil];

        id instance = [giniInjector getInstanceOf:@"raboof"];
        [[instance should] equal:@"rabooffoobar"];
    });

    it(@"should be able to register values", ^{
        [giniInjector setObject:@"teeeeest" forKey:@"testKey"];
        id instance = [giniInjector getInstanceOf:@"testKey" provideDependencies:nil];
        [[instance should] equal:@"teeeeest"];
    });

    it(@"should be able to overwrite the providers when getting an instance", ^{
        [giniInjector setObject:@"foobar" forKey:@"foobar"];
        [giniInjector setFactory:@selector(createRaboofWithFoobar:)
                              on:[GINIInjectorTestFactory class]
                          forKey:@"raboof"
                withDependencies:@"foobar", nil];
        id instance = [giniInjector getInstanceOf:@"raboof" provideDependencies:@{
                @"foobar" : @"gnarf"
        }];
        [[instance should] equal:@"raboofgnarf"];
    });

    it(@"should instantiate singletons only once", ^{
        GINIFactoryDescription *factoryDescription = [giniInjector setFactory:@selector(createFoobar)
                              on:[GINIInjectorTestFactory class]
                          forKey:@"foobar"
                withDependencies:nil];
        factoryDescription.isSingleton = YES;
        id instanceOne = [giniInjector getInstanceOf:@"foobar"];
        id instanceTwo = [giniInjector getInstanceOf:@"foobar"];
        [[instanceOne should] equal:instanceTwo];
        [[theValue(GINICreateFoobarCalled) should] equal:theValue(1)];
    });

    context(@"The factory registration", ^{
        it(@"should raise an exception if arguments are skipped ", ^{
            [[theBlock(^{
                [giniInjector setFactory:nil on:[GINIInjectorTestFactory class] forKey:@"foobar" withDependencies:nil];
            }) should] raise];

            [[theBlock(^{
                [giniInjector setFactory:@selector(createFoobar) on:[GINIInjectorTestFactory class] forKey:nil withDependencies:nil];
            }) should] raise];
        });

        it(@"should raise an exception if the given class does not have the factory method", ^{
            [[theBlock(^{
                [giniInjector setFactory:@selector(stringWithCapacity:)
                                      on:[GINIInjectorTestFactory class]
                                  forKey:@"foobar"
                        withDependencies:nil];
            }) should] raise];
        });

        it(@"should raise an exception if the given object does not have the factory method", ^{
            [[theBlock(^{

                [giniInjector setFactory:@selector(createFoobar)
                                      on:[GINIInjectorTestFactory new]
                                  forKey:@"foobar"
                        withDependencies:nil];
            }) should] raise];
        });
    });

    context(@"The singleton factory registration", ^{
        it(@"should be able to register a singleton factory", ^{
            GINIFactoryDescription *factoryDescription = [giniInjector setSingletonFactory:@selector(createFoobar)
                                                                               on:[GINIInjectorTestFactory class]
                                                                           forKey:@"foobar"
                                                                 withDependencies:nil];
            [[theValue(factoryDescription.isSingleton) should] beYes];
            id instanceOne = [giniInjector getInstanceOf:@"foobar"];
            id instanceTwo = [giniInjector getInstanceOf:@"foobar"];
            [[instanceOne should] equal:instanceTwo];
            [[theValue(GINICreateFoobarCalled) should] equal:theValue(1)];
        });

        it(@"should be able to register a singleton factory with dependencies", ^{
            [giniInjector setSingletonFactory:@selector(createFoobar)
                                           on:[GINIInjectorTestFactory class]
                                       forKey:@"foobar"
                             withDependencies:nil];
            [giniInjector setSingletonFactory:@selector(createRaboofWithFoobar:)
                                           on:[GINIInjectorTestFactory class]
                                       forKey:@"raboof"
                             withDependencies:@"foobar", nil];

            GINIFactoryDescription *factoryDescription = [giniInjector setSingletonFactory:@selector(createFoobarWithRaboof:andFoobar:)
                                                                                        on:[GINIInjectorTestFactory class]
                                                                                    forKey:@"foobarRaboofFoobar"
                                                                          withDependencies:@"raboof", @"foobar", nil];
            [[theValue(factoryDescription.isSingleton) should] beYes];
            id instanceOne = [giniInjector getInstanceOf:@"foobarRaboofFoobar"];
            id instanceTwo = [giniInjector getInstanceOf:@"foobarRaboofFoobar"];
            [[instanceOne should] equal:instanceTwo];
            [[instanceOne should] equal:@"foobarrabooffoobarfoobar"];
        });
    });
});

SPEC_END