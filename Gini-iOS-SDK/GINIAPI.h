//
//  GINIAPI.h
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 1/10/19.
//

/**
 * The current supported APIs
 */
typedef NS_ENUM(NSInteger, GINIAPIType) {
    /// The default one, which points to https://api.gini.net
    GINIAPITypeDefault = 0,
    /// The accounting API, which points to https://accounting-api.gini.net/
    GINIAPITypeAccounting = 1
};

@interface GINIAPI : NSObject

@property (readonly) NSURL *baseUrl;
@property (readonly) NSDictionary *contentTypes;

- (instancetype)initWithBaseURL:(NSURL *)baseUrl contentTypes:(NSDictionary *)contentTypes;

@end
