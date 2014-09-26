/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIError.h"


NSString *const GINIErrorDomain = @"net.gini.error";

NSString *const GINIErrorKeyCause = @"cause";


@implementation GINIError

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [[self alloc] initWithDomain:GINIErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)errorWithCode:(NSInteger)code cause:(NSError *)cause userInfo:(NSDictionary *)dict {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    userInfo[GINIErrorKeyCause] = cause;
    return [self errorWithCode:code userInfo:userInfo];
}

- (NSError *)cause {
    return self.userInfo[GINIErrorKeyCause];
}

@end
