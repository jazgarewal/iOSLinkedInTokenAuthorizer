//
//  LTAViewController.m
//  linkedInTokenAuthorizer
//
//  Created by Jaz Garewal on 7/17/14.
//  Copyright (c) 2014 Skinny Bones Productions. All rights reserved.
//

#import "LTAViewController.h"
#import "LTAlinkedInTokenHandler.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

//Set this to match the definitions in LTAlinkedInTokenHandler.m. This is only for the alert view in "connectButtonTapped" to work in this example.
#define kAPIKey @"APIKey"
#define kSecretKey @"SecretKey"
#define kState @"State"
#define kRedirectURL @"redirectURL"
#define kGrantedAccess @[@"SCOPE"]

@interface LTAViewController ()

@property (strong, nonatomic) LTAlinkedInTokenHandler *tokenHandler;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *profileInfoButton;

@end

@implementation LTAViewController {
    LIALinkedInHttpClient *_client;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([kAPIKey isEqualToString:@"APIKey"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You haven't set your LinkedIn App data" message:@"Please set the constants in LTAViewController.m and LTAlinkedInTokenHandler.m" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    } else {
    
        self.tokenHandler = [LTAlinkedInTokenHandler new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"linkedInCookie"] && [defaults objectForKey:@"linkedin_token"]) {
            NSNumber *tokenExpiration = [defaults objectForKey:@"linkedin_expiration"];
            NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:tokenExpiration.floatValue];
           
            if ([expirationDate timeIntervalSinceDate:[NSDate date]] < 40320) {
                [self.tokenHandler authorizeApp];
            }
        }
    });
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"linkedInCookie"] && [defaults objectForKey:@"linkedin_token"]) {
            [self.connectButton setTitle:@"Refresh Token" forState:UIControlStateNormal];
            self.profileInfoButton.hidden = NO;
        } else {
            self.profileInfoButton.hidden = YES;
        }
    
    }
    
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)connectButtonTapped:(id)sender {
    
    if ([LTAlinkedInTokenHandler hasSessionCookie]) {
        [self.tokenHandler authorizeApp];
    } else {
        [self.tokenHandler loginToLinkedInInView:self.view];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"linkedin_token"]) {
        [self.connectButton setTitle:@"Refresh Token" forState:UIControlStateNormal];
        self.profileInfoButton.hidden = NO;
        NSString *tokenKey = [defaults objectForKey:@"linkedin_token"];
        NSString *tokenExpiration = [defaults objectForKey:@"linkedin_expiration"];
        NSString *tokenCreationDate = [defaults objectForKey:@"linkedin_token_created_at"];
        
        NSDate *creationDate = [NSDate dateWithTimeIntervalSince1970:tokenCreationDate.intValue];
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:tokenExpiration.intValue];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Token: %@", tokenKey] message:[NSString stringWithFormat:@"Token Created: %@\nToken Expires: %@", creationDate, expirationDate] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        
    }
}

- (IBAction)getFirstConnectionButtonTapped:(id)sender {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/connections?oauth2_access_token=%@&format=json", [[NSUserDefaults standardUserDefaults] objectForKey:@"linkedin_token"]] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSArray *connectionsArray = [result objectForKey:@"values"];
        NSDictionary *firstConnectionDictionary = connectionsArray.firstObject;
        NSLog (@"firstconnection dict is %@", firstConnectionDictionary);
        NSString *firstName = [firstConnectionDictionary objectForKey:@"firstName"];
        NSString *lastName = [firstConnectionDictionary objectForKey:@"lastName"];
        NSString *company = [firstConnectionDictionary objectForKey:@"headline"];
        NSDictionary *urlDictionary = [firstConnectionDictionary objectForKey:@"siteStandardProfileRequest"];
        NSString *url = [urlDictionary objectForKey:@"url"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", firstName, lastName] message:[NSString stringWithFormat:@"%@\n%@", company, url] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        
        
        
        
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:kRedirectURL clientId:kAPIKey clientSecret:kSecretKey state:kState grantedAccess:kGrantedAccess];
    
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

@end
