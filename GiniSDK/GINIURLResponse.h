#import <Foundation/Foundation.h>


/**
 * The `GINIURLResponse` is a value object for the result of an HTTP request.
 */
@interface GINIURLResponse : NSObject


+ (instancetype)urlResponseWithResponse:(NSHTTPURLResponse *)urlResponse;
+ (instancetype)urlResponseWithResponse:(NSHTTPURLResponse *)urlResponse data:(id)urlData;

- (instancetype)initWithResponse:(NSHTTPURLResponse *)urlResponse;
- (instancetype)initWithResponse:(NSHTTPURLResponse *)urlResponse data:(id)responseData;


/**
 * The interpreted data, based on the content type of the response. @see GINIURLSession for more detailed information
 * about the of the content-type deserialization of the data.
 */
@property id data;

/**
 * TODO
 * Usually this property is of the sub type `NSHTTPURLResponse`.
 */
@property NSHTTPURLResponse *response;

@end