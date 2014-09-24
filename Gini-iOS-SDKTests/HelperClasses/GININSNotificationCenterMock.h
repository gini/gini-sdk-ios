/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>


@interface GININSNotificationCenterMock : NSNotificationCenter

// Thanks Apple for not using instancetype in the header file.
+ (instancetype)defaultCenter;

@property (readonly) NSArray *notifications;

@property (readonly) NSNotification *lastNotification;

@end