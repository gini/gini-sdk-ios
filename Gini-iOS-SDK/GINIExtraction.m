/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIExtraction.h"


@implementation GINIExtraction {
    NSString *_value;
    NSDictionary *_box;
}


- (void)setValue:(NSString *)value {
    if (_value != value) {
        _isDirty = YES;
    }
    _value = value;
}

- (NSString *)value {
    return _value;
}

- (NSDictionary *)box {
    return _box;
}

- (void)setBox:(NSDictionary *)value {
    if (_box != value) {
        _isDirty = YES;
    }
    _box = value;
}

+ (instancetype)extractionWithName:(NSString *)name value:(NSString *)value entity:(NSString *)entity box:(NSDictionary *)box {
    return [[GINIExtraction alloc] initWithName:name value:value entity:entity box:box];
}

- (instancetype)initWithName:(NSString *)name value:(NSString *)value entity:(NSString *)entity box:(NSDictionary *)box {
    self = [super init];
    if (self) {
        _isDirty = NO;
        _name = name;
        _value = value;
        _entity = entity;
        _box = box;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GINIExtraction %@=%@>", _name, _value];
}

@end
