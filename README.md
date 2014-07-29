iOSLinkedInTokenAuthorizer
==========================

iOSLinkedInTokenAuthorizer is a small Objective-C helper class for LinkedIn App authentication and OAuth 2 token refreshing. It relies on jeyben's awesome  [iOSLinkedInAPI](https://github.com/jeyben/IOSLinkedInAPI), while adding functionality "set it and forget it" token authentication, allowing for OAuth2 token refreshing that doesn't require user interaction to refresh non-expired tokens. 

##Installation & basic usage

- Drag the `iOSLinkedInTokenAuthorizer/iOSLinkedInTokenAuthorizer` folder into your project.
- Add [iOSLinkedInAPI](https://github.com/jeyben/IOSLinkedInAPI) and [AFNetworking](https://github.com/AFNetworking/AFNetworking) to your project.
- Input your LinkedIn app's information into the appropriate constants in `LTAlinkedInTokenHandler.m`.
<p align="center"><img src="http://i.imgur.com/T3BRLia.png"/></p>
- `#import "LTAlinkedInTokenHandler.h"` into the view controllers you want to manage the LinkedIn authorization process and into any where you want to call the the token refresh method. 
- Set cookie accept policy to 'always' by calling `[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways]` before calling `loginToLinkedIn:` (you can change the accept policy back to whatever you'd like after the first LinkedIn login process completes. You will need to set it to 'always' before calling the `authorizeApp:` method, but, again, you can change it to whatever you'd like after the method completes).

##How to use
See sample project in `/iOSLinkedInTokenAuthorizerExample`.

##Notes

###The LinkedIn Authentication Flow ...
LinkedIn doesn't provide an explicit token refresh call, rather, when making an app authentication call, there's a check to see if:
1) The user is logged in to LinkedIn.
2) The user has an existing, unexpired token. 

If both requirements are met, the token is refreshed without any interaction on the user's part. 
If one or both requirements are not met, the user is taken to LinkedIn's app authentication login page to allow the user to authorize the app, and, in doing so, obtain an OAuth 2 token.  

###... and an inherent difficulty for iOS apps needing to utilize LinkedIn's API without requiring the user to re-authenticate the app after 60 days (that iOSLinkedInTokenAuthorizer attempts to solve)
After going through the initial authorization flow on an iOS device, the user gets their token, which satisfies requirement 2 when a subsequent authorization call is made with 60 days of token creation, however, a login session cookie is never exchanged during the initial authentication. Because of this, the user is sent to the app authorization login screen again.

iOSLinkedInTokenAuthorizer provides the missing step needed to generate the login session cookie, and then capture it so your app can use it for subsequent calls to refresh a user's token. 

Unfortunately, for that session cookie to be generated and captured, an initial LinkedIn login has to be completed. After that, then the authentication call is made to generate a token. What that boils down to is the user has to log in twice. After that, as long as the user opens your app within 60 days (and you provide a call to the `authorizeApp:` method before 60 days is up), the token can be refreshed in the background without them having to be sent to a LinkedIn login screen again. 

##Tips
- Add an alertView or some other popup or label prior to the user's initial login to alert them to the process. Something with a message along the lines of "For <name of feature or app>  to work, please log in to your LinkedIn Account." Then, when the LinkeIn's "login to authenticate" screen appears, display another alertView with a message along the lines of "Please authenticate <app name> to authorize it to access your LinkedIn account." Basically some sort of indicator that the two login methods are necessary, and are not a mistake. 

- When refreshing a token using the `authorizeApp:` method, the `iOSLinkedInAPI "LIALinkedInAuthorizationViewController"` will attempt to display a webView for the authentication flow, which it will quickly show the navigation bar, then quickly dismiss. Since this is code that pertains to `iOSLinkedInAPI`, I have not modified the behavior in this public library, but you can modify `LIALinkedInAuthorizationViewController.m` to add a check along the lines of 
	`if ([]LTAlinkedInTokenHandler hasSessionCookie] && [][NSUserDefaults NSstandardUserDefaults] objectForKey:@"linkedin_token]")`
and suppress the webView there.

##Thanks
- [jeyben](https://github.com/jeyben) and his [iOSLinkedInAPI library](https://github.com/jeyben/IOSLinkedInAPI).
- [Mattt Thompson](http://nshipster.com) and his always invaluable [AFNetworking library](http://afnetworking.com).