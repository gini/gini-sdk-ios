#import <Kiwi/Kiwi.h>
#import "GINIURLResponse.h"


SPEC_BEGIN(GINIURLResponseSpec)

describe(@"The GINIURLResponse", ^{
    it(@"should have a factory that takes a NSHTTPURLResponse instance", ^{
        NSHTTPURLResponse *httpurlResponse = [NSHTTPURLResponse new];
        GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:httpurlResponse];
        [[response should] beKindOfClass:[GINIURLResponse class]];
        [[response.response should] equal:httpurlResponse];
    });

    it(@"should have a factory that takes a NSHTTPURLResponse instance and a data object", ^{
        NSHTTPURLResponse *httpurlResponse = [NSHTTPURLResponse new];
        NSData *data = [NSData new];
        GINIURLResponse *response = [GINIURLResponse urlResponseWithResponse:httpurlResponse data:data];
        [[response should] beKindOfClass:[GINIURLResponse class]];
        [[response.response should] equal:httpurlResponse];
        [[response.data should] equal:data];
    });
});

SPEC_END