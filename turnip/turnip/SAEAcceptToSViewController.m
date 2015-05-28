//
//  SAEAcceptToSViewController
//  turnip
//
//  Created by Per on 3/27/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAEAcceptToSViewController.h"
#import <Parse/Parse.h>

@interface SAEAcceptToSViewController ()

@end

@implementation SAEAcceptToSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma button handlers

- (IBAction)acceptButton:(id)sender {
    [PFUser currentUser][@"TOS"] = @"True";

    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //go to mapview.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
        [self presentViewController:mapViewController animated:YES completion:nil];
    }];
}

- (IBAction)cancelButton:(id)sender {
    // go back to Login view
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    [self presentViewController:lvc animated:YES completion:nil];
}
@end
