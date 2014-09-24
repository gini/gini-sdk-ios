/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import "GININSNotificationCenterMock.h"


@implementation GININSNotificationCenterMock {
    NSMutableArray *_notifications;
}

+ (instancetype)defaultCenter {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _notifications = [NSMutableArray new];
    }
    return self;
}

- (void)postNotification:(NSNotification *)notification {
    [_notifications addObject:notification];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject {
    [self postNotificationName:aName object:anObject userInfo:nil];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    [self postNotification:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

- (NSArray *)notifications {
    return _notifications;
}

- (NSNotification *)lastNotification {
    return [_notifications lastObject];
}

@end