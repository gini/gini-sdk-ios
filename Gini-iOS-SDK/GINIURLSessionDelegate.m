//
//  GINIURLSessionDelegate.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 12/11/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

#import "GINIURLSessionDelegate.h"

@implementation GINIURLSessionDelegate {
    NSString *_nsCertificatePath;
}

+ (instancetype)urlSessionDelegateWithCertificatePath:(NSString *)certificatePath {
    return [[self alloc] initWithNSURLSessionDelegate:certificatePath];
}

- (instancetype)initWithNSURLSessionDelegate:(NSString *)certificatePath {
    self = [super init];
    if (self) {
        _nsCertificatePath = certificatePath;
    }
    return self;
}

-(void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))
completionHandler {
    
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    
    NSMutableArray *policies = [NSMutableArray array];
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)
                                                                 challenge.protectionSpace.host)];
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    BOOL certificateIsValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    
    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    NSData *localCertificate = [NSData dataWithContentsOfFile:_nsCertificatePath];
    
    if (([remoteCertificateData isEqualToData:localCertificate] && certificateIsValid) || _nsCertificatePath == nil ) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

@end
