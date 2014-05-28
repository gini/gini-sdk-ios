/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINICredentialsStore.h"

@interface GINIKeychainCredentialsStore : NSObject <GINICredentialsStore>

- (instancetype)initWithIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup;

@end
