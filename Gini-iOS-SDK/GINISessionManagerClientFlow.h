/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINISessionManager.h"

@interface GINISessionManagerClientFlow : GINISessionManager

/**
 *  Initializes the manager to use client-side authentication flow.
 *
 *  @param clientID         The clientID you received from Gini.
 *  @param baseURL          The base URL of the Gini Oauth Server.
 *
 *  @return The initialized instance
 */
- (instancetype)initWithClientID:(NSString *)clientID baseURL:(NSURL *)baseURL URLSession:(GINIURLSession *)URLSession;

@end
