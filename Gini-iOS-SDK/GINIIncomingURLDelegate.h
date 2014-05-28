/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

@protocol GINIIncomingURLDelegate <NSObject>

- (BOOL)handleURL:(NSURL*)URL;

@end
