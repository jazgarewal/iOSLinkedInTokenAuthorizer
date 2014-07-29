//
//  LTAlinkedInTokenHandler.h
//  linkedInTokenAuthorizer
//
//  Created by Jaz Garewal on 7/17/14.
//  Copyright (c) 2014 Skinny Bones Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 Put [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways] at some point before you call loginToLinkedInView
 
 Authorization flow is as follows for the user's first time using the app:
 1. User logs in to LinkedIn by calling the loginToLinkedInView method.
    The resulting session cookie is saved to NSUserDefaults for the app to use later to refresh the OAuth token
 2. The user is then sent to the LinkedIn authorization login screen to retrieve an OAuth token.
 3. After this, all subsequent calls to the authorizeApp method and refreshToken method can happen in the background without user interatction.
 */


@interface LTAlinkedInTokenHandler : NSObject

/**
 Check to see if the user has already logged in to LinkedIn.
 */
+(BOOL)hasSessionCookie;

/**
 Display the LinkedIn account login screen.
 */
-(void)loginToLinkedInInView:(UIView *)view;

/**
 Start the app authorization process. If the user hasn't granted access to their LinkedIn account, it will send them to the
 LinkedIn authorization login screen. Otherwise it will refresh the existing token without the user needing to do anything.
 Use this method to also refresh existing token.
 */
-(void)authorizeApp;


@end
