/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "NSString+GINIAdditions.h"

@implementation NSString (GINIAdditions)

NSString *GINIDecodeURLString(NSString *string) {

    return (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef) string, CFSTR("")));
}

+ (instancetype)GINIQueryStringWithParameterDictionary:(NSDictionary *)parameters {

    NSMutableString *query = [NSMutableString string];

    for (NSString *key in parameters.allKeys) {
        [query appendFormat:@"%@", key];
        NSString * value = parameters[key];
        if (value != (id)[NSNull null]) {
            [query appendFormat:@"=%@", value];
        }
        [query appendString:@"&"];
    }

    if (query.length > 0) {
        [query deleteCharactersInRange:NSMakeRange(query.length - 1, 1)];
    }

    return [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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