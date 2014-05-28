/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionParser.h"
#import "GINISession.h"

@implementation GINISessionParser

+ (GINISession *)sessionWithJSONDictionary:(NSDictionary *)dictionary {
    NSString *accessToken = dictionary[@"access_token"];
    NSString *refreshToken = dictionary[@"refresh_token"];
    NSNumber *expirationTimeNumber = dictionary[@"expires_in"];
    NSTimeInterval expirationTime = [expirationTimeNumber doubleValue];
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:expirationTime];
    return [[GINISession alloc] initWithAccessToken:accessToken refreshToken:refreshToken expirartionDate:expirationDate];
}

+ (GINISession *)sessionWithFragmentParametersDictionary:(NSDictionary *)dictionary {
    NSString *accessToken = dictionary[@"access_token"];
    NSString *refreshToken = dictionary[@"refresh_token"];
    NSString *expiresIn = dictionary[@"expires_in"];
    NSTimeInterval expirationTime = [expiresIn doubleValue];
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:expirationTime];
    return [[GINISession alloc] initWithAccessToken:accessToken refreshToken:refreshToken expirartionDate:expirationDate];
}

@end