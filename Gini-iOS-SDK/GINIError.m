/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIError.h"


NSString *const GINIErrorDomain = @"net.gini.error";


@implementation GINIError

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [[GINIError alloc] initWithDomain:GINIErrorDomain code:code userInfo:userInfo];
}

@end
