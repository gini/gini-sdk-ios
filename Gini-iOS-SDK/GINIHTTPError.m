/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIHTTPError.h"
#import "GINIURLResponse.h"
#import "GINIError.h"

NSString *const GINIHTTPErrorKeyResponse = @"response";

@implementation GINIHTTPError {

}
+ (instancetype)HTTPErrrorWithResponse:(GINIURLResponse *)response code:(NSInteger)code userInfo:(NSDictionary *)dict {
    if (!dict) {
        dict = [NSDictionary new];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    userInfo[GINIHTTPErrorKeyResponse] = response;
    return [[self alloc] initWithCode:code userInfo:userInfo];
}

- (instancetype)initWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    if (self = [super initWithDomain:GINIErrorDomain code:code userInfo:userInfo]) {
        // Customize initialization
    }
    return self;
}

- (GINIURLResponse *)response {
    return self.userInfo[GINIHTTPErrorKeyResponse];
}

@end
