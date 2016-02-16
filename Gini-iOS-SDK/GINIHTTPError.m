/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIHTTPError.h"
#import "GINIURLResponse.h"
#import "GINIError.h"

NSString *const GINIHTTPErrorKeyResponse = @"response";

@implementation GINIHTTPError

+ (instancetype)errorWithResponse:(GINIURLResponse *)response {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[GINIHTTPErrorKeyResponse] = response;
    return [[self alloc] initWithCode:GINIHTTPErrorRequestError cause:nil userInfo:userInfo];
}

- (GINIURLResponse *)response {
    return self.userInfo[GINIHTTPErrorKeyResponse];
}

@end
