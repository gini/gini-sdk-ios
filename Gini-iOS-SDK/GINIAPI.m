//
//  GINIAPI.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 1/10/19.
//

#import <Foundation/Foundation.h>
#import "GINIAPI.h"

@interface GINIAPI ()
@end


@implementation GINIAPI {
}

- (instancetype)initWithBaseURL:(NSURL *)baseUrl contentTypes:(NSDictionary *)contentTypes {
    _baseUrl = baseUrl;
    _contentTypes = contentTypes;
    return self;
}

@end
