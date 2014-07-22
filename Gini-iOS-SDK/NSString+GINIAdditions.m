/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "NSString+GINIAdditions.h"

// This method is copied from BFAppLinkNavigation.m (Bolts framework)
NSString *stringByEscapingString(NSString *string) {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
            (CFStringRef)string,
            NULL,
            (CFStringRef)@":/?#[]@!$&'()*+,;=",
            kCFStringEncodingUTF8));
}

@implementation NSString (GINIAdditions)

NSString *GINIDecodeURLString(NSString *string) {

    return (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef) string, CFSTR("")));
}

+ (instancetype)GINIQueryStringWithParameterDictionary:(NSDictionary *)parameters {

    NSMutableArray *stringParameters = [NSMutableArray new];

    for (NSString *key in parameters.allKeys) {
        NSMutableArray *parameterComponents = [NSMutableArray new];
        [parameterComponents addObject:stringByEscapingString(key)];

        NSString * value;
        if ([parameters[key] isKindOfClass:[NSString class]]) {
            value = parameters[key];
        } else {
            value = [NSString stringWithFormat:@"%@", value];
        }

        if (value) {
            [parameterComponents addObject:stringByEscapingString(value)];
        }
        [stringParameters addObject:[parameterComponents componentsJoinedByString:@"="]];
    }

    return [stringParameters componentsJoinedByString:@"&"];
}

- (NSDictionary *)GINIQueryStringParameterDictionary {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *query = self;
    if ([query isEqualToString:@""]) {
        return @{};
    }
    NSArray *queryComponents = [query componentsSeparatedByString:@"&"];
    for (NSString *component in queryComponents) {
        NSRange equalsLocation = [component rangeOfString:@"="];
        if (equalsLocation.location == NSNotFound) {
            // There's no equals, so associate the key with NSNull
            parameters[GINIDecodeURLString(component)] = [NSNull null];
        } else {
            NSString *key = GINIDecodeURLString([component substringToIndex:equalsLocation.location]);
            NSString *value = GINIDecodeURLString([component substringFromIndex:equalsLocation.location + 1]);
            parameters[key] = value;
        }
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end