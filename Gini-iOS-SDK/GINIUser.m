/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIUser.h"

@implementation GINIUser {
}

+ (instancetype)userWithEmail:(NSString *)email userId:(NSString *)userId {
    NSParameterAssert([email isKindOfClass:[NSString class]]);
    NSParameterAssert([userId isKindOfClass:[NSString class]]);

    return [[GINIUser alloc] initWithEmail:email userId:userId];
}

- (instancetype)initWithEmail:(NSString *)email userId:(NSString *)userId {
    self = [super init];
    if (self) {
        self.userEmail = email;
        self.userId = userId;
    }
    return self;
}

@end
