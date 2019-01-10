//
//  GINIAPI.h
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 1/10/19.
//

typedef NS_ENUM(NSInteger, GINIAPIType) {
    GINIAPITypeDefault = 0,
    GINIAPITypeAccounting = 1
};

@interface GINIAPI : NSObject

@property (readonly) NSURL *baseUrl;
@property (readonly) NSDictionary *contentTypes;

- (instancetype)initWithBaseURL:(NSURL *)baseUrl contentTypes:(NSDictionary *)contentTypes;

@end
