/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "GINIAPIManager.h"

@interface GINIAPIManagerMock : GINIAPIManager
/**
 * A counter that counts how many times the `getDocument:` method has been called.
 */
@property NSUInteger getDocumentCalled;
@end
