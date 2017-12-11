//
//  GINIURLSessionDelegate.m
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 12/11/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

#import "GINIURLSessionDelegate.h"

@implementation GINIURLSessionDelegate {
    NSString *_nsCertPath;
}

+ (instancetype)urlSessionDelegateWithCertPath:(NSString *)certPath {
    return [[self alloc] initWithNSURLSessionDelegate:certPath];
}

- (instancetype)initWithNSURLSessionDelegate:(NSString *)certPath {
    self = [super init];
    if (self) {
        _nsCertPath = certPath;
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
    NSData *localCertificate = [NSData dataWithContentsOfFile:_nsCertPath];
    
    if (([remoteCertificateData isEqualToData:localCertificate] && certificateIsValid) || _nsCertPath == nil ) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

@end
