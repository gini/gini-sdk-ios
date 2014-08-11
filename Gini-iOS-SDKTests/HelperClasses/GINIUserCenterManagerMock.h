/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "GINIUserCenterManager.h"

@class BFTask;


@interface GINIUserCenterManagerMock : GINIUserCenterManager

@property BOOL loginEnabled;
@property BOOL getInfoEnabled;
@property BOOL createUserEnabled;

@end