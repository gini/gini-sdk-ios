/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIError.h"


NSString *const GINIErrorDomain = @"net.gini.error";
NSInteger const GINIErrorNoValidSession = 1;


@implementation GINIError

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [[self alloc] initWithDomain:GINIErrorDomain code:code userInfo:userInfo];
}

@end
