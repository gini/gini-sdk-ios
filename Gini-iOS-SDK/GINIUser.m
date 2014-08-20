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

+ (id)userFromAPIResponse:(NSDictionary *)response {

    if ([response isKindOfClass:[NSDictionary class]]) {
        id email = response[@"email"];
        id userId = response[@"id"];

        if ([email isKindOfClass:[NSString class]] && [userId isKindOfClass:[NSString class]]) {
            return [GINIUser userWithEmail:email userId:userId];
        }
    }

    return nil;
}


- (instancetype)initWithEmail:(NSString *)email userId:(NSString *)userId {
    self = [super init];
    if (self) {
        self.userEmail = email;
        self.userId = userId;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GINIUser email=%@, id=%@>", _userEmail, _userId];
}

@end
