//
//  LTAlinkedInTokenHandler.m
//  linkedInTokenAuthorizer
//
//  Created by Jaz Garewal on 7/17/14.
//  Copyright (c) 2014 Skinny Bones Productions. All rights reserved.
//

#import "LTAlinkedInTokenHandler.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"

//Set your app's LinkedIn API Key, SecretKey, state code (random string), your redirect URL (the app will not redirect to this site, instead it will return to your app), and an array of your app's scope
#define kAPIKey @"APIKey"
#define kSecretKey @"SecretKey"
#define kState @"State"
#define kRedirectURL @"redirectURL"
#define kGrantedAccess @[@"SCOPE"]

@interface LTAlinkedInTokenHandler () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *loginWebView;

@end

@implementation LTAlinkedInTokenHandler {
    LIALinkedInHttpClient *_client;
}

+(BOOL)hasSessionCookie {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"linkedInCookie"]) {
        return YES;
    } else {
        return NO;
    }
}

+(void)loadSessionCookie {
    NSData *cookieData = [[NSUserDefaults standardUserDefaults] objectForKey:@"linkedInCookie"];
    NSHTTPCookie *cookie = [NSKeyedUnarchiver unarchiveObjectWithData:cookieData];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

-(void)authorizeApp {
    [LTAlinkedInTokenHandler loadSessionCookie];
    
        [self.client getAuthorizationCode:^(NSString *code) {
            [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
                NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
                
                [self requestMeWithToken:accessToken];
                NSLog (@"success!");
                                
                
            }                   failure:^(NSError *error) {
                NSLog(@"Quering accessToken failed %@", error);
            }];
        }                      cancel:^{
            NSLog(@"Authorization was cancelled by user");
        }                     failure:^(NSError *error) {
            NSLog(@"Authorization failed %@", error);
        }];
    
}

-(void)loginToLinkedInInView:(UIView *)view {
    self.loginWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds) - [UIApplication sharedApplication].statusBarFrame.size.height)];
    
    [self.loginWebView setDelegate:self];
    
    [view addSubview:self.loginWebView];
    
    [self.loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://touch.linkedin.com"]]];
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    

    
    NSString *url = request.URL.absoluteString;
    
    if ([url rangeOfString:@"sessionid="].location != NSNotFound) {
        for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
            if ([cookie.name isEqualToString:@"li_at"]) {
                NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookie];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:cookieData forKey:@"linkedInCookie"];
                [defaults synchronize];
            }
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"linkedInCookie"]) {
                [self authorizeApp];
            }
            
        }
        
        [self.loginWebView removeFromSuperview];
        return NO;
    } else if ([url rangeOfString:@"?dl=no"].location !=NSNotFound) {
        
        [self.loginWebView removeFromSuperview];
        return NO;
    } else {
        return YES;
    }
    


}

- (void)requestMeWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:kRedirectURL clientId:kAPIKey clientSecret:kSecretKey state:kState grantedAccess:kGrantedAccess];

    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

@end
