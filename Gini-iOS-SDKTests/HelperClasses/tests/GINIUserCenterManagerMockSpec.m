#import <Kiwi/Kiwi.h>
#import "GINIUserCenterManagerMock.h"
#import "GINIURLSession.h"


SPEC_BEGIN(GINIUserCenterManagerMockSpec)

    describe(@"The GINIUserCenterManagerMock", ^{
        __block GINIUserCenterManagerMock *userCenterManagerMock;

        beforeEach(^{
            userCenterManagerMock = [GINIUserCenterManagerMock new];
        });

        it(@"should raise an exception when the original factory is used to prevent accidental misuses", ^{
            GINIURLSession *giniurlSession = [GINIURLSession urlSessionWithNSURLSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]];
            [[theBlock(^{
                [GINIUserCenterManagerMock userCenterManagerWithURLSession:giniurlSession clientID:@"gini-ios-sdk" clientSecret:@"1234" baseURL:[NSURL URLWithString:@"https://user.gini.net"] notificationCenter:nil];
            }) should] raise];
        });

        it(@"should throw an exception if getUserInfo: is called when getInfoEnabled is NO", ^{
            userCenterManagerMock.getInfoEnabled = NO;

            [[theBlock(^{
                [userCenterManagerMock getUserInfo:@"1234"];
            }) should] raise];
        });

        it(@"should throw an exception if loginUser:password: is called when loginEnabled is NO", ^{
            userCenterManagerMock.loginEnabled = NO;

            [[theBlock(^{
                [userCenterManagerMock loginUser:@"foo@example.com" password:@"1234"];
            }) should] raise];
        });

        it(@"should throw an exception if createUserWithEmail:password: is called when createUserEnabled is NO", ^{
            userCenterManagerMock.createUserEnabled = NO;

            [[theBlock(^{
                [userCenterManagerMock createUserWithEmail:@"foo@example.com" password:@"1234"];
            }) should] raise];
        });
    });

SPEC_END
