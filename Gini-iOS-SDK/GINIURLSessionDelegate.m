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

+ (instancetype)urlSessionDelegateWithCertificatePaths:(NSArray<NSString *> *)certificatePaths {
    return [[self alloc] initWithNSURLSessionDelegate:certificatePaths];
}

- (instancetype)initWithNSURLSessionDelegate:(NSArray<NSString *> *)certificatePaths {
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
    BOOL remoteCertEqualToLocalCert = false;
    BOOL remoteCertificateIsValid = false;
    
    for (int i = 0; i < SecTrustGetCertificateCount(serverTrust); i++) {
        NSMutableArray *policies = [NSMutableArray array];
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)
                                                                     challenge.protectionSpace.host)];
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
        
        SecTrustResultType result;
        SecTrustEvaluate(serverTrust, &result);
        remoteCertificateIsValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
        
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        NSData *remoteCertificateData = (NSData *)CFBridgingRelease(SecCertificateCopyData(certificate));
        
        for (int j = 0; j < [_nsCertificatePaths count]; j++) {
            NSData *localCertificate = [NSData dataWithContentsOfFile:[_nsCertificatePaths objectAtIndex:j]];
            if(localCertificate != nil) {
                remoteCertEqualToLocalCert = [remoteCertificateData isEqualToData:localCertificate];
                if (remoteCertEqualToLocalCert) {
                    goto outer_done;
                }
            }
        }
    }
    outer_done:;
    
    if ((remoteCertEqualToLocalCert && remoteCertificateIsValid) || _nsCertificatePaths == nil ) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

@end
