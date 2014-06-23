/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface NSString (GINIAdditions)

/*
 * Creates a URL query string from a parameter dictionary.
 *
 * Every key in the dictionary ìs expected to be an `NSString`. All keys that have a value of `[NSNull null]` will be
 * translated to a parameter without '=' character.
 *
 * NOTE: The resulting query string is automatically percent-encoded.
 *
 * @returns The query string.
 */
+ (instancetype)GINIQueryStringWithParameterDictionary:(NSDictionary *)parameters;

/*
 * Creates an `NSDictionary` out of the URL query string represented by the current object.
 *
 * Every key in the dictionary will be a `NSString`. Every parameter in the string which does not have a '=' (and the
 * right side of the equity) will have its value set to `[NSNull null]`.
 *
 * @returns A dictionary with the query parameters.
 */
- (NSDictionary *)GINIQueryStringParameterDictionary;

@end