//
//  GINIURLSessionDelegate.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 12/11/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

#import "GINIURLSessionDelegate.h"

@implementation GINIURLSessionDelegate {
    NSArray<NSString *> *_nsCertificatePaths;
}

+ (instancetype)urlSessionDelegateWithCertificatePaths:(NSArray<NSString *> *) certificatePaths {
    return [[self alloc] initWithNSURLSessionDelegate:certificatePaths];
}

- (instancetype)initWithNSURLSessionDelegate:(NSArray<NSString *> *) certificatePaths {
    self = [super init];
    if (self) {
        _nsCertificatePaths = certificatePaths;
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
    NSData *localCertificate = [NSData dataWithContentsOfFile:_nsCertificatePaths];
    
    if (([remoteCertificateData isEqualToData:localCertificate] && certificateIsValid) || _nsCertificatePaths == nil ) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

@end
