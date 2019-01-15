//
//  GINIAPIFactory.h
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 1/10/19.
//

#import "GINIAPI.h"

@interface GINIAPIFactory : NSObject

+ (GINIAPI *)apiWith:(GINIAPIType)apiType;

@end
