//
//  GINIURLSessionDelegate.h
//  Gini-iOS-SDK
//
//  Created by Enrique del Pozo Gómez on 12/11/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol GINIURLSessionDelegate <NSObject>
@end

@interface GINIURLSessionDelegate : NSObject <NSURLSessionDelegate>

+ (instancetype)urlSessionDelegateWithCertPath:(NSString *)certPath;

@end
