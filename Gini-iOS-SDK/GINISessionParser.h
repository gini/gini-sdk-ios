/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

@class GINISession;

@interface GINISessionParser : NSObject

+ (GINISession*)sessionWithJSONDictionary:(NSDictionary *)dictionary;

+ (GINISession *)sessionWithFragmentParametersDictionary:(NSDictionary *)dictionary;

@end