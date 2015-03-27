//
//  VerificationViewController.m
//  turnip
//
//  Created by Per on 3/27/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "VerificationViewController.h"
#import "LoginViewController.h"
#import "MapViewController.h"
#import <Parse/Parse.h>

@interface VerificationViewController ()

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validCode:) name:@"validCodeNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark parse queries

- (void) verifyInviteCode {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    [query whereKey:@"inviteCode" equalTo:self.codeField.text];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"error");
        } else {
            if (object == nil) {
                NSLog(@"not a valid code");
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"validCodeNotification" object:nil];
            }
        }
    }];
}

- (void) validCode:(NSNotification *) note {
    //add TOS = TRUE to currentUser.
    
    [PFUser currentUser][@"TOS"] = @"True";
    [[PFUser currentUser] saveInBackground];
    
    //go to mapview.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MapViewController *mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapView"];
    [self presentViewController:mapViewController animated:YES completion:nil];
}

- (IBAction)acceptButton:(id)sender {
    [self verifyInviteCode];
}

- (IBAction)cancelButton:(id)sender {
    // go back to Login view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LoginViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    [self presentViewController:lvc animated:YES completion:nil];
}
@end
