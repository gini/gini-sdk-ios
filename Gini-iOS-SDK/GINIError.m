/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIError.h"


NSString *const GINIErrorDomain = @"net.gini.error";

NSString *const GINIErrorKeyCause = @"cause";


@implementation GINIError

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [self errorWithCode:code cause:nil userInfo:userInfo];
}

+ (instancetype)errorWithCode:(NSInteger)code cause:(NSError *)cause userInfo:(NSDictionary *)userInfo {
    return [[self alloc] initWithCode:code cause:cause userInfo:userInfo];
}

- (instancetype)initWithCode:(NSInteger)code cause:(NSError *)cause userInfo:(NSDictionary *)dict {
    if (!dict) {
        dict = [NSDictionary new];
    }
    if (cause) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
        userInfo[GINIErrorKeyCause] = cause;
        self = [super initWithDomain:GINIErrorDomain code:code userInfo:userInfo];
    } else {
        self = [super initWithDomain:GINIErrorDomain code:code userInfo:dict];
    }
    return self;
}

- (NSError *)cause {
    return self.userInfo[GINIErrorKeyCause];
}

@end
