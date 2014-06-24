/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

/**
 * This protocol is used for checking if a specific URL should be handled by the app.
 *
 * It links the part where the ApplicationDelegate receives a new incoming URL and needs to pass it to the session
 * manager to check if it is a authentication request.
 */
@protocol GINIIncomingURLDelegate <NSObject>

/**
 * Checks if a specific URL should be handled by the implementing class of this method, it should return YES if
 * is handled by the class or NO otherwise.
 *
 * @param URL The URL that should be checked
 */
- (BOOL)handleURL:(NSURL*)URL;

@end
