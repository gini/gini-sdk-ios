//
//  GINIAPIFactory.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 1/10/19.
//

#import <Foundation/Foundation.h>
#import "GINIAPIFactory.h"
#import "GINIAPI.h"
#import "GINIConstants.h"

@implementation GINIAPIFactory {
    GINIAPIType *_apiType;
    NSURL *_baseUrl;
}

+ (GINIAPI *)apiWith:(GINIAPIType)apiType {
    return [[GINIAPI alloc] initWithBaseURL:[GINIAPIFactory baseUrlForApi:apiType]
                               contentTypes:[GINIAPIFactory contentTypesForApi:apiType]];
}

+ (NSURL *)baseUrlForApi:(GINIAPIType)apiType {
    switch (apiType) {
        case GINIAPITypeDefault:
            return [NSURL URLWithString:@"https://api.gini.net/"];
        case GINIAPITypeAccounting:
            return [NSURL URLWithString:@"https://accounting-api.gini.net/"];
    }
}

+ (NSDictionary *)contentTypesForApi:(GINIAPIType)apiType {
    NSMutableDictionary *contentTypes = [NSMutableDictionary new];
    switch (apiType) {
        case GINIAPITypeDefault:
            contentTypes[GINIContentTypeJsonKey] = GINIContentJsonV2;
            contentTypes[GINIContentTypeXmlKey] = GINIContentXmlV2;
            contentTypes[GINIContentTypeCompositeJsonKey] = GINICompositeJsonV2;
            contentTypes[GINIContentTypePartialTypeKey] = GINIPartialTypeV2;
            break;
        case GINIAPITypeAccounting:
            contentTypes[GINIContentTypeJsonKey] = GINIContentJsonV1;
            contentTypes[GINIContentTypeXmlKey] = GINIContentXmlV1;
            break;
    }
    
    contentTypes[GINIContentTypeIncubatorJsonKey] = GINIIncubatorJson;
    contentTypes[GINIContentTypeIncubatorXmlKey] = GINIIncubatorXml;
    
    return [NSDictionary dictionaryWithDictionary:contentTypes];
}

@end
