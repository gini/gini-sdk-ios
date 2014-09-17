/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GINIHTTPError.h"
#import "GINIURLResponse.h"


@implementation GINIHTTPError {

}
+ (instancetype)HTTPErrrorWithResponse:(GINIURLResponse *)response {
    return [[self alloc] initWithResponse:response];
}

- (instancetype)initWithResponse:(GINIURLResponse *)response {
    if (self = [super init]) {
        self.response = response;
    }
    return self;
}

@end
