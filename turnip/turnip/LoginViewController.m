//
//  LoginViewController.m
//  turnip
//
//  Created by Per on 1/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

#pragma mark -
#pragma mark Login


- (IBAction)facebookLoginButton:(id)sender {
     NSArray *permissionsArray = @[ @"user_about_me", @"user_birthday", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            // Hide the activity view
            //self.activityViewVisible = NO;
            NSString *alertMessage, *alertTitle;
            if (error) {
                FBErrorCategory errorCategory = [FBErrorUtility errorCategoryForError:error];
                if ([FBErrorUtility shouldNotifyUserForError:error]) {
                    // If the SDK has a message for the user, surface it.
                    alertTitle = @"Something Went Wrong";
                    alertMessage = [FBErrorUtility userMessageForError:error];
                } else if (errorCategory == FBErrorCategoryAuthenticationReopenSession) {
                    // It is important to handle session closures. We notify the user.
                    alertTitle = @"Session Error";
                    alertMessage = @"Your current session is no longer valid. Please log in again.";
                } else if (errorCategory == FBErrorCategoryUserCancelled) {
                    // The user has cancelled a login. You can inspect the error
                    // for more context. Here, we will simply ignore it.
                    NSLog(@"user cancelled login");
                } else {
                    // Handle all other errors in a generic fashion
                    alertTitle  = @"Unknown Error";
                    alertMessage = @"Error. Please try again later.";
                }
                
                if (alertMessage) {
                    [[[UIAlertView alloc] initWithTitle:alertTitle
                                                message:alertMessage
                                               delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                }
            }
        } else {
            // Make a call to get user info
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                dispatch_block_t completion = ^{
                    // Hide the activity view
                    // Show the logged in view
                    
                    [self performSegueWithIdentifier:@"loginSegue" sender:sender];
                };
                
                if (error) {
                    completion();
                } else {
                    // Save the name on Parse
                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                    [[PFInstallation currentInstallation] saveEventually];
                    
                    [PFUser currentUser][@"name"] = user.name;
                    [PFUser currentUser][@"facebookId"] = user.objectID;
                    [PFUser currentUser][@"TOS"] = @"True";
                    [PFUser currentUser][@"birthday"] = user.birthday;
                    
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        completion();
                    }];
                }
            }];
        }
    }];
}
@end
