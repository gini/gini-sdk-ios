#import "GINIURLResponse.h"


@implementation GINIURLResponse

@synthesize data, response;

#pragma mark - Factories
+ (instancetype)urlResponseWithResponse:(NSHTTPURLResponse *)urlResponse {
    return [[GINIURLResponse alloc] initWithResponse:urlResponse];
}

+ (instancetype)urlResponseWithResponse:(NSHTTPURLResponse *)urlResponse data:(id)urlData {
    return [[GINIURLResponse alloc] initWithResponse:urlResponse data:urlData];
}


#pragma mark - Initializers
- (instancetype)initWithResponse:(NSHTTPURLResponse *)urlResponse {
    self = [super init];
    if (self) {
        self.response = urlResponse;
    }
    return self;
}

- (instancetype)initWithResponse:(NSHTTPURLResponse *)urlResponse data:(id)responseData {
    self = [super init];
    if (self) {
        self.response = urlResponse;
        self.data = responseData;
    }
    return self;
}

@end