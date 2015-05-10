//
//  LoginViewController.m
//  turnip
//
//  Created by Per on 1/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "LoginViewController.h"
#import "AcceptToSViewController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "Reachability.h"
#import "ReachabilityManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.tabBarController.tabBar setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"test");
    
    self.activityView.hidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([ReachabilityManager isReachable]) {
        self.facebookLoginButton.hidden = NO;
    } else {
        self.facebookLoginButton.hidden = YES;
        self.connectionLabel.hidden = NO;
    }
    
}

#pragma mark -
#pragma mark Login


- (IBAction)facebookLoginButton:(id)sender {
    self.facebookLoginButton.hidden = YES;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    
     NSArray *permissionsArray = @[ @"user_about_me", @"user_birthday", @"user_location", @"user_photos"];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"user cancelled login");
        } else if(user.isNew) {
            // Make a call to get user info
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    NSLog(@"error occured");
                } else {
                    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                        [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:permissionsArray];
                    }
                    // Save the name on Parse
                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                    [[PFInstallation currentInstallation] saveEventually];
                    
                    [PFUser currentUser][@"bio"] = @"Hi, I really like to party";
                    [PFUser currentUser][@"name"] = [result objectForKey:@"name"];
                    [PFUser currentUser][@"firstName"] = [result objectForKey:@"first_name"];
                    [PFUser currentUser][@"lastName"] = [result objectForKey:@"last_name"];
                    [PFUser currentUser][@"facebookId"] = [result objectForKey:@"id"];
                    [PFUser currentUser][@"TOS"] = @"False";
                    [PFUser currentUser][@"birthday"] = [result objectForKey:@"birthday"];
                    
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self presentTosView];
                    }];
                }
            }];
        }else {
            // Make a call to get user info
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    NSLog(@"something went wrong: %@", error);
                } else {
                    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                        [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:permissionsArray];
                    }
                    // Save the name on Parse
                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                    [[PFInstallation currentInstallation] saveEventually];
                    
                    [PFUser currentUser][@"firstName"] = [result objectForKey:@"first_name"];
                    [PFUser currentUser][@"lastName"] = [result objectForKey:@"last_name"];
                    [PFUser currentUser][@"birthday"] = [result objectForKey:@"birthday"];
                    
                    [[PFUser currentUser] saveInBackground];
                    
                    if ([[PFUser currentUser][@"TOS"] isEqualToString:@"False"]) {
                        [self presentTosView];
                    } else {
                        [self presentMapView];
                    }
                }
            }];
        }
    }];
}

- (void) presentMapView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    [self presentViewController:mvc animated:YES completion:nil];
}

- (void) presentTosView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *atvc = [storyboard instantiateViewControllerWithIdentifier:@"acceptTosView"];
    [self presentViewController:atvc animated:YES completion:nil];
}

- (void) reachabilityDidChange: (NSNotification *) note {
    if ([ReachabilityManager isReachable]) {
        NSLog(@"reached");
        self.facebookLoginButton.hidden = NO;
        self.connectionLabel.hidden = YES;
        
    } else {
        self.facebookLoginButton.hidden = YES;
        self.connectionLabel.hidden = NO;
    }
}
@end
