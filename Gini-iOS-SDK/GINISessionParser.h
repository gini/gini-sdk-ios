/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

@class GINISession;

@interface GINISessionParser : NSObject

/**
 * Parses a JSON dictionary into a `GINISession` given that the it matches the description on the API.
 *
 * The expected dictionary should look like the following:
 *
 * {
 *    "access_token": "exampleToken", (Necessary)
 *    "refresh_token": "exampleToken", (Optional)
 *    "expires_in": 123 (Necessary)
 * }
 *
 * If a necessary parameter is not found, nil is returned.
 */
+ (GINISession*)sessionWithJSONDictionary:(NSDictionary *)dictionary;

@end