//
//  GINIURLSessionDelegate.h
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 12/11/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol GINIURLSessionDelegate <NSObject>
@end

@interface GINIURLSessionDelegate : NSObject <NSURLSessionDelegate>

+ (instancetype)urlSessionDelegate;

@end
