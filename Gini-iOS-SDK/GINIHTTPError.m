/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIHTTPError.h"
#import "GINIURLResponse.h"
#import "GINIError.h"

NSString *const GINIHTTPErrorKeyResponse = @"response";

@implementation GINIHTTPError
+ (instancetype)HTTPErrrorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [[self alloc] initWithDomain:GINIErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)HTTPErrrorWithResponse:(GINIURLResponse *)response code:(NSInteger)code userInfo:(NSDictionary *)dict {
    if (!dict) {
        dict = [NSDictionary new];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    userInfo[GINIHTTPErrorKeyResponse] = response;
    return [[self alloc] initWithDomain:GINIErrorDomain code:code userInfo:userInfo];
}

- (GINIURLResponse *)response {
    return self.userInfo[GINIHTTPErrorKeyResponse];
}

@end
